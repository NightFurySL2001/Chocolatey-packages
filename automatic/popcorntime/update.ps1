$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://api.github.com/repos/popcorn-official/popcorn-desktop/releases/latest'
$Owner = "popcorn-official"
$repo = "popcorn-desktop"

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(^[$]url\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
            "(^[$]checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
            "(^[$]checksumType\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType32)'"
            "(^[$]url64\s*=\s*)('.*')"          = "`$1'$($Latest.URL64)'"
            "(^[$]checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
            "(^[$]checksumType64\s*=\s*)('.*')" = "`$1'$($Latest.ChecksumType64)'"
        }
    }
}

function global:au_GetLatest {
    $tags = Get-GitHubRelease -OwnerName $Owner -RepositoryName $repo -Latest
	$urls = $tags.assets.browser_download_url | Where-Object {$_ -match "-Setup.exe$"} | Where-Object {$_ -match ".exe$"}
    $url32 = $urls | Where-Object {$_ -match 'win32'}
    $url64 = $urls | Where-Object {$_ -match 'win64'}
	$version = $url32 -split 'v|/' | select-object -Last 1 -Skip 1
    if($tags.tag_name -match $version) {
        if($tags.prerelease -match "true") {
            $date = $tags.published_at.ToString("yyyyMMdd")
            $version = "$version-pre$($date)"
        }
    }
    if($version -eq '0.4.6') {
        $version='0.4.6.20220205'
    }

    return @{ URL32 = $url32; URL64 = $url64; Version = $version }
}

update -NoCheckChocoVersion