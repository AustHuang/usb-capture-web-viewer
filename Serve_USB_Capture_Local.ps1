# USB Capture Viewer local static server - Windows PowerShell 5.1, no admin / Python needed.
# Only serves one HTML page, only on 127.0.0.1, no uploads or filesystem browsing.
param(
  [Parameter(Mandatory=$true)][string]$SiteRoot,
  [ValidateRange(1024,65535)][int]$Port=18764
)
$ErrorActionPreference='Stop'
$html=Join-Path $SiteRoot 'USB_Capture_Web_Viewer.html'
if(!(Test-Path -LiteralPath $html)){throw "Viewer HTML not found: $html"}
$listener=[System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,$Port)
$listener.Start()
$lastRequest=[DateTime]::UtcNow
try {
  # The browser pings /__ping every 30 seconds. Stop the server 2 minutes after exit.
  while(([DateTime]::UtcNow-$lastRequest).TotalSeconds -lt 120){
    if(!$listener.Pending()){Start-Sleep -Milliseconds 150;continue}
    $client=$listener.AcceptTcpClient()
    try {
      $client.ReceiveTimeout=2500
      $client.SendTimeout=2500
      $stream=$client.GetStream()
      $reader=[System.IO.StreamReader]::new($stream,[System.Text.Encoding]::ASCII,$false,1024,$true)
      $line=$reader.ReadLine()
      if([string]::IsNullOrWhiteSpace($line)){continue}
      $headers=@{}
      for($i=0;$i -lt 60;$i++){
        $header=$reader.ReadLine()
        if([string]::IsNullOrEmpty($header)){break}
        $split=$header.IndexOf(':')
        if($split -gt 0){$headers[$header.Substring(0,$split).Trim().ToLowerInvariant()]=$header.Substring($split+1).Trim()}
      }
      $parts=$line.Split(' ')
      $path=if($parts.Length -ge 2){$parts[1].Split('?')[0]}else{'/bad'}
      $hostHeader=$headers['host']
      $status='200 OK'
      $type='text/plain; charset=utf-8'
      $body=''
      if($hostHeader -ne "127.0.0.1:$Port"){$status='403 Forbidden';$body='Forbidden'}
      elseif($parts[0] -ne 'GET' -and $parts[0] -ne 'HEAD'){$status='405 Method Not Allowed';$body='Method Not Allowed'}
      elseif($path -eq '/__health'){$body='USB-CAPTURE-LOCALHOST-v1'}
      elseif($path -eq '/__ping'){$body='OK'}
      elseif($path -eq '/' -or $path -eq '/USB_Capture_Web_Viewer.html'){$type='text/html; charset=utf-8'}
      elseif($path -eq '/favicon.ico'){$status='204 No Content'}
      else {$status='404 Not Found';$body='Not Found'}
      $lastRequest=[DateTime]::UtcNow
      $payload=if($type -like 'text/html*' -and $status -eq '200 OK'){
        [System.IO.File]::ReadAllBytes($html)
      }else{[System.Text.Encoding]::UTF8.GetBytes($body)}
      $meta="HTTP/1.1 $status`r`nContent-Type: $type`r`nContent-Length: $($payload.Length)`r`nCache-Control: no-store`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
      $prefix=[System.Text.Encoding]::ASCII.GetBytes($meta)
      $stream.Write($prefix,0,$prefix.Length)
      if($parts[0] -ne 'HEAD' -and $payload.Length -gt 0){$stream.Write($payload,0,$payload.Length)}
      $stream.Flush()
    }catch{}finally{$client.Close()}
  }
}finally{$listener.Stop()}
