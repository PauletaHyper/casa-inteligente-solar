# Mostra os eventos de energia do Windows (desligar, suspender, reiniciar,
# falhas de energia) das ultimas N horas, para perceber porque o portatil
# deixou de correr o Home Assistant.
# Uso: & .\scripts\eventos_energia.ps1 [-Horas 12]
param([int]$Horas = 12)

$ids = 1, 12, 13, 41, 42, 107, 109, 187, 506, 507, 1074, 6005, 6006, 6008
Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = (Get-Date).AddHours(-$Horas) } -ErrorAction SilentlyContinue |
    Where-Object { $ids -contains $_.Id } |
    Sort-Object TimeCreated |
    ForEach-Object {
        $msg = ($_.Message -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 3) -join ' | '
        "{0:dd/MM HH:mm:ss}  [{1,5}] {2}: {3}" -f $_.TimeCreated, $_.Id, $_.ProviderName, $msg
    }

"--- Bateria ---"
Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue |
    ForEach-Object { "Carga: {0}%  Estado: {1}" -f $_.EstimatedChargeRemaining, $_.BatteryStatus }

"--- Plano de energia: suspender/hibernar (AC = ligado a corrente) ---"
powercfg /query SCHEME_CURRENT SUB_SLEEP | Select-String -Pattern "Nome do GUID|GUID Alias|Indice da Defini|Current AC|Current DC|Índice"
