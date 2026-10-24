# Lições aprendidas (incidentes reais)

| Problema | Causa | Solução |
|---|---|---|
| Dados do inversor pararam 3 dias | O dongle mudou de IP (DHCP) | Varrimento de portas, reserva DHCP, vigilância por "idade da última leitura" (os sensores ficavam congelados em vez de "indisponível") |
| A lógica inicial nunca disparava | O excedente real é curto e o inversor tapa défices com a bateria antes de importar | Decisões por SoC + descarga da bateria + importação, não só por injeção |
| Estores mostravam "fechado" estando abertos | A integração inverte a posição nos módulos em modo "forward" | *Template covers* que invertem a leitura; testes estore a estore |
| Abrir pela percentagem parava a meio | A posição é estimada pelo tempo de curso calibrado; a subida é mais lenta | Abrir/fechar por comando de fim de curso; % só para posições intermédias |
| Um estore deixou de responder localmente | Bloqueio do módulo após muitas tentativas falhadas + perda de alcance no mesh | Descoberta por UDP decifrado, reinício do módulo; reserva pela cloud (cenas) com troca automática |
| Abertura matinal falhou quase toda | Erro intermitente da cloud ("sign invalid") abortava o script inteiro | Um comando de cada vez, cada um isolado, com verificação 1 min depois |
| Servidor parado 7 h | Windows Update reiniciou e ficou no ecrã de login (Docker só arranca com sessão) | Login automático, Docker no arranque, sem reinício automático, aviso de arranque |
| Dongle recusava ligações após o reinício | Ficou preso à ligação Modbus antiga | Recarga automática da integração + aviso para reiniciar o dongle |
| Atualizações "voltavam atrás" | O Docker matava o HA ao fim de 10 s e o HACS/BD não gravavam | `stop_grace_period: 2m` |
| Valores mudavam sozinhos | Barras deslizantes arrastadas sem querer no telemóvel | Campos numéricos (`mode: box`) |
| Contador de energia de um AC "impossível" | Multi-split: a energia da unidade exterior conta toda numa unidade interior | Teste controlado (ligar um AC, ver qual contador sobe) e renomear o contador |
| Câmaras desapareceram | Mudaram de IP depois de um reinício do router | Correção dos IPs + reservas DHCP |
| Integrações cloud em baixo depois de uma falha de corrente | O servidor arrancou antes de o Wi-Fi estar pronto: Tuya, MELCloud e eWeLink falharam a ligação e a recuperação dos estores desistiu | Ao arrancar, recarregar as integrações que ficaram todas indisponíveis (até 3 vezes, com aviso no fim); a recuperação dos estores espera que eles fiquem disponíveis |
