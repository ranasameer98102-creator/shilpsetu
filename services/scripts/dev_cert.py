"""Self-signed HTTPS certificate for testing the web app from a phone on the same Wi-Fi.

Browsers only give a page the microphone over https (or on localhost), so the LAN link needs TLS for voice input:

    python -m scripts.dev_cert 192.168.1.20          # writes .data/dev-cert.pem and .data/dev-key.pem
    uvicorn api.main:app --host 0.0.0.0 --port 8443 --ssl-certfile .data/dev-cert.pem --ssl-keyfile .data/dev-key.pem

The phone shows a one-time warning (the certificate is not from a public authority): Advanced -> Proceed.
Production uses a real certificate from the host (Render, nginx + Let's Encrypt).
"""
import ipaddress
import sys
from datetime import datetime, timedelta, timezone

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.x509.oid import NameOID

from api.config import get_settings


def main(ips: list[str]) -> None:
    key = ec.generate_private_key(ec.SECP256R1())
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "ShilpSetu local demo")])
    alt = [x509.DNSName("localhost")] + [x509.IPAddress(ipaddress.ip_address(ip)) for ip in ["127.0.0.1", *ips]]
    now = datetime.now(timezone.utc)
    cert = (x509.CertificateBuilder().subject_name(name).issuer_name(name).public_key(key.public_key())
            .serial_number(x509.random_serial_number()).not_valid_before(now - timedelta(days=1))
            .not_valid_after(now + timedelta(days=365))
            .add_extension(x509.SubjectAlternativeName(alt), critical=False)
            .sign(key, hashes.SHA256()))
    d = get_settings().data_dir
    (d / "dev-cert.pem").write_bytes(cert.public_bytes(serialization.Encoding.PEM))
    (d / "dev-key.pem").write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
                                                      serialization.NoEncryption()))
    print(f"wrote {d / 'dev-cert.pem'} for {', '.join(['localhost', '127.0.0.1', *ips])}")


if __name__ == "__main__":
    main(sys.argv[1:])
