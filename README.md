# Chocolatey Package Updater
## Goals
This project was created to achieve these goals:
* Spend as less time as possible on package maintenance.
* Have control over packages.
* Ability to use alternative software sources. 
If computer accessing repository is in internal network - use internal software source. 
If external - use default source.
* Ability to test packages in external CI without embeding software files inside the package.

## Difference from default Chocolatey package
### Firefox package content
```
Package
│   firefox.nuspec
│   update.ps1
│
└───tools
        chocolateybeforemodify.ps1
        chocolateyinstall.ps1
        chocolateyuninstall.ps1
        helpers.ps1
        package.json
```
**update.ps1**  
Technique is borowed from [AU module](https://github.com/majkinetor/au)
This script outputs a PSCustomObject containing Version, DownloadURL32 and Download64 properties.  
Firefox update.ps1 example
```ps
$releases = 'https://www.mozilla.org/en-US/firefox/all/?q=English%20(US)'
$download_page = Invoke-WebRequest -Uri $releases 
$url32 = $download_page.links | Where-object title -eq 'Download for Windows in English (US)' | Select-object -expand href
$url64 = $download_page.links | Where-object title -eq 'Download for Windows 64-bit in English (US)' | Select-object -expand href
[string]$version = ($url32 -split '-')[1]

return [PScustomObject]@{ 'Version' = $version; 
                    'DownloadUrl32' = $url32;
                    'DownloadUrl64' = $url64 }
```
**chocolateyinstall.ps1**  
Install script gets URLs with Get-URL function defined in helpers.ps1.   
Packagename and Checksum properties are listed in package.json.
Firefox package example
```ps
$ErrorActionPreference = 'Stop'
try {
    $toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    . $toolsDir\helpers.ps1
    $Package = Get-Content "$toolsDir\Package.json" | Out-String | ConvertFrom-Json 
    $url = Get-URL -Arch 32
    $url64 = Get-URL -Arch 64
    $packageArgs = @{
      packageName   = $Package.Packagename
      fileType      = 'exe'
      url           = $url
      url64bit      = $url64
      softwareName  = 'Mozilla Firefox*'
      checksum      = $Package.Checksum32
      checksumType  = 'md5' 
      checksum64    = $Package.Checksum64
      checksumType64= 'md5' 
      silentArgs    = "-ms"
      validExitCodes= @(0, 3010, 1641)
    }
    Install-ChocolateyPackage @packageArgs
} 
catch {
    throw $_.expression.message
}
```
**package.json**  
Since you can not add additional tags to nuspec file, additional settings file was created.  
```json
{
    "Packagename": "firefox",
    "Filename32": "firefox32.exe",
    "Filename64": "firefox64.exe"
}
```
These three properties are mandatory and they will not change depending on version.  
During update process, this file gets additional version related properties.  
Firefox v51.0.1 example
```json
{
    "Packagename": "firefox",
    "SoftwareName": "Mozilla Firefox*",
    "Filename32": "firefox32.exe",
    "Filename64": "firefox64.exe",
    "Version": "51.0.1",
    "Checksum32": "95D7C988D4C768C2D8F70A26334F0C5E",
    "Checksum64": "B7531D3FDBAC3B5909248495D149E44D",
    "DownloadURL32": "https://download.mozilla.org/?product=firefox-51.0.1-SSL&amp;os=win&amp;lang=en-US",
    "DownloadURL64": "https://download.mozilla.org/?product=firefox-51.0.1-SSL&amp;os=win64&amp;lang=en-US"
}
```
**helpers.ps1**  
This script determines which URL to use - internal or external (default).
It order to return internal URL, you must have a DNS record chocolateycdn.local pointing to
a web server which hosts software files.  
For example, if you want to download Firefox v51.0.1 32bit install, URL http://chocolateycdn.local/files/firefox/51.0.1/firefox32.exe must be valid.

```ps
Function Test-URL {
    [CmdletBinding()]
    param([string]$URL
    )
     $paramHash = @{
     UseBasicParsing = $True
     DisableKeepAlive = $True
     Uri = $URL
     Method = 'Head'
     ErrorAction = 'stop'
     TimeoutSec = 5
    }
    try {
        $test = Invoke-WebRequest @paramHash
        if ($test.statuscode -ne 200) {
            Write-Output $false
        }
        else {
            Write-Output $True
        }
    } 
    catch {
        Write-Output $false
    }
}
Function Get-URL {
    [CmdletBinding()]
    param([ValidateSet("32","64")]
          [string]$Arch
    )
    switch ($Arch) {
        "32" {
            $url = "http://chocolateycdn.local/files/$($Package.Packagename)/$($Package.Version)/$($Package.Filename32)"
            Write-Output $url
            if (!(Test-URL -URL $url)) {
                $url = $Package.DownloadURL32
            }
        }
        "64" {
            $url = "http://chocolateycdn.local/files/$($Package.Packagename)/$($Package.Version)/$($Package.Filename64)"
            if (!(Test-URL -URL $url)) {
                $url = $Package.DownloadURL64
            }   
        }
    }
    Write-Output $url   
}
```

## Installation
You can find this module in Powershell Gallery
```ps
Install-module ChocoPackageUpdater
```

## Example
```ps
$ErrorActionPreference = 'stop'
Import-Module ChocoPackageUpdater
try {
    #Repository URL and APIkey where you want to upload packages
    Set-ChocoPackageSource -Source 'https://www.myget.org/somefeed/api/v2' -ApiKey 'aaaaa-bbbbb-ccccc'

    #Get all packages
    $packages = @()
    foreach ($packagePath in Get-ChildItem -Path .\Packages) {
        $packages += Get-ChocoPackage -Path $packagePath.fullname
    }

    #Check if package needs update. If yes - update it and test it
    $testRes = @()
    foreach ($package in $packages) { 
        if ($package.needsupdate()) {
            $package.Update()
            $testRes += Test-ChocoPackage -Path $package.Path
        }
    }

    <#
        Test-ChocoPackage returns
        [pscustomobject]@{  'Packagename'= $package_name;
                            'Version' = $package_version;
                            'Status' = 'success|failed'; 
                            'Exitcode' = $LastExitCode;
                            'Nupkg' = $nu.FullName}
        so you can filter out successfull packages and publish them to repository.
    #> 
    foreach ($sPackage in ($testRes | Where-Object {$_.status -eq 'success'})) {
        Publish-ChocoPackage -Path $sPackage.nupkg
    }

} 
catch {
    throw $_.exception.message
}



```
