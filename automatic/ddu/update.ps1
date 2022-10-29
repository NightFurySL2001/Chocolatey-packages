$ErrorActionPreference = 'Stop'
import-module au

$releases = "https://www.wagnardsoft.com/forums/viewforum.php?f=5"

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
			"(^[$]referer\s*=\s*)('.*')" = "`$1'$($Latest.Referer)'"
		}
	}
}

function global:au_BeforeUpdate {
	Import-Module VirusTotalAnalyzer -NoClobber -Force
	$vt = (Get-VirusScan -ApiKey $env:VT_APIKEY -Url $Latest.URL32).data.attributes.reputation
	if ( $vt -gt 5 ) {
	  Write-Error "Ignoring $($Latest.PackageName) package due to virus total results - $vt positives"
	  return 'ignore'
	}
}

function global:au_GetLatest {
	Add-Type -AssemblyName System.Web # To URLDecode
	$links = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_ -match 'Released'}).href
	if ($links -is [array]) { $links = $links[0] }
	$urlend = $(([System.Web.HttpUtility]::UrlDecode($links).replace('./','').replace('&amp;','&')))
	$release="https://www.wagnardsoft.com/forums/$urlend"
	$splited=$release.split('&')
	$referer="$($splited[0])&$($splited[1])"
	$url32=(((Invoke-WebRequest -Uri $release -UseBasicParsing).Links | Where-Object {$_ -match '.exe'}).href)

	$version=$url32.split('/')[-1].ToLower().split('v')[-1].replace('.exe','')
	#$version = Get-Version $url32
	if($version -eq "18.0.5.4") {
		$version = '18.0.5.2023082201'
	}

	$Latest = @{ URL32 = $url32; Referer = $referer; Version = $version }
	return $Latest
}


update -ChecksumFor 32 -NoCheckChocoVersion
