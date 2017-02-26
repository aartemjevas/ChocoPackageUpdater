<#
.DESCRIPTION
Creates package object from your given package path

.PARAMETER Path
Package location

.EXAMPLE
Get-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox

Path           : D:\GitHub\chocofeed\packages\firefox
PackageName    : firefox
Version        : 51.0.1
DownloadUrl32  : https://download.mozilla.org/?product=firefox-51.0.1-SSL&amp;os=win&amp;lang=en-US
DownloadUrl64  : https://download.mozilla.org/?product=firefox-51.0.1-SSL&amp;os=win64&amp;lang=en-US
Filename32     : firefox32.exe
Filename64     : firefox64.exe
Checksum32     : 
Checksum64     : 
PackageCreated : False

.NOTES
This function works only with customized chocolatey packages.

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Get-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true,
                     ValueFromPipeline=$True)]
          [String[]]$Path)
    
    process {
        foreach ($p in $Path) {
            try {
                if (Test-Path $p) {
                    $Package = [Package]::new($p)
                    Write-Output $Package                
                } 
                else {
                    throw "Path $p does not exist"
                }

            } 
            catch {
                throw $_.exception.message
            }        
        }
    }
}