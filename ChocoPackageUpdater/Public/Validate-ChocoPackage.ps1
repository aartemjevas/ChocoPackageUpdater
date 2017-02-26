<#
.DESCRIPTION
Validates Chocolatey package with Pester tests

.PARAMETER Path
Package location

.EXAMPLE
Validate-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox

.NOTES
This function works only with customized chocolatey packages.

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Validate-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true)]
          [string]$Path)

    $testsPath = Join-Path ((Get-Module ChocoPackageUpdater | 
                                Select-Object -ExpandProperty Path | 
                                Get-Item).DirectoryName) "Private\PackageValidation.Tests.ps1"
    $testRes = Invoke-Pester -Script @{Path = $testsPath; Parameters = @{Path = "$Path"}}  -PassThru -Quiet
    if ($testRes.FailedCount -ne 0) {
        Write-Output $false
    } 
    else {
        Write-Output $true
    }
}