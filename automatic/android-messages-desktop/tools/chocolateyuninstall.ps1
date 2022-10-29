﻿$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName   = 'android-messages-desktop'
  softwareName  = 'Android Messages*'
  fileType      = 'EXE'
  validExitCodes= @(0, 3010, 1605, 1614, 1641)
  silentArgs   = '/S'
  file = "$env:LOCALAPPDATA\Programs\android-messages-desktop\Uninstall Android Messages.exe"
}

$uninstalled = $false

[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % {
    Uninstall-ChocolateyPackage @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}