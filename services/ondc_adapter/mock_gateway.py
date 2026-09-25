"""Mock ONDC gateway + a tiny fake buyer app (BAP) for dev demos of the full ONDC order round-trip.

Real ONDC requires registry onboarding; this stands in for gateway + buyer app so judges can watch a
listing approved in ShilpSetu get discovered, ordered and tracked from 'another app' on the network.
"""
from __future__ import annotations

import uuid
from collections import defaultdict, deque
from datetime import datetime, timezone

from fastapi import APIRouter, BackgroundTasks, Depends, Request
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session

from api.config import get_settings
from api.db import get_db

router = APIRouter(prefix="/ondc-mock", tags=["ondc-mock"])

CALLBACKS: dict[str, list[dict]] = defaultdict(list)
NETWORK_INDEX: dict[str, dict] = {}  # item id -> last catalog item seen by the gateway
LOG: deque = deque(maxlen=200)


def _ctx(action: str, txn: str | None = None) -> dict:
    s = get_settings()
    return {"domain": s.ondc_domain, "country": "IND", "city": s.ondc_city, "action": action,
            "core_version": "1.2.0", "bap_id": "mock-buyer.ondc.local",
            "bap_uri": f"{s.public_base_url}/ondc-mock/bap", "bpp_id": s.ondc_subscriber_id,
            "bpp_uri": s.ondc_subscriber_uri, "transaction_id": txn or uuid.uuid4().hex,
            "message_id": uuid.uuid4().hex, "timestamp": datetime.now(timezone.utc).isoformat(), "ttl": "PT30S"}


def receive(action: str, payload: dict) -> None:
    txn = payload.get("context", {}).get("transaction_id", "?")
    CALLBACKS[txn].append({"action": action, "payload": payload})
    LOG.appendleft({"at": datetime.now(timezone.utc).isoformat(), "direction": "BPP→BAP", "action": action,
                    "transaction_id": txn})


def index_catalog(catalog: dict) -> None:
    for prov in catalog.get("bpp/providers", []):
        for it in prov.get("items", []):
            NETWORK_INDEX[it["id"]] = {"provider": prov["descriptor"]["name"], **it}
    LOG.appendleft({"at": datetime.now(timezone.utc).isoformat(), "direction": "BPP→Gateway",
                    "action": "catalog_sync", "transaction_id": "-"})


def _call(db: Session, action: str, body: dict) -> dict:
    from .bpp import process

    LOG.appendleft({"at": datetime.now(timezone.utc).isoformat(), "direction": "BAP→BPP", "action": action,
                    "transaction_id": body["context"]["transaction_id"]})
    result = process(db, action, body)
    db.commit()
    return result


@router.post("/gateway/search")
async def gateway_search(request: Request, background: BackgroundTasks, db: Session = Depends(get_db)):
    """Gateway fan-out: forwards a BAP search to registered BPPs (here, ShilpSetu)."""
    body = await request.json()
    _call(db, "search", body)
    return {"message": {"ack": {"status": "ACK"}}}


@router.post("/bap/{action}")
async def bap_callback(action: str, request: Request):
    receive(action, await request.json())
    return {"message": {"ack": {"status": "ACK"}}}


class BuyerSearch(BaseModel):
    q: str = ""


class BuyerOrder(BaseModel):
    product_id: str
    qty: int = 1
    name: str = "Asha Rao"
    phone: str = "9800000000"
    building: str = "12 MG Road"
    city: str = "Bengaluru"
    state: str = "Karnataka"
    pincode: str = "560001"
    paid: bool = True


@router.post("/buyer/api/search")
def buyer_search(req: BuyerSearch, db: Session = Depends(get_db)):
    ctx = _ctx("search")
    result = _call(db, "search", {"context": ctx, "message": {"intent": {"item": {"descriptor": {"name": req.q}}}}})
    return {"transaction_id": ctx["transaction_id"], "catalog": result["message"]["catalog"]}


@router.post("/buyer/api/order")
def buyer_order(req: BuyerOrder, db: Session = Depends(get_db)):
    txn = uuid.uuid4().hex
    items = [{"id": req.product_id, "quantity": {"count": req.qty}}]
    fulfil = [{"id": "F1", "type": "Delivery", "end": {
        "location": {"address": {"name": req.name, "building": req.building, "city": req.city, "state": req.state,
                                 "area_code": req.pincode, "country": "IND"}},
        "contact": {"phone": req.phone, "name": req.name}}}]
    sel = _call(db, "select", {"context": _ctx("select", txn), "message": {"order": {"items": items}}})
    if "error" in sel:
        return {"error": sel["error"]}
    _call(db, "init", {"context": _ctx("init", txn), "message": {"order": {"items": items, "fulfillments": fulfil,
                                                                             "billing": {"name": req.name, "phone": req.phone}}}})
    conf = _call(db, "confirm", {"context": _ctx("confirm", txn), "message": {"order": {
        "items": items, "fulfillments": fulfil, "billing": {"name": req.name, "phone": req.phone},
        "payment": {"type": "ON-ORDER" if req.paid else "ON-FULFILLMENT", "status": "PAID" if req.paid else "NOT-PAID",
                    "collected_by": "BAP"}}}})
    return {"transaction_id": txn, "order": conf["message"]["order"],
            "callbacks": [c["action"] for c in CALLBACKS[txn]]}


@router.get("/buyer/api/status/{order_id}")
def buyer_status(order_id: str, db: Session = Depends(get_db)):
    from api.models import Order

    o = db.get(Order, order_id)
    res = _call(db, "status", {"context": _ctx("status", o.ondc_transaction_id if o else None),
                               "message": {"order_id": order_id}})
    return res.get("message", res)


@router.get("/log")
def network_log():
    return {"events": list(LOG), "indexed_items": len(NETWORK_INDEX)}


@router.get("/buyer", response_class=HTMLResponse)
def buyer_app():
    return BUYER_HTML


BUYER_HTML = """<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Mock ONDC Buyer App</title>
<style>
:root{--bg:#f4f6fb;--card:#fff;--ink:#1d2433;--muted:#5b6475;--accent:#2f5bd3}
body{margin:0;font-family:system-ui,Segoe UI,Roboto,sans-serif;background:var(--bg);color:var(--ink)}
header{background:#1d2433;color:#fff;padding:14px 16px}header small{display:block;color:#aab3c5;font-size:12px}
main{max-width:980px;margin:0 auto;padding:16px}form{display:flex;gap:8px}
input{flex:1;padding:12px;border:1px solid #cdd3df;border-radius:10px;font-size:16px}
button{padding:12px 16px;border:0;border-radius:10px;background:var(--accent);color:#fff;font-size:15px;cursor:pointer}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:12px;margin-top:16px}
.card{background:var(--card);border-radius:12px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.card img{width:100%;aspect-ratio:1;object-fit:cover;border-radius:8px;background:#e8ebf2}
.p{font-weight:700}.m{color:var(--muted);font-size:13px}pre{white-space:pre-wrap;background:#fff;padding:12px;border-radius:10px;font-size:12px}
</style></head><body><header><b>Mock ONDC Buyer App</b><small>Dev-only stand-in for any ONDC buyer app — discovers sellers via the mock gateway</small></header>
<main><form id="f"><input id="q" placeholder="Search the ONDC network (e.g. pottery, saree, dhokra)"><button>Search</button></form>
<div id="res" class="grid"></div><h3>Network log</h3><pre id="out">—</pre></main>
<script>
const $=s=>document.querySelector(s);
async function j(u,b){const r=await fetch(u,{method:b?'POST':'GET',headers:{'Content-Type':'application/json'},body:b?JSON.stringify(b):undefined});return r.json()}
$('#f').onsubmit=async e=>{e.preventDefault();const d=await j('/ondc-mock/buyer/api/search',{q:$('#q').value});
 const items=[];(d.catalog['bpp/providers']||[]).forEach(p=>p.items.forEach(i=>items.push([p,i])));
 $('#res').innerHTML=items.map(([p,i])=>{const t=Object.fromEntries((i.tags.find(t=>t.code=='handicraft')||{list:[]}).list.map(x=>[x.code,x.value]));
 return `<div class=card><img src="${i.descriptor.symbol||''}" alt=""><div class=p>${i.descriptor.name}</div>
 <div class=m>by ${p.descriptor.name}</div><div class=p>₹${Number(i.price.value).toLocaleString('en-IN')}</div>
 <div class=m>${t.artisan_share_pct?t.artisan_share_pct+'% to artisan':''}${t.gi_tag?' · GI: '+t.gi_tag:''}</div>
 ${t.provenance_certificate?`<a class=m href="${t.provenance_certificate}" target=_blank>Provenance certificate ↗</a>`:''}
 <p><button onclick="buy('${i.id}')">Buy via ONDC</button></p></div>`}).join('')||'<p>No results</p>';log()};
async function buy(id){const d=await j('/ondc-mock/buyer/api/order',{product_id:id});$('#out').textContent=JSON.stringify(d,null,2);log()}
async function log(){const d=await j('/ondc-mock/log');$('#out').textContent+= '\\n\\n'+d.events.slice(0,12).map(e=>e.at.slice(11,19)+'  '+e.direction+'  '+e.action).join('\\n')}
</script></body></html>"""
