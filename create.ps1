param(
  [Int32]$TestInterval = 30,
  [String]$LogPath = "$home\net-log"
)

$Command = '$ErrorActionPreference = "Stop";
  try {
    Test-Connection -Count 1 -ComputerName 8.8.8.8 | Out-Null;
  } catch {
    If(!(test-path $LogPath)) {
      New-Item -ItemType Directory -Path $LogPath -Force;
    }

    $Msg = "$((Get-Date).ToString()),1`n";
    $LogPath = "$LogPath\$(Get-Date -UFormat %Y-%m).csv";
    Out-File -FilePath $LogPath -InputObject $Msg -Append;
  }
}'

$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -command $Command"
$TaskTrigger = New-ScheduledTaskTrigger -RepititionInterval "${$TestInterval}s"

$ExistingTask = Get-ScheduledTask -TaskName "Net-Log"
if ($ExistingTask -ne $null) {
  Set-ScheduledTask "Net-Log" -Action $TaskAction -Trigger $TaskTrigger
} else {
  Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -TaskName "Net-Log" -Description "Checks for & logs internet outages"
}
