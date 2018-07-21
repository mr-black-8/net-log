param(
  [Int32]$TestInterval = 3, #minutes
  [String]$LogPath = "C:\net-log"
)

$Command = '$ErrorActionPreference = ''Stop'';
$NetAdaptors = Get-NetAdapter;
$HasNetworkConnection = $false;
foreach ($Adaptor in $NetAdaptors) {
  if ($Adaptor.status -eq ''Up'') {
    $HasNetworkConnection = $true;
  }
}

If(!(Test-Path '+$LogPath+')) {
  New-Item -ItemType Directory -Path '+$LogPath+' -Force;
}

if ($HasNetworkConnection) {
  try {
    Test-Connection -Count 1 -ComputerName 8.8.8.8 | Out-Null;
  } catch {
    try {
      Test-Connection -Count 1 -ComputerName 1.1.1.1 | Out-Null;
    } catch {
      $Msg = (Get-Date).ToString() + '',1'';
      $Path = '''+$LogPath+'\''+ (Get-Date -UFormat %Y-%m) + ''.csv'';
      Out-File -FilePath $Path -InputObject $Msg -Append;
    }
  }
} else {
  $Msg = (Get-Date).ToString() + '',2'';
  $Path = '''+$LogPath+'\''+ (Get-Date -UFormat %Y-%m) + ''.csv'';
  Out-File -FilePath $Path -InputObject $Msg -Append;
}'

$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -command $Command";
$TaskTrigger = New-ScheduledTaskTrigger -Once -At(Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $TestInterval);
$TaskPrincipal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest;
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun;

if (Get-ScheduledTask -TaskName "Net-Log" -ErrorAction SilentlyContinue) {
  Set-ScheduledTask "Net-Log" -Action $TaskAction -Trigger $TaskTrigger;
} else {
  Register-ScheduledTask -Settings $TaskSettings -Principal $TaskPrincipal -Action $TaskAction -Trigger $TaskTrigger -TaskName "Net-Log" -Description "Checks for & logs internet outages";
}
