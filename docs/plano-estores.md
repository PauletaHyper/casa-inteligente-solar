# Plano dos estores (horário + proteção do calor)

Pedido do Filho a 2026-10-10. **IMPLEMENTADO a 2026-10-12** em
`config/packages/estores_automacao.yaml` (horário + proteção dos 4
estores poente; opcionais da secção 4, pontos 4 e 5, não implementados).
Dias úteis/feriados: `binary_sensor.workday_sensor_pt` (integração
Workday, PT). Gestão ativa desde 12/10 ~14h. Controlos na página
"Estores" do painel Casa. Por confirmar: orientação com bússola, e se o
`set_cover_position` dos estores corrigidos vai para a % certa (só os
botões subir/descer foram testados).

Objetivos: horário fixo de abrir e fechar (diferente em dias úteis e ao
fim de semana) e, durante o dia, proteger a casa do sol da tarde para a
manter fresca. Gostam de luz natural de manhã.

## 1. Orientação da casa (planta de arquitetura, proc. 058/PARQ/2019)

- Moradia geminada dos dois lados (lotes 480 e 482): norte e sul são
  empenas cegas. **Só há janelas na fachada da rua e na do jardim.**
- Seta do norte na vertical da planta: a rua fica a
  **poente (oeste)**, com sol da tarde, e o jardim (tardoz) a **nascente
  (este)**, com sol da manhã. Bate certo com o que o Filho observa ("à
  tarde o lado contrário ao jardim aquece").
- ⚠️ Confirmar com a bússola do telemóvel encostado à fachada da rua: o
  esperado é ~270°. Se for diferente, ajustar os azimutes da secção 5.

## 2. Estores: fachada e papel de cada um

⚠️ **Usar as entidades corrigidas** (`config/packages/estores.yaml`, desde
12/10). A integração Tuya mostrava 11 estores ao contrário. As entidades
`cover.*_cortina` originais estão escondidas e **não devem ser usadas**,
exceto `cover.estores_do_quarto_do_filho_cortina`, que já estava certa.
Corrigidas: `cover.estores_da_sala`, `cover.estores_da_sala_de_estar`,
`cover.estores_da_cozinha`, `cover.estores_do_escritorio_da_mae`,
`cover.estores_da_suite`, `cover.estores_da_casa_de_banho_da_suite`,
`cover.estores_do_closet`, `cover.estores_do_escritorio_do_pai`,
`cover.escadas_rooftop`, `cover.rooftop`, `cover.janela_rooftop`.

| Piso | Estore (`cover.*`) | Fachada | Proteção solar à tarde? |
|---|---|---|---|
| Cave | Estores da Garagem (tuya-local, por ligar) | tardoz | Não (só horário) |
| Piso 0 | Sala de estar (`estores_da_sala_de_estar_cortina`) | **Poente (rua)**, confirmado | **Sim** |
| Piso 0 | Sala (`estores_da_sala_cortina`) | Nascente (jardim) | Não |
| Piso 0 | Cozinha | Nascente | Não; **nunca fecha mais de 70 %** |
| Piso 0 | Escritório da Mãe | **Poente** | **Sim** |
| Piso 1 | Casa de banho da suite (`estores_da_casa_de_banho_cortina`) | Não definida | Não (só horário) |
| Piso 1 | Quarto do Filho | **Poente** | **Sim** |
| Piso 1 | Escritório do Pai | **Poente** | **Sim** |
| Piso 1 | Suite | Nascente | Não |
| Piso 1 | Closet | Nascente, confirmado | Não |
| Rooftop | Escadas Rooftop, Rooftop, Janela Rooftop | Não definida | Não: abertos de dia, fecham à noite |

## 3. Horário fixo (decidido pelo Filho)

### Abrir: dias úteis (segunda a sexta)
| Hora | Estores |
|---|---|
| 07:00 | Garagem |
| 08:00 | Casa de banho da suite (piso 1) |
| 09:00 | Suite, Closet, Escritório do Pai, os 3 do Rooftop, **todos os do piso 0** (sala, sala de estar, cozinha, escritório da Mãe) |
| 12:00 | Quarto do Filho |

### Abrir: fim de semana (sábado e domingo)
| Hora | Estores |
|---|---|
| 10:00 | Todos os do Rooftop e todos os do piso 0 |
| 08:00 | Garagem |
| Sem hora | **Piso 1 fica fechado** (incluindo a casa de banho da suite): cada um abre o seu à mão |

### Fechar: todos os dias
| Hora | Estores |
|---|---|
| **Pôr do sol + 30 min** (desde 14/10; 13/10 pôr do sol; antes 21:00) | **Todos**, exceto Garagem e Cozinha |
| 23:30 | Garagem e Cozinha |

### Cozinha: fecho parcial
O estore da cozinha **fecha sempre só 70 %**, nunca até baixo. Ao fechar
fica com a posição em **30 %** (`cover.set_cover_position` 30, em vez de
`close_cover`). Confirmado: desce 70 %, fica 30 % aberto.

### Feriados
**Feriados nacionais contam como fim de semana** (confirmado). Usar a
integração **Workday** do HA (`binary_sensor.workday_sensor`, país PT):
"dia útil" = segunda a sexta e não feriado.

### Inverno e estação automática (21/10)
- **Estação** (`input_select.estacao`: Verão/Inverno) muda sozinha às
  06:00 (e ao arrancar o HA) pela **previsão do tempo** (met.no): média das
  máximas dos próximos 3 dias < 18 °C → Inverno; > 22 °C → Verão; no meio
  fica como está. Pode-se mudar à mão (desligar "Mudar sozinha").
  Notificação ao Filho quando muda.
- **Verão:** proteção do sol da tarde ativa (como antes).
- **Inverno:** proteção do sol desligada (o sol aquece a casa); em **dias
  frios** (exterior < 12 °C ao pôr do sol, sensor do AC da sala) os
  estores fecham **logo ao pôr do sol**; nos outros, pôr do sol + 30 min.
- Garagem continua a abrir às 7h. Mudança da hora (25/10) tratada pelo
  HA; a regra de fecho após reinício usa o pôr do sol registado no dia.

### Modo cinema (15/10)
Botões na página Estores. **Modo cinema** (`script.modo_cinema`): fecha
sala e sala de estar, cozinha a 40 % aberta. **Sair do modo cinema**
(`script.sair_modo_cinema`): repõe conforme a hora: de dia abre os três;
depois do fecho da noite a sala fica fechada e a cozinha volta a abrir
(até às 23:30) ou a 25 % (depois das 23:30).

## 4. Proteção do calor durante o dia (só os 4 estores poente)

Estores: sala de estar, escritório da Mãe, quarto do Filho,
escritório do Pai.

Ativa só em dias quentes: máxima prevista ≥ 25 °C, ou divisão ≥ 24 °C,
entre abril e outubro (ajustável).

1. **Tarde: descer para ~20 a 30 %** quando o sol bate na rua (azimute entre
   ~190° e ~300°, elevação > 8°) **e** há sol a sério (produção solar acima
   de ~40 % do esperado para a hora, ou nebulosidade < 60 %). Entra luz,
   mas a maior parte do calor fica de fora. Se a divisão passar 26 °C,
   descer até 0 a 10 %.
2. **Fim da tarde: voltar à posição anterior** quando o sol deixa de
   bater (elevação < 5°). Depois, às 21:00 fecham pelo horário.
3. **Só atua em estores que já estão abertos.** Nunca abre um estore que
   o horário (ou alguém) deixou fechado. Exemplos: o quarto do Filho
   antes das 12h, o piso 1 ao fim de semana.
4. Dias muito quentes (≥ 32 °C), opcional: a nascente também desce para
   ~50 % entre as 10h e o meio-dia solar. Desligado por omissão, porque
   preferem luz de manhã.
5. **Inverno** (máxima < 18 °C), opcional: em vez de proteger, manter
   abertos onde bate o sol (aquecimento passivo). O fecho às 21h isola a
   casa à noite.

## 5. Dados disponíveis no HA
- `sun.sun`: azimute e elevação.
- `weather.forecast_home`: máxima prevista e nebulosidade.
- Temperatura interior por divisão (ACs MELCloud):
  `sensor.ac_{sala,cozinha,ecritorio,escritorio_pai,filho,suite,rooftop}_temperatura_da_divisao`.
- `sensor.solax_inverter_pv_power_total`: sol real em vez de previsão.
- Posição dos estores em %.

## 6. Regras de convivência
- **Uso manual manda.** Se alguém mexer num estore, a proteção solar
  deixa-o em paz até ao dia seguinte. **O horário fixo (abrir e fechar)
  continua a aplicar-se**, porque é o que foi pedido.
- Interruptor geral `input_boolean.gestao_estores_ativa`, mais um
  interruptor "modo férias" (desliga a abertura e mantém o fecho).
- Proteção solar: no máximo 1 ajuste por estore a cada 30 min, com
  decisões tomadas sobre médias de 10 a 15 min.
- Horas e percentagens como `input_datetime` / `input_number`, editáveis
  na UI (como no termossifão).
- Se o HA reiniciar, ao arrancar aplicar o estado esperado para a hora
  (por exemplo, depois das 21h garantir que estão fechados).

## 7. Questões em aberto ❓
1. Orientação com bússola (secção 1). As outras dúvidas ficaram
   respondidas a 10/10: o estore WC é da casa de banho da suite (piso 1;
   já movido no HA), a garagem ao fim de semana abre às 08:00, a cozinha
   fica 30 % aberta, e os feriados contam como fim de semana.
2. O estore da garagem só entra no horário depois de ligado por
   tuya-local (ver README). Até lá, só há a cena Tuya, que não dá estado.

## 8. Ordem de implementação sugerida
1. Horário fixo (secção 3): simples e de valor imediato.
2. Proteção solar dos 4 estores poente (secção 4), observando 1 a 2 semanas.
3. Opcionais (nascente em dias muito quentes, modo inverno).
4. Comparar no Grafana a temperatura das divisões poente antes e depois.
