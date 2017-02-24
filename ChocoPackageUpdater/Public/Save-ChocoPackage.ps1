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
                $Package = Get-Content "$($PackagesPath.fullname)\tools\package.json" | 
                    ConvertFrom-Json -ErrorAction Stop

                Write-Verbose ('-'*60)
                Write-Verbose "PACKAGE: $($Package.Packagename) v$($Package.Version)"
                Write-Verbose ('-'*60)

                $saveTo =  "$Destination\$($Package.Packagename)\$($Package.Version)"
                if (!(Test-Path $saveTo)) {
                    $null = mkdir $saveTo
                }
            
                if (!([string]::IsNullOrEmpty($Package.DownloadURL32))) {
                   if ((Test-Path "$saveTo\$($Package.Filename32)") -and (-not $Force)) {
                        Write-Verbose "File $saveTo\$($Package.Filename32) already exists"
                   }
                   else {
                       Get-RemoteFile -URL $Package.DownloadURL32 -Destination "$saveTo\$($Package.Filename32)" -Checksum $Package.Checksum32               
                   }

                }
                if (!([string]::IsNullOrEmpty($Package.DownloadURL64))) {
                   if ((Test-Path "$saveTo\$($Package.Filename64)") -and (-not $Force)) {
                        Write-Verbose "File $saveTo\$($Package.Filename64) already exists"
                   }
                   else {
                       Get-RemoteFile -URL $Package.DownloadURL64 -Destination "$saveTo\$($Package.Filename64)" -Checksum $Package.Checksum64               
                   }
                }   
            } 
            catch {
                throw $_.exception.message
            }
        }    
    }

}