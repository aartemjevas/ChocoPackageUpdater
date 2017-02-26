<#
.DESCRIPTION
Creates new Chocolatey package

.PARAMETER Name
Package name

.PARAMETER Path
Package location

.EXAMPLE
New-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function New-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true)]
          [string]$Name,
          [parameter(Mandatory=$true)]
          [string]$Path)

    $installTemplate = @'
$ErrorActionPreference = 'Stop'
try {
    $toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    . $toolsDir\helpers.ps1
    $Package = Get-Content "$toolsDir\Package.json" | Out-String | ConvertFrom-Json 
    $url = Get-URL -Arch 32
    $url64 = Get-URL -Arch 64

    $packageArgs = @{
      packageName   = $Package.Packagename
      fileType      = ''
      url           = $url
      url64bit      = $url64
      softwareName  = ''
      checksum      = $Package.Checksum32
      checksumType  = 'md5' 
      checksum64    = $Package.Checksum64
      checksumType64= 'md5' 
      silentArgs    = ""
      validExitCodes= @(0, 3010, 1641)
    }

    Install-ChocolateyPackage @packageArgs

} 

catch {
    throw $_.expression.message
}
'@
    $helperTemplate = @'
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
'@
    $updateTemplate = @'
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
'@
    try {
        if (Test-Path "$Path\$Name") {
            throw "$Path\$Name already exists"
        } 
        else {
            if (!(Test-Path $Path)) { $null = mkdir $Path }
            Push-Location $Path
            $null = choco new $Name
            [pscustomobject]@{'PackageName' = $Name;
                              'Filename32' = '';
                              'Filename64' = ''} | 
                              ConvertTo-Json | 
                              Out-File "$Path\$Name\tools\package.json" -ErrorAction Stop
            $installTemplate | Out-File "$Path\$Name\tools\chocolateyinstall.ps1" -Force -ErrorAction Stop
            $helperTemplate | Out-File "$Path\$Name\tools\helpers.ps1" -ErrorAction Stop
            $updateTemplate | Out-File "$Path\$Name\update.ps1" -ErrorAction Stop
        }
    } 
    catch {
        throw $_.exception.message
    }
}