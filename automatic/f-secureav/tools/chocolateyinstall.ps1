﻿$ErrorActionPreference = 'Stop'
$url32          = 'https://download.sp.f-secure.com/SE/Retail/installer/F-SecureNetworkInstaller-AV.exe'
$checksum32     = ''
$checksumType32 = ''

$packageArgs = @{
    url             = $url32
    fileType        = 'exe'
    softwareName    = $env:ChocolateyPackageName
    packageName     = $env:ChocolateyPackageName
    silentArgs      = '/s'
    checksum        = $checksum32
    checksumType    = $checksumType32
}

$OSIsServerVersion = if ([Int]3 -eq [Int](Get-CimInstance -Class Win32_OperatingSystem).ProductType) {$True} else {$False}
if($OSIsServerVersion) {
  Write-Warning "System not supported"
  exit 0
} else {
  Install-ChocolateyPackage @packageArgs
}
