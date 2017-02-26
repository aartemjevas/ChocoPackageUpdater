<#
.DESCRIPTION
Tests chocolatey package and returns result. Nupkg file must exist in provided location.

.PARAMETER Path
Package location

.EXAMPLE
Test-ChocoPackage -Path D:\GitHub\chocofeed\packages\firefox

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Test-ChocoPackage {
    [CmdletBinding()]
    param([parameter(Mandatory=$true)]
          [string]$Path)
    try {
        if (Test-Path "$Path\*.nupkg") {
            $nu = Get-Item "$Path\*.nupkg"
            $package_name    = $Nu.Name -replace '(\.\d+)+(-[^-]+)?\.nupkg$'
            $package_version = ($Nu.BaseName -replace $package_name).Substring(1)
        
            Write-Host ('-'*60) -ForegroundColor Magenta
            Write-Host "TESTING PACKAGE: $package_name v$package_version" -ForegroundColor Magenta
            Write-Host ('-'*60) -ForegroundColor Magenta
        
            $LastExitCode = 0
            $validExitCodes = @(0, 1605, 1614, 1641, 3010)
            #Invoke-Expression "choco install $package_name --version $package_version --source $Path -yf" | Out-Host
            choco install -y -r $package_name --version $package_version --source "$Path" --force | Out-Host
            $lo = choco list -lo | ConvertFrom-Csv -Header "Package", "Version" -Delimiter ' '
            if ($validExitCodes -contains $LastExitCode -and ($lo | ? {$_.package -eq $package_name -and $_.Version -eq $package_version})) {
                $testRes = [pscustomobject]@{'Packagename'= $package_name;
                                             'Version' = $package_version;
                                             'Status' = 'success'; 
                                             'Exitcode' = $LastExitCode}
            } 
            else {
                $testRes = [pscustomobject]@{'Packagename'= $package_name;
                                             'Version' = $package_version
                                             'Status' = 'failed'; 
                                             'Exitcode' = $LastExitCode}
            }
            Write-Output $testRes        
        }
        else {
            Write-Verbose "nupkg file was not found in $Path"
        }

    } 
    catch {
        throw $_.exception.message
    }
}