<#
.SYNOPSIS
    Runs pathping against a target host and saves the output to a timestamped log file.

.DESCRIPTION
    Captures pathping diagnostic output for later analysis. Useful when investigating
    intermittent network drops, where multiple captures over time are needed to
    identify the failing hop or link.

    The script writes a header block (target, query count, hostname, start time)
    to the log before running pathping, then appends pathping's output. The
    operator sees output in real time and the log captures everything.

.PARAMETER Target
    Destination host or IP address to test against. Defaults to 8.8.8.8.

.PARAMETER QueryCount
    Number of queries pathping sends per hop. Higher values produce more reliable
    loss statistics for intermittent issues, at the cost of longer run time.
    Defaults to 100, which matches pathping's native default. Lower values
    (e.g. 30) finish faster but make percentage figures noisier.

.PARAMETER OutputPath
    Directory where log files will be written. Created if it does not exist.
    Defaults to .\sample-output (relative to the script's working directory).

.EXAMPLE
    .\Capture-Pathping.ps1
    Captures pathping output against 8.8.8.8 with 100 queries per hop.

.EXAMPLE
    .\Capture-Pathping.ps1 -Target 1.1.1.1 -QueryCount 50 -OutputPath C:\logs
    Captures pathping output against 1.1.1.1 with 50 queries per hop, writing to C:\logs.

.NOTES
    Output filename format: pathping_<target>_<yyyy-MM-dd_HHmmss>.txt
    Tested on Windows PowerShell 5.1 and PowerShell 7.x.
#>

[CmdletBinding()]
param(
    [string]$Target = "8.8.8.8",
    [int]$QueryCount = 100,
    [string]$OutputPath = ".\sample-output"
)

# Ensure the output directory exists
if (-not (Test-Path -Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Build a clean timestamp and a filename-safe target name
$timestamp  = Get-Date -Format "yyyy-MM-dd_HHmmss"
$safeTarget = $Target -replace '[^a-zA-Z0-9.-]', '_'
$logFile    = Join-Path -Path $OutputPath -ChildPath "pathping_${safeTarget}_${timestamp}.txt"

# Header block so each log is self-describing
$header = @"
==========================================================
Pathping capture
Target:      $Target
Query count: $QueryCount
Started:     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')
Hostname:    $env:COMPUTERNAME
==========================================================
"@

$header | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "Running pathping against $Target with $QueryCount queries per hop." -ForegroundColor Cyan
Write-Host "This may take several minutes depending on hop count." -ForegroundColor Cyan
Write-Host "Output will be written to: $logFile`n" -ForegroundColor Cyan

# Run pathping; Tee-Object shows output live AND appends to the log
pathping $Target -q $QueryCount | Tee-Object -FilePath $logFile -Append

Write-Host "`nCapture complete." -ForegroundColor Green
Write-Host "Log saved: $logFile" -ForegroundColor Green
