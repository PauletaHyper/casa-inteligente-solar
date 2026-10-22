"""
Fase A, passo 3 - diagnostico bruto de Modbus TCP ao dongle SolaX.

Nao assume mapa de registos: faz dump de holding registers e input
registers em blocos, para confirmar que o Modbus responde e permitir
comparar os valores com a documentacao oficial
(Solax_Hybrid_X1&X3-G4_ModbusTCP&RTU_V3.34) antes de mapear sensores.

Uso:
    pip install pymodbus
    python dump_modbus_registers.py <ip_dongle> [--port 502] [--unit 1]
"""

import argparse
import sys

from pymodbus.client import ModbusTcpClient


def dump_block(client, read_fn, label, start, count, unit):
    # O nome do parametro para o slave/device id mudou entre versoes do
    # pymodbus (unit -> slave -> device_id). Tenta as variantes conhecidas
    # antes de cair para chamada posicional.
    result = None
    last_error = None
    for kwargs in (
        {"device_id": unit},
        {"slave": unit},
        {"unit": unit},
    ):
        try:
            result = read_fn(address=start, count=count, **kwargs)
            break
        except TypeError as exc:
            last_error = exc
            continue

    if result is None:
        try:
            result = read_fn(start, count, unit)
        except TypeError:
            raise last_error

    if result.isError():
        print(f"  [{label}] regs {start}-{start + count - 1}: erro -> {result}")
        return

    for i, value in enumerate(result.registers):
        addr = start + i
        signed = value - 0x10000 if value >= 0x8000 else value
        print(f"  [{label}] reg {addr:5d}: raw={value:5d}  signed={signed:6d}  hex=0x{value:04X}")


def main():
    parser = argparse.ArgumentParser(description="Dump bruto de registos Modbus TCP do dongle SolaX")
    parser.add_argument("ip", help="IP do dongle na rede local")
    parser.add_argument("--port", type=int, default=502)
    parser.add_argument("--unit", type=int, default=1, help="Unit/slave id (normalmente 1)")
    parser.add_argument("--start", type=int, default=0, help="Registo inicial")
    parser.add_argument("--count", type=int, default=100, help="Quantos registos ler por bloco (max ~125)")
    args = parser.parse_args()

    client = ModbusTcpClient(args.ip, port=args.port)
    if not client.connect():
        print(f"Nao foi possivel ligar a {args.ip}:{args.port}")
        sys.exit(1)

    print(f"Ligado a {args.ip}:{args.port} (unit={args.unit})")

    print("\n-- HOLDING REGISTERS (function code 3) --")
    dump_block(client, client.read_holding_registers, "holding", args.start, args.count, args.unit)

    print("\n-- INPUT REGISTERS (function code 4) --")
    dump_block(client, client.read_input_registers, "input", args.start, args.count, args.unit)

    client.close()
    print("\nCompara os valores acima com a doc oficial dos registos para mapear")
    print("producao, consumo, potencia da rede, SoC da bateria, etc.")


if __name__ == "__main__":
    main()
