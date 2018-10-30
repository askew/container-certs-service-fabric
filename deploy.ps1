Param
(
    [String]
    $ApplicationPackagePath = ".\ContainerApp",

    [String]
    $ApplicationName = 'fabric:/ContainerApp',

    [String]
    $ImageStoreConnectionString = "fabric:ImageStore"
)

[xml]$manifest = Get-Content (Join-Path $ApplicationPackagePath 'ApplicationManifest.xml')

$ApplicationPackagePath = Join-Path $PSScriptRoot $ApplicationPackagePath
$packagePath = Split-Path -Path $ApplicationPackagePath -Leaf

Copy-ServiceFabricApplicationPackage `
    -ApplicationPackagePath $ApplicationPackagePath `
    -ImageStoreConnectionString $ImageStoreConnectionString

Register-ServiceFabricApplicationType -ApplicationPathInImageStore $packagePath

New-ServiceFabricApplication `
    -ApplicationName $ApplicationName `
    -ApplicationTypeName $manifest.ApplicationManifest.ApplicationTypeName `
    -ApplicationTypeVersion $manifest.ApplicationManifest.ApplicationTypeVersion