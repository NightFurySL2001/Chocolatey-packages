$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://sourceforge.net/projects/tigervnc/files/stable'
$options =
@{
  Headers = @{
    UserAgent = 'Wget';
  }
}

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url32\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum32\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 		= "`$1'$($Latest.ChecksumType32)'"
			"(^[$]url64\s*=\s*)('.*')"      		= "`$1'$($Latest.URL64)'"
			"(^[$]checksum64\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum64)'"
		}
	}
}

function global:au_BeforeUpdate {
	$file32 = Join-Path $env:TEMP "tigervnc.exe"
	$file64 = Join-Path $env:TEMP "tigervnc64.exe"

	$cli = New-Object System.Net.WebClient;
    $cli.Headers['User-Agent'] = 'Wget';
    $cli.DownloadFile($Latest.URL32 , $file32)
	$cli.DownloadFile($Latest.URL64, $file64)

	$Latest.ChecksumType32 = "SHA256"
	$Latest.ChecksumType64 = "SHA256"
	$Latest.Checksum32 = (Get-FileHash -Path $file32 -Algorithm $Latest.ChecksumType32).Hash
	$Latest.Checksum64 = (Get-FileHash -Path $file64 -Algorithm $Latest.ChecksumType32).Hash
}

  function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
	$version = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_.href -match "[0-9].[0-9]"} | Where-Object {$_.href -notmatch 'css'}).href[0].split('/')[-2]
	$url32 = "https://sourceforge.net/projects/tigervnc/files/stable/$version/tigervnc-$version.exe/download"
	$url64 = "https://sourceforge.net/projects/tigervnc/files/stable/$version/tigervnc64-$version.exe/download"

	$Latest = @{ URL32 = $url32; URL64 = $url64; Version = $version; Options = $options }
	return $Latest
}

update -NoCheckUrl -ChecksumFor none