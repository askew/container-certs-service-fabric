# KeyVault API version
$kvApiVer = '2016-10-01'

filter Get-RandomPfxFileName { Join-Path $env:Temp ([System.IO.Path]::ChangeExtension([System.IO.Path]::GetRandomFileName(), '.pfx')) }

$auth = Get-Content -Path "$env:Fabric_Folder_App_Work\kvauth.json" -Raw | ConvertFrom-Json

# UNIX filetime, seconds since January 1, 1970
$epoc = New-Object -TypeName datetime -ArgumentList @(1970,1,1,0,0,0,0,[DateTimeKind]::Utc)
$expireson = $epoc.AddSeconds($auth.expires_on)

if ($expireson -ge [DateTime]::UtcNow)
{
    Write-Error -Message "The MSI auth token has expired."
    Exit(1)
}

$authHdr = @{ Authorization = "Bearer $($auth.access_token)" }

# Get the versions of the certificate
$certVers = Invoke-RestMethod -UseBasicParsing `
    -Uri "https://$($auth.keyVaultName).vault.azure.net/certificates/$($auth.certName)/Versions?api-version=$($kvApiVer)" `
    -Method GET -Headers $authHdr

# Get the latest certificate version.
$certInfo = Invoke-RestMethod -UseBasicParsing `
    -Uri "$($certVers.value[0].id)?api-version=$($kvApiVer)" `
    -Method GET -Headers $authHdr

# Retrieve the secret value for the cert. This is the pfx.
$certSecret = Invoke-RestMethod -UseBasicParsing `
    -Uri "$($certInfo.sid)?api-version=$($kvApiVer)" `
    -Method GET -Headers $authHdr

# Write out the PFX data to a temporary file.
$pfxPath = Get-RandomPfxFileName

[Convert]::FromBase64String($certSecret.value) | Set-Content -Path $pfxPath -Encoding Byte

# Import the pfx into the machine cert store
$cert = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation 'Cert:\LocalMachine\My\'

# Delete the PFX file
Remove-Item -Path $pfxPath -Force

netsh http add sslcert ipport=0.0.0.0:443 certhash="$($cert.Thumbprint)" appid="$([Guid]::NewGuid().ToString('B'))"

C:\Windows\System32\inetsrv\appcmd.exe set site 'Default Web Site' /+"bindings.[protocol='https',bindingInformation='*:443:']"
