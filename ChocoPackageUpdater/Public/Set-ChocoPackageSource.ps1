<#
.DESCRIPTION
Sets repository source and ApiKey.

.PARAMETER Source
Repository URL

.PARAMETER ApiKey
Repository ApiKey

.EXAMPLE
Set-ChocoPackageSource -Source 'https://www.myget.org/F/chocofeed/api/v2' -ApiKey 'ccccccc-aaaa-uuu-wer-bbbbbbbbb'

.LINK
https://github.com/aartemjevas/ChocoPackageUpdater

#>
Function Set-ChocoPackageSource {
    [CmdletBinding()]
    [OutputType([void])] 
    param([parameter(Mandatory=$true)]
          [string]$Source,
          [parameter(Mandatory=$true)]
          [string]$ApiKey)

     $paramHash = @{
     UseBasicParsing = $True
     DisableKeepAlive = $True
     Uri = $Source
     Method = 'Head'
     ErrorAction = 'stop'
     TimeoutSec = 5
    }
    try {
        $test = Invoke-WebRequest @paramHash
        if ($test.statuscode -ne 200) {
            throw "Failed to access $Source"
        }
        else {
            $env:ChocoPackageSource = $Source
            $env:ChocoPackageSourceApiKey = $ApiKey
        }
    } 
    catch {
        throw $_.exception.message
    }
}