Function Get-ChocoPackage {
    [CmdletBinding()]
    param([string]$Path)

    try {
        $Package = [Package]::new($Path)
        Write-Output $Package
    } 
    catch {
        throw $_.exception.message
    }
}