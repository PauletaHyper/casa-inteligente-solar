# Arquitetura

## Hardware e rede
- **Inversor híbrido** monofásico de 3,7 kW com bateria, com dongle Wi-Fi que
  expõe **Modbus TCP** (porta 502). Sem hardware extra (RS485), confirmado
  com um *dump* de registos em Python (`scripts/dump_modbus_registers.py`).
- **Servidor**: portátil Windows 11 a correr 24/7, IP fixo, Docker Desktop
  (WSL2). Preparado para servidor: início de sessão automático, Docker no
  arranque, sem suspensão, Windows Update sem reinício automático.
- **Rede**: sistema mesh com 6 nós atrás do router do operador (duplo NAT).
  IPs reservados por DHCP para tudo o que o HA contacta diretamente
  (inversor, câmaras, servidor).

## Serviços (Docker Compose)
| Contentor | Função |
|---|---|
| Home Assistant | automações, integrações, painel, notificações |
| InfluxDB 2 | histórico de longo prazo (sensores, interruptores, ACs, estores) |
| Grafana | painéis de análise |

Ver `docker-compose.example.yml` (segredos num `.env`, fora do repositório).

## Integrações
| Origem | Como | Aparelhos |
|---|---|---|
| Inversor | Modbus TCP local (5 s) | produção, bateria, casa, rede |
| Tuya / Smart Life | cloud oficial + tuya-local | 13 estores, tomadas com medição, termoacumulador, robôs, piscina |
| Mitsubishi MELCloud | cloud | 7 ACs |
| Samsung SmartThings | cloud (OAuth) | máquina de lavar e secador |
| eWeLink | cloud | 5 interruptores de luz |
| Câmaras | ONVIF + RTSP local | 8 câmaras, vídeo e rotação |
| met.no | previsão | estação Verão/Inverno |
| Workday | feriados nacionais | horários dos estores |

## Organização das automações (`homeassistant/packages/`)
| Ficheiro | Conteúdo |
|---|---|
| `excedente_solar.yaml` | termoacumulador com excedente solar, segurança, vigilância do inversor |
| `estores.yaml` | *template covers* que corrigem posição/sentido dos estores Tuya |
| `estores_automacao.yaml` | horários, fecho ao pôr do sol, proteção solar, estação, modo cinema, script de movimento com confirmação |
| `casa_automacoes.yaml` | lavandaria, resumo de energia, casa vazia, luzes, avisos |
| `ac_noite.yaml` | desligar o AC do quarto à noite |
| `resiliencia.yaml` | aviso de arranque, recuperação do inversor, recuperação dos estores |

## Padrões usados
- **Package por domínio** e **parâmetros como `input_*`** (editáveis no painel).
- **Comandos isolados** (`script.turn_on` de um script por comando) para que
  um erro da cloud não interrompa uma sequência; **confirmação e repetição**
  (até 3x / 6x) com base no estado reportado.
- **Histerese** em todas as decisões (SoC liga 95 % / desliga 85 %; estação
  Inverno < 18 °C / Verão > 22 °C) e **médias móveis** em vez de valores
  instantâneos.
- **Recuperação após paragem**: o HA regista um "sinal de vida" a cada 2 min;
  ao arrancar sabe quanto tempo esteve parado e repõe o que ficou por fazer.
