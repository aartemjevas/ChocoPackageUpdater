Function Get-RemoteFile {
    [CmdletBinding()]
    param([parameter(Mandatory=$true)]
          [string]$URL,
          [parameter(Mandatory=$true)]
          [string]$Destination,
          [parameter(Mandatory=$true)]
          [string]$Checksum)

    try {
        Invoke-WebRequest -UseBasicParsing $URL -OutFile $Destination -ErrorAction Stop
        $fileHash = Get-FileHash -Path $Destination -Algorithm MD5 | 
            Select-Object -ExpandProperty Hash

        if ($fileHash -eq $Checksum) {
            Write-Verbose "Hashes match"
            Write-Verbose $Destination
        }
        else {
            Remove-Item $Destination
            throw "Hashes does not match"
        }    
    } catch {
        throw $_.exception.message
    }
}