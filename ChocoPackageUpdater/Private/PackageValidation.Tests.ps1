[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$Path
)

Describe "Package validation" {
    Context "Directory|File" {
        It "$Path should exist" {
            Test-Path $Path | Should be $true
        }
        It "$Path\tools should exist" {
            Test-Path "$Path\tools" | Should be $true
        }
        It "$Path\update.ps1 should exist" {
            Test-Path "$Path\update.ps1" | Should be $true
        }
        It "$Path\tools\package.json should exist" {
            Test-Path "$Path\tools\package.json"
        }
        It "$Path\tools\chocolateyinstall.ps1 should exist" {
            Test-Path "$Path\tools\chocolateyinstall.ps1" | Should be $true
        }
        It "$Path\*.nuspec should exist" {
            Test-Path "$Path\*.nuspec" | Should be $true
        } 
    }
    Context "Package.json" {
        It "Should be valid Json file with mandatory properties filled in" {
            $package = ConvertFrom-Json -InputObject (Get-Content "$Path\tools\package.json" | Out-String)
            if ([string]::IsNullOrEmpty($package.PackageName) -or 
                [string]::IsNullOrEmpty($package.Filename32) -or 
                [string]::IsNullOrEmpty($package.Filename64)) {
                $res = $true
            } else { $res = $false }
            $res | SHould be $false 
        } 
    }
    Context "update.ps1" {
        $update = . "$Path\update.ps1"
        It "Should return PSCustomObject" {
            $update.GetType() | Select-Object -ExpandProperty name | 
                Should be "PSCustomObject"
        }
        It "Version propert should not be empty" {
            [string]::IsNullOrEmpty($update.Version) | Should be $false
        }
        It "DownloadUrl32 and DownloadUrl64 should not be empty" {
            ([string]::IsNullOrEmpty($update.DownloadUrl32) -and [string]::IsNullOrEmpty($update.DownloadUrl64)) |
                Should be $false
        }

    }
}