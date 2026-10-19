# USB Capture Viewer V1.6.2 RC1 - Chrome app window WITH native Windows 11 Snap Layout support.
# No SetWindowLong border removal: keeps the native maximize button and resizable frame.
param(
  [ValidateSet('Chrome','Edge','Auto')][string]$Browser='Chrome',
  [ValidateRange(20,90)][int]$HeightPercent=34,
  [int]$MonitorIndex=-1
)
$ErrorActionPreference='Stop'
try {
  $html=Join-Path $PSScriptRoot 'USB_Capture_Web_Viewer.html'
  if(!(Test-Path -LiteralPath $html)){throw "HTML file not found: $html"}
  $paths=@()
  if($Browser -ne 'Edge'){
    if($env:ProgramFiles){$paths+=Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe'}
    if(${env:ProgramFiles(x86)}){$paths+=Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe'}
    if($env:LOCALAPPDATA){$paths+=Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe'}
  }
  if($Browser -ne 'Chrome'){
    if(${env:ProgramFiles(x86)}){$paths+=Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'}
    if($env:ProgramFiles){$paths+=Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe'}
    if($env:LOCALAPPDATA){$paths+=Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\Application\msedge.exe'}
  }
  $exe=$paths|Where-Object{Test-Path -LiteralPath $_}|Select-Object -First 1
  if(!$exe){throw "Browser not found: $Browser. Change -Browser Chrome to -Browser Edge if needed."}

  # Enable per-monitor DPI awareness for accurate coordinate calculations when practical.
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class UsbCaptureSnapNative {
  [DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(IntPtr value);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc callback, IntPtr extra);
  public delegate bool EnumWindowsProc(IntPtr hwnd, IntPtr extra);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hwnd, StringBuilder str, int len);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hwnd);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int width, int height, uint flags);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd, int cmd);
  public static IntPtr FindTitle(string title){
    IntPtr found=IntPtr.Zero;
    EnumWindows((h,p)=>{if(!IsWindowVisible(h))return true;
      var b=new StringBuilder(512);GetWindowText(h,b,b.Capacity);
      if(b.ToString().Contains(title)){found=h;return false;}return true;},IntPtr.Zero);
    return found;
  }
}
'@
  try { [void][UsbCaptureSnapNative]::SetProcessDpiAwarenessContext([IntPtr](-4)) } catch { }
  Add-Type -AssemblyName System.Windows.Forms
  $screens=[System.Windows.Forms.Screen]::AllScreens
  if($MonitorIndex -ge 0){
    if($MonitorIndex -ge $screens.Count){throw "MonitorIndex out of range. Screen count: $($screens.Count). Indices start at 0."}
    $screen=$screens[$MonitorIndex]
  } else {
    $screen=$screens|Where-Object{$_.Bounds.Height -gt $_.Bounds.Width}|Select-Object -First 1
    if(!$screen){$screen=[System.Windows.Forms.Screen]::PrimaryScreen}
  }
  $area=$screen.WorkingArea
  # Leave the native caption/maximize buttons intact, so Windows 11 Snap Layouts work.
  # First-launch position: approximately the bottom third of the selected monitor.
  $w=[int]$area.Width
  $h=[Math]::Min([int]$area.Height,[Math]::Max(300,[int][Math]::Round($area.Height*$HeightPercent/100.0)))
  $x=[int]$area.Left
  $y=[int]($area.Bottom-$h)

  $port=18764
  $profile=Join-Path $env:LOCALAPPDATA 'USB_Capture_Snap_Profile'
  $siteRoot=Join-Path $env:LOCALAPPDATA 'USB_Capture_Web_Viewer_Host'
  if(!(Test-Path -LiteralPath $siteRoot)){New-Item -ItemType Directory -Force -Path $siteRoot | Out-Null}
  Copy-Item -LiteralPath $html -Destination (Join-Path $siteRoot 'USB_Capture_Web_Viewer.html') -Force
  $server=Join-Path $PSScriptRoot 'Serve_USB_Capture_Local.ps1'
  if(!(Test-Path -LiteralPath $server)){throw "Local server missing: $server"}
  $uri="http://127.0.0.1:$port/"
  function Test-CaptureServer {
    try {
      $req=[System.Net.HttpWebRequest][System.Net.WebRequest]::Create("${uri}__health")
      $req.Proxy=$null;$req.Timeout=700
      $resp=$req.GetResponse()
      try { $reader=[System.IO.StreamReader]::new($resp.GetResponseStream());return ($reader.ReadToEnd().Trim() -eq 'USB-CAPTURE-LOCALHOST-v1') }
      finally {$resp.Close()}
    }catch{return $false}
  }
  if(!(Test-CaptureServer)){
    $tcp=New-Object System.Net.Sockets.TcpClient
    try { $result=$tcp.BeginConnect('127.0.0.1',$port,$null,$null); if($result.AsyncWaitHandle.WaitOne(300)){ $tcp.EndConnect($result);throw "TCP $port already occupied" } }
    finally {$tcp.Close()}
    $args='-NoProfile -ExecutionPolicy Bypass -File "'+$server+'" -SiteRoot "'+$siteRoot+'" -Port '+$port
    $proc=Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -ArgumentList $args -WindowStyle Hidden -PassThru
    $ready=$false
    for($i=0;$i -lt 40;$i++){Start-Sleep -Milliseconds 150;if(Test-CaptureServer){$ready=$true;break};if($proc.HasExited){break}}
    if(!$ready){throw "Failed to start local-only server"}
  }
  $arguments="--no-first-run --no-default-browser-check --no-proxy-server --user-data-dir=`"$profile`" --app=`"$uri`""
  Write-Host "Local viewer: $uri" -ForegroundColor Cyan
  Write-Host "Browser: $exe" -ForegroundColor Cyan
  Write-Host "Screen: $($screen.DeviceName); Start window: ${w}x${h} at $x,$y" -ForegroundColor Cyan
  Start-Process -FilePath $exe -ArgumentList $arguments | Out-Null
  $handle=[IntPtr]::Zero
  for($i=0;$i -lt 80;$i++){
    Start-Sleep -Milliseconds 250
    $handle=[UsbCaptureSnapNative]::FindTitle('USB Capture Snap V1.6.2 RC1')
    if($handle -ne [IntPtr]::Zero){break}
  }
  if($handle -eq [IntPtr]::Zero){throw 'Browser opened but the capture viewer window was not found. Try closing previous capture viewer windows and run again.'}
  # SW_RESTORE=9; SWP_NOZORDER=4 | SWP_SHOWWINDOW=64 => 0x44.
  [void][UsbCaptureSnapNative]::ShowWindow($handle,9)
  if(![UsbCaptureSnapNative]::SetWindowPos($handle,[IntPtr]::Zero,$x,$y,$w,$h,0x44)){
    throw 'Could not position the window. Move it to the portrait monitor manually.'
  }
  Write-Host 'Ready: Native title bar, resize borders and Windows 11 Snap Layouts are enabled.' -ForegroundColor Green
  Write-Host 'Use Win+Z or hover over maximize button to choose native layout.'
  exit 0
} catch {
  Write-Host "Launch failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
