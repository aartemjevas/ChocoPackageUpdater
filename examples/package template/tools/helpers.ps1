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
