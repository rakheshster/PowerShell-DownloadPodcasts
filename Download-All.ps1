$myPath = $MyInvocation.MyCommand.Path
$myFolder = Split-Path -Parent $myPath

Get-ChildItem -Path $myFolder -Filter "Get-*.ps1" | ForEach-Object {
    Invoke-Expression $_
}