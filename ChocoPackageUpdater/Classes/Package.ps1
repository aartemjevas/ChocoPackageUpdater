Class Package {
    [string]$Path
    [string]$PackageName
    [string]$Version
    [string]$DownloadUrl32
    [string]$DownloadUrl64
    [string]$Filename32
    [string]$Filename64
    [string]$FileType
    [string]$Checksum32
    [string]$Checksum64
    hidden [string]$TmpFile32Path
    hidden [string]$TmpFile64Path
    [bool]$PackageCreated

    Package ([string]$Path){
        $updateScript = Join-Path $Path 'update.ps1'
        if (Test-Path $updateScript) {           
            $packageJson = ConvertFrom-Json -InputObject $(Get-Content "$Path\tools\package.json" | Out-String)

            Write-Verbose "Launching $updateScript"
            $update = &$updateScript
            $this.PackageName = $packageJson.Packagename
            $this.Version = $update.Version
            $this.DownloadUrl32 = $update.DownloadUrl32
            $this.DownloadUrl64 = $update.DownloadUrl64
            $this.Filename32 = $packageJson.Filename32
            $this.Filename64 = $packageJson.Filename64
            $this.Path = $Path
            $this.PackageCreated = $false

        } 
        else {
            Write-Verbose "This package does not have update script"
        }
        
    }
    [bool] NeedsUpdate() {
        if ([string]::IsNullOrEmpty($env:ChocoPackageSource)) {
            throw "Please set package source with Set-ChocoPackageSource command"
        }
        else {
            $feedPackage = choco list $this.PackageName --version $this.Version  --source $env:ChocoPackageSource |
                ConvertFrom-Csv -Header "Package", "Version" -Delimiter ' '
            if ($feedPackage | ? {$_.Package -eq $this.PackageName -and $_.Version -eq $this.Version}) {
                return $false
            }
            else {
                return $true
            }        
        }
    }
    [void] Update() {
        $tmpPackageLocation = "$env:TMP\$($this.PackageName).$($this.Version)"
        Write-Verbose "Temporary package location: $tmpPackageLocation"
        if (!(Test-Path $tmpPAckageLocation)) { 
            $null = mkdir $tmpPackageLocation 
        }
        Copy-Item $this.Path $tmpPackageLocation -Recurse -Force

        if ([string]::IsNullOrEmpty($this.DownloadUrl32) -and [string]::IsNullOrEmpty($this.DownloadUrl32)) {
            throw "No URLs were found"
        }
        else {
            if (-Not([string]::IsNullOrEmpty($this.DownloadUrl32)) -and -not([string]::IsNullOrEmpty($this.Filename32))) {
                $this.TmpFile32Path = "$tmpPackageLocation\$($this.Filename32)"
                Invoke-WebRequest -UseBasicParsing $this.DownloadUrl32 -OutFile $this.TmpFile32Path
                Write-Verbose "Saved to $($this.TmpFile32Path)" 
                $this.Checksum32 = Get-FileHash -Path $this.TmpFile32Path -Algorithm MD5 | Select-Object -ExpandProperty Hash
            }
            if (-Not([string]::IsNullOrEmpty($this.DownloadUrl64)) -and -not([string]::IsNullOrEmpty($this.Filename64))) {
                $this.TmpFile64Path = "$tmpPackageLocation\$($this.Filename64)"
                Invoke-WebRequest -UseBasicParsing $this.DownloadUrl64 -OutFile $this.TmpFile64Path
                Write-Verbose "Saved to $($this.TmpFile64Path)"
                $this.Checksum64 = Get-FileHash -Path $this.TmpFile64Path -Algorithm MD5 | Select-Object -ExpandProperty Hash
            } 
        }
        $this | Select  Packagename, 
                        Version, 
                        Filename32, 
                        Filename64,
                        Checksum32,
                        Checksum64,
                        DownloadURL32,
                        DownloadURL64 | 
                ConvertTo-Json | 
                Out-File "$tmpPackageLocation\$($this.PackageName)\tools\package.json"

        [xml]$nuspec = Get-Content "$tmpPackageLocation\$($this.PackageName)\$($this.PackageName).nuspec"
        $nuspec.package.metadata.version = $this.Version
        $nuspec.Save("$tmpPackageLocation\$($this.PackageName)\$($this.PackageName).nuspec")

        Push-Location "$tmpPackageLocation\$($this.PackageName)"
        &choco pack
        Pop-Location
        $nupkg = "$tmpPackageLocation\$($this.PackageName)\$($this.PackageName).$($this.Version).nupkg" 
        if (!(Test-Path $nupkg)) {
            throw "Failed to create package"
        }
        else {
            Write-Verbose "Package created"
            Copy-Item $nupkg $this.Path -Force
            $this.PackageCreated = $true
        }
        Write-Verbose "Removing $tmpPackageLocation"
        Remove-Item $tmpPackageLocation -Force -Recurse 
    
    }
}