"""Testa a ligacao local a um aparelho Tuya, fora do Home Assistant.

Uso: python scripts/testar_tuya.py <device_id> <ip>
A local key e pedida no terminal (nao fica guardada em lado nenhum).
Requer: pip install tinytuya
"""
import sys

import tinytuya

device_id, ip = sys.argv[1], sys.argv[2]
key = input("Local key: ").strip()

for version in (3.3, 3.4, 3.5, 3.1):
    d = tinytuya.Device(device_id, ip, key, version=version)
    d.set_socketTimeout(5)
    d.set_socketRetryLimit(1)
    status = d.status()
    print(f"v{version}: {status}")
    if status and "dps" in status:
        print("OK - versao certa:", version)
        break
