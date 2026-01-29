#Script qui affiche les infos système

Write-Host -ForegroundColor Green "Informations de la machine"

$os = Get-CimInstance Win32_OperatingSystem

Write-Host -ForegroundColor DarkBlue "Nom de la machine : $env:COMPUTERNAME"

Write-Host -ForegroundColor DarkCyan "Nom de la machine : $env:USERNAME"

Write-Host -ForegroundColor Blue "Nous sommes le : $(Get-Date)"

Write-Host -ForegroundColor Green "Processeur :" | wmic cpu get Manufacturer,Name,SocketDesignation /value

Write-Host -ForegroundColor Magenta "Mémoire totale du système :" | wmic ComputerSystem get TotalPhysicalMemory

Write-Host -ForegroundColor Yellow "Système d'exploitation :" | wmic os get Name

Pause