$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://cdist2.perforce.com/perforce/'

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumType\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
		}
	}
}

function global:au_GetLatest {
	Write-Output 'Check Folder'
	$version_folder = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object  {$_.href -match '^r\d+([.]\d+)?'} | ForEach-Object {($_.href -replace '[^.\d]', '')} | Sort-Object -Descending)
	$newversion='0.0'
	$version='0.0'
	foreach ($item in $version_folder) {
		try {
			$ver = $item.replace(',','.')
			$linktest = "https://cdist2.perforce.com/perforce/r$($ver)/doc/user/p4vnotes.txt"
			Invoke-WebRequest -Uri $linktest -OutFile "$env:TEMP\p4v.txt"
            $newversion = $($(Get-Content "$env:TEMP\p4v.txt" | Where-Object { $_ -match 'version'}).trim() | Where-Object { $_ -match '^Version'})[0].split(' ')[-1]
            if([version]$version -lt [version]$newversion)
			{
				$url64 = "https://cdist2.perforce.com/perforce/r$($ver)/bin.ntx64/p4vinst64.exe"

                $version = $newversion
			}
		}
		catch {
			Write-Verbose "V$($item) Not found"
		}
    }
	$same='no'

	# check if the sha is the same as the current
	$currentcheck = "$env:TEMP\p4vinst.exe"
	$currenttools = "./tools/chocolateyinstall.ps1"
	Invoke-WebRequest -UseBasicParsing -Uri $url32 -OutFile $currentcheck
	$return = Get-Content $currenttools | Where-Object {$_ -match $((Get-FileHash $currentcheck).hash.tolower )}
	if($return.Length -gt 1) {
		$version = "$version.$(Get-Date -Format "yyyyMMdd")"
	}

	$Latest = @{ URL32 = $url64; Version = $version }
	return $Latest
}

update -ChecksumFor 32