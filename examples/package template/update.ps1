<#

Example how to check firefox version

$releases = 'https://www.mozilla.org/en-US/firefox/all/?q=English%20(US)'
$download_page = Invoke-WebRequest -Uri $releases 
$url32 = $download_page.links | Where-object title -eq 'Download for Windows in English (US)' | Select-object -expand href
$url64 = $download_page.links | Where-object title -eq 'Download for Windows 64-bit in English (US)' | Select-object -expand href
[string]$version = ($url32 -split '-')[1]
#>

return [PScustomObject]@{ 'Version' = $version; 
                    'DownloadUrl32' = $url32;
                    'DownloadUrl64' = $url64 }


