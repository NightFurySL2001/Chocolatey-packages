import-module au


function global:au_SearchReplace {
	@{
		"$($Latest.PackageName).nuspec" = @{
            "(\<dependency .+?`"nano-win`" version=)`"([^`"]+)`"" = "`$1`"[$($Latest.Version)]`""
        }
	}
}

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
	$version = $((choco search nano-win -s https://community.chocolatey.org/api/v2) | Where-Object {$_ -match "nano-win"}).split(' ') | Where-Object {$_ -match "\."}


	$Latest = @{ URL32 = $url32; URL64 = $url64; Version = $version }
	return $Latest
}

update -NoCheckChocoVersion -ChecksumFor none
