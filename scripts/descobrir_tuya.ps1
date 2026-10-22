# Escuta os anuncios UDP dos aparelhos Tuya (portas 6666 e 6667) e mostra
# o IP e o ID (gwId) de cada um. Os anuncios da porta 6667 vem cifrados com
# a chave publica fixa da Tuya (MD5 de "yGAdlopoPVldABfn").
# Uso: powershell -ExecutionPolicy Bypass -File scripts\descobrir_tuya.ps1

param([int]$Segundos = 20)

$md5 = [System.Security.Cryptography.MD5]::Create()
$key = $md5.ComputeHash([Text.Encoding]::ASCII.GetBytes("yGAdlopoPVldABfn"))
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Mode = "ECB"; $aes.Padding = "None"; $aes.Key = $key

function Decifrar([byte[]]$b) {
    $n = $b.Length - ($b.Length % 16)
    if ($n -le 0) { return "" }
    $p = $aes.CreateDecryptor().TransformFinalBlock($b, 0, $n)
    return [Text.Encoding]::UTF8.GetString($p)
}

$vistos = @{}
$sockets = foreach ($porta in 6666, 6667) {
    $u = New-Object System.Net.Sockets.UdpClient
    $u.Client.SetSocketOption("Socket", "ReuseAddress", $true)
    $u.Client.Bind((New-Object System.Net.IPEndPoint([Net.IPAddress]::Any, $porta)))
    $u.Client.ReceiveTimeout = 500
    $u
}

Write-Host "A escutar durante $Segundos s..."
$fim = (Get-Date).AddSeconds($Segundos)
while ((Get-Date) -lt $fim) {
    foreach ($u in $sockets) {
        try {
            $ep = New-Object System.Net.IPEndPoint([Net.IPAddress]::Any, 0)
            $d = $u.Receive([ref]$ep)
        } catch { continue }
        $ip = $ep.Address.ToString()
        if ($vistos.ContainsKey($ip)) { continue }
        $txt = [Text.Encoding]::UTF8.GetString($d)
        if ($txt -notmatch "gwId") {
            foreach ($ini in 20, 24) {
                if ($d.Length -gt $ini + 8) {
                    $corpo = $d[$ini..($d.Length - 9)]
                    $t = Decifrar $corpo
                    if ($t -match "gwId") { $txt = $t; break }
                }
            }
        }
        $id = if ($txt -match '"gwId"\s*:\s*"([^"]+)"') { $Matches[1] } else { "(nao decifrado)" }
        $ver = if ($txt -match '"version"\s*:\s*"([^"]+)"') { $Matches[1] } else { "?" }
        $vistos[$ip] = $id
        Write-Host ("{0,-16} {1}  v{2}  (porta {3})" -f $ip, $id, $ver, $u.Client.LocalEndPoint.Port)
    }
}
$sockets | ForEach-Object { $_.Close() }
Write-Host "Fim. $($vistos.Count) aparelhos encontrados."
