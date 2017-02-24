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