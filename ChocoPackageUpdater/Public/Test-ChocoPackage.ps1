Function Test-ChocoPackage {
    [CmdletBinding()]
    param([string]$Path)
    try {
        $package = Get-Content $Path\tools\package.json | ConvertFrom-Json -ErrorAction Stop
        Write-Verbose ('-'*60)
        Write-Verbose "TESTING $($package.Packagename) v$($package.Version)"
        Write-Verbose ('-'*60)
        $LastExitCode = 0
        $validExitCodes = @(0, 1605, 1614, 1641, 3010)
        Invoke-Expression "choco install $($package.Packagename) --version $($package.Version) --source $Path -yf" | Out-Host
        if ($validExitCodes -contains $LastExitCode) {
            $testRes = [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'success'; 
                                        'exitcode' = $LastExitCode}
        } 
        else {
            $testRes = [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'failed'; 
                                        'existcode' = $LastExitCode}
        }
        Write-Output $testRes
    } 
    catch {
        throw $_.exception.message
    }
}