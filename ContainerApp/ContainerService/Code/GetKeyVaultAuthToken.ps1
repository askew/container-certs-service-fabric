param (
    [Parameter(Mandatory = $true)]
    [string] $keyVaultName,

    [Parameter(Mandatory = $true)]
    [string] $certName
)

Write-Output "ImportKeyVaultCert -keyVaultName $keyVaultName -certName $certName"
filter Get-RandomPfxFileName { Join-Path $env:Temp ([System.IO.Path]::ChangeExtension([System.IO.Path]::GetRandomFileName(), '.pfx')) }

# KeyVault API version
$kvApiVer = '2016-10-01'

# Get a KeyVault auth token using the Managed Service Identity
$kvauth = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' `
    -Method GET -Headers @{ Metadata = 'true' }


$kvauth | Add-Member -MemberType NoteProperty -Name 'keyVaultName' -Value $keyVaultName
$kvauth | Add-Member -MemberType NoteProperty -Name 'certName' -Value $certName

$kvauth | ConvertTo-Json -Depth 10 | Set-Content -Path '..\work\kvauth.json'
