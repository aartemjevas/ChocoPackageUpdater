<#
.DESCRIPTION
Saves software files used by package to desired location

.PARAMETER Path
Package location

.PARAMETER Destination
Path where you want to save files

.PARAMETER Force
Switch for files overwriting

.EXAMPLE
Save-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox -Destination c:\temp\packageFiles

------------------------------------------------------------
SAVING PACKAGE: firefox v51.0.1
------------------------------------------------------------
Saved to C:\temp\packageFiles\firefox\51.0.1\firefox64.exe
Saved to C:\temp\packageFiles\firefox\51.0.1\firefox64.exe

.NOTES
This function works only with customized chocolatey packages.

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Save-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true,
                     ValueFromPipeline=$True)]
          [string[]]$Path,
          [parameter(Mandatory=$true)]
          [string]$Destination,
          [switch]$Force)

    process {
        foreach ($PackagesPath in $Path) {
            try {
                $Package = Get-Content "$PackagesPath\tools\package.json" | 
                    ConvertFrom-Json -ErrorAction Stop
                $update = . "$PackagesPath\Update.ps1"
                Write-Host ('-'*60) -ForegroundColor Magenta
                Write-Host "SAVING PACKAGE: $($Package.Packagename) v$($update.Version)" -ForegroundColor Magenta
                Write-Host ('-'*60) -ForegroundColor Magenta

                $saveTo =  "$Destination\$($Package.Packagename)\$($update.Version)"
                if (!(Test-Path $saveTo)) {
                    $null = mkdir $saveTo
                }
            
                if (!([string]::IsNullOrEmpty($update.DownloadURL32))) {
                   if ((Test-Path "$saveTo\$($Package.Filename32)") -and (-not $Force)) {
                        Write-Host "File $saveTo\$($Package.Filename32) already exists" -ForegroundColor Yellow
                   }
                   else {
                       Invoke-WebRequest -UseBasicParsing $update.DownloadURL32 -OutFile "$saveTo\$($Package.Filename32)" 
                       Write-Host "Saved to $saveTo\$($Package.Filename64)"              
                   }

                }
                if (!([string]::IsNullOrEmpty($Package.DownloadURL64))) {
                   if ((Test-Path "$saveTo\$($Package.Filename64)") -and (-not $Force)) {
                        Write-Host "File $saveTo\$($Package.Filename64) already exists" -ForegroundColor Yellow
                   }
                   else {
                       Invoke-WebRequest -UseBasicParsing $update.DownloadURL64 -OutFile "$saveTo\$($Package.Filename64)"
                       Write-Host "Saved to $saveTo\$($Package.Filename64)"               
                   }
                }   
            } 
            catch {
                throw $_.exception.message
            }
        }    
    }

}