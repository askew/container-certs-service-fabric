Param
(
    [String]
    $ApplicationPackagePath = ".\ContainerApp",

    [String]
    $ApplicationName = 'fabric:/ContainerApp',

    [String]
    $ImageStoreConnectionString = "fabric:ImageStore"
)

$ApplicationPackagePath = Join-Path $PSScriptRoot $ApplicationPackagePath
$packagePath = Split-Path -Path $ApplicationPackagePath -Leaf

[xml]$manifest = Get-Content (Join-Path $ApplicationPackagePath 'ApplicationManifest.xml')

Remove-ServiceFabricApplication -ApplicationName $ApplicationName -Force

Unregister-ServiceFabricApplicationType `
    -ApplicationTypeName $manifest.ApplicationManifest.ApplicationTypeName `
    -ApplicationTypeVersion $manifest.ApplicationManifest.ApplicationTypeVersion `
    -Force

Remove-ServiceFabricApplicationPackage `
    -ApplicationPackagePathInImageStore $packagePath `
    -ImageStoreConnectionString $ImageStoreConnectionString