﻿$ErrorActionPreference = 'Stop';

$packageName      = $env:ChocolateyPackageName
$toolsDir         = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$file             = Join-Path $toolsDir '/p4vinst64.exe'
$checksum         = '57C9D23DB923572366CF1123C9BEB325CD4DA653CC32115D267E6B64E847AB12'
$checksumType     = 'sha256'

$packageArgs = @{
  packageName     = $packageName
  unzipLocation   = $toolsDir
  fileType        = 'EXE'
  file            = $file

  softwareName    = 'Helix Core*'

  validExitCodes= @(0, 3010, 1641)
  silentArgs   = '/s REMOVEAPPS=P4V,P4ADMIN,P4'
}

Install-ChocolateyPackage @packageArgs
