
param([switch]$Elevated, [string]$rootPath)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated -eq $false) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition)), ((Get-Location).Path)
    }

    exit
}

cd $rootPath
cd httpsca

$serverCertificate = ".\service_certificate.pem"

if(Test-Path $serverCertificate)
{
    openssl ca -config ../https.cnf -revoke "$serverCertificate"
}

openssl req -x509 -config ../https.cnf -newkey rsa:2048 -days 365 -out ca_certificate.pem -outform PEM -subj /CN=httpsca/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=httpsca/O=service/ -nodes

openssl ca -config ../https.cnf -in req.pem -out service_certificate.pem -notext -batch -extensions server_ca_extensions
openssl pkcs12 -export -out service_certificate.pfx -in service_certificate.pem -inkey private_key.pem -passout pass:MySecretPassword

$CERT_PATH = $rootPath + "\httpsca\ca_certificate.cer"
Write-Output $CERT_PATH
Import-Certificate -FilePath "$CERT_PATH" -CertStoreLocation Cert:\\LocalMachine\\Root

cd..

$process_id = [System.Diagnostics.Process]::GetCurrentProcess().Id
Stop-Process $process_id