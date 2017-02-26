$ErrorActionPreference = 'Stop'
try {
    $toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    . $toolsDir\helpers.ps1
    $Package = Get-Content "$toolsDir\Package.json" | Out-String | ConvertFrom-Json 
    $url = Get-URL -Arch 32
    $url64 = Get-URL -Arch 64

    $packageArgs = @{
      packageName   = $Package.Packagename
      fileType      = ''
      url           = $url
      url64bit      = $url64
      softwareName  = ''
      checksum      = $Package.Checksum32
      checksumType  = 'md5' 
      checksum64    = $Package.Checksum64
      checksumType64= 'md5' 
      silentArgs    = ""
      validExitCodes= @(0, 3010, 1641)
    }

    Install-ChocolateyPackage @packageArgs

} 

catch {
    throw $_.expression.message
}

