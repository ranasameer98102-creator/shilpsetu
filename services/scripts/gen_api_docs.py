"""Generate docs/api.md from the FastAPI OpenAPI schema.  Run: python -m scripts.gen_api_docs"""
import json
from pathlib import Path

from fastapi.openapi.utils import get_openapi

from api.main import app

ROOT = Path(__file__).resolve().parents[2]


def main() -> None:
    spec = get_openapi(title=app.title, version=app.version, description=app.description, routes=app.routes)
    (ROOT / "docs").mkdir(exist_ok=True)
    (ROOT / "docs" / "openapi.json").write_text(json.dumps(spec, indent=2, ensure_ascii=False), encoding="utf-8")
    by_tag: dict[str, list[tuple[str, str, dict]]] = {}
    for path, ops in spec["paths"].items():
        for method, op in ops.items():
            by_tag.setdefault((op.get("tags") or ["other"])[0], []).append((method.upper(), path, op))
    lines = [
        "# ShilpSetu API reference",
        "",
        f"Generated from the OpenAPI schema (`docs/openapi.json`, {sum(len(v) for v in by_tag.values())} operations). "
        "Interactive docs: `http://localhost:8000/docs`. Base path `/api/v1` unless shown otherwise. "
        "Auth: `Authorization: Bearer <JWT>` from `/api/v1/auth/otp/verify`; kiosk operators add `X-Artisan-Id`.",
        "",
    ]
    for tag in sorted(by_tag):
        lines += [f"## {tag}", "", "| Method | Path | Summary | Request body |", "|---|---|---|---|"]
        for method, path, op in sorted(by_tag[tag], key=lambda x: (x[1], x[0])):
            summary = (op.get("summary") or "").replace("|", "/")
            desc = (op.get("description") or "").split("\n")[0].replace("|", "/")
            body = ""
            rb = op.get("requestBody", {}).get("content", {})
            for ct, c in rb.items():
                ref = c.get("schema", {}).get("$ref") or c.get("schema", {}).get("items", {}).get("$ref")
                body = f"`{ref.split('/')[-1]}`" if ref else f"`{ct}`"
            lines.append(f"| {method} | `{path}` | {summary}{' — ' + desc if desc else ''} | {body} |")
        lines.append("")
    lines += ["## Schemas", ""]
    for name, schema in sorted(spec.get("components", {}).get("schemas", {}).items()):
        props = schema.get("properties", {})
        if not props:
            continue
        req = set(schema.get("required", []))
        lines.append(f"### {name}")
        lines.append("")
        for k, v in props.items():
            t = v.get("type") or (v.get("$ref", "").split("/")[-1]) or " | ".join(
                a.get("type", a.get("$ref", "").split("/")[-1]) for a in v.get("anyOf", []))
            lines.append(f"- `{k}`{' *' if k in req else ''}: {t}{' — ' + v['description'] if v.get('description') else ''}")
        lines.append("")
    (ROOT / "docs" / "api.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote docs/api.md ({len(lines)} lines) and docs/openapi.json")


if __name__ == "__main__":
    main()
