# PowerShell One-Liners for System Management

## Shutdown Computer
```powershell
Stop-Computer -Force
```
This command immediately shuts down the computer without prompting for confirmation.

## Restart Computer  
```powershell
Restart-Computer -Force
```
This command immediately restarts the computer without prompting for confirmation.

## Cancel Pending Restart
```powershell
shutdown /a
```
This command cancels a pending system shutdown or restart operation.

## Additional Useful One-Liners

### Get Current System Time
```powershell
Get-Date
```

### List All Running Processes
```powershell
Get-Process
```

### Get System Information
```powershell
Get-ComputerInfo
```

### Check Disk Space
```powershell
Get-PSDrive -PSProvider FileSystem
```

### Restart Windows Explorer
```powershell
Stop-Process -Name explorer -Force; Start-Process explorer
```

### Clear DNS Cache
```powershell
Clear-DnsClientCache
```

### Get Network Configuration
```powershell
Get-NetIPConfiguration
```

### List Installed Programs
```powershell
Get-WmiObject -Class Win32_Product | Select-Object Name, Version
```