<#
.DESCRIPTION
Pushes nupkg package to repository. Source and ApiKey must be set first with Set-ChocoPackageSource command

.PARAMETER Path
Package location

.EXAMPLE
Push-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox\firefox.51.0.1.nupkg

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Publish-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true)]
          [ValidateScript({(get-item $_).name -like "*.nupkg"})]
          [string]$Path)
    try {
        if ([string]::IsNullOrEmpty($env:ChocoPackageSource) -or [string]::IsNullOrEmpty($env:ChocoPackageSourceApiKey)) {
            throw "Source or Api key was not set. Please run Set-ChocoPackageSource command first"
        }
        else {
            &choco push $Path --source $env:ChocoPackageSource --apikey $env:ChocoPackageSourceApiKey
        }    
    } 
    catch {
        throw $_.exception.message
    }
}