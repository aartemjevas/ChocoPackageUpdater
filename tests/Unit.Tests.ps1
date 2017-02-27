$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force



Describe "Get-ChocoPackage" {
    It "Should throw" {
        {Get-ChocoPackage -Path 'c:\Does\not\exist'} | Should Throw
    }
    It "Path parameter should be mandatory" {
        (Get-Command Get-ChocoPackage).Parameters.Path.Attributes.Mandatory |
            Should Be $true
    }
    It "Output type should be [Package]" {
        (Get-Command Get-ChocoPackage).OutputType.Name | Should be "Package"
    }
}
Describe "New-ChocoPackage" {
    It "Path parameter should be mandatory" {
        (Get-Command New-ChocoPackage).Parameters.Path.Attributes.Mandatory |
            Should Be $true
    }
    It "Name parameter should be mandatory" {
        (Get-Command New-ChocoPackage).Parameters.Name.Attributes.Mandatory |
            Should Be $true
    }
    It "Output type should be [Void]" {
        (Get-Command New-ChocoPackage).OutputType.Name | Should be "Void"
    }
}
Describe "Publish-ChocoPackage" {

}
Describe "Save-ChocoPackage" {
    It "Path parameter should be mandatory" {
        (Get-Command Save-ChocoPackage).Parameters.Path.Attributes.Mandatory |
            Should Be $true
    }
    It "Destination parameter should be mandatory" {
        (Get-Command Save-ChocoPackage).Parameters.Destination.Attributes.Mandatory |
            Should Be $true
    }
}
Describe "Set-ChocoPackageSource" {

}
Describe "Test-ChocoPackage" {
    It "Path parameter should be mandatory" {
        (Get-Command Test-ChocoPackage).Parameters.Path.Attributes.Mandatory |
            Should Be $true
    }
}
Describe "Test-ChocoPackageContent" {

}
