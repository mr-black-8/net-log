### Net-Log

PowerShell script that creates a Scheduled Task to periodically check internet connectivity downtime, and log to a file.
Log files will be .csv for easy visualisation, with a new file created each month.

Optional Parameters:
`-TestInterval <Int32>`: Time in seconds between connection check
`-LogPath <String>`: Path to directory where log files will be saved

Example Usage:
```ps
PS C:\> .\create.ps1 -TestInterval 300 -LogPath "C:\logs\net-log"
```
