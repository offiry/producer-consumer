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

# Revoke server and client certificates
cd testca

$serverCertificate = "..\server\server_certificate.pem"
$clientCertificate = "..\client\client_certificate.pem"

if(Test-Path $serverCertificate)
{
    openssl ca -config ../rabbitmq.cnf -revoke "$serverCertificate"
}

if(Test-Path $clientCertificate)
{
    openssl ca -config ../rabbitmq.cnf -revoke "$clientCertificate"
}

cd..

# Create CA certificate
cd testca

openssl req -x509 -config ../rabbitmq.cnf -newkey rsa:2048 -days 365 -out ca_certificate.pem -outform PEM -subj /CN=testca1/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

cd..

# Create server certificates and pkcs
if(!(Test-Path "./server"))
{
    mkdir server
}

cd server

openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=testca1/O=server/ -nodes

cd ../testca
openssl ca -config ../rabbitmq.cnf -in ../server/req.pem -out ../server/server_certificate.pem -notext -batch -extensions server_ca_extensions

cd ../server
openssl pkcs12 -export -out server_certificate.p12 -in server_certificate.pem -inkey private_key.pem -passout pass:MySecretPassword

cd..

# Create client certificates and pkcs
if(!(Test-Path "./client"))
{
    mkdir client
}

cd client
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM -subj /CN=testca1/O=client/ -nodes

cd ../testca
openssl ca -config ../rabbitmq.cnf -in ../client/req.pem -out ../client/client_certificate.pem -notext -batch -extensions client_ca_extensions

cd ../client
openssl pkcs12 -export -out client_certificate.p12 -in client_certificate.pem -inkey private_key.pem -passout pass:MySecretPassword

cd..

# Import CA to root
$CERT_PATH = $rootPath + "\testca\ca_certificate.cer"
Write-Output $CERT_PATH
Import-Certificate -FilePath "$CERT_PATH" -CertStoreLocation Cert:\\LocalMachine\\Root

# End process
$process_id = [System.Diagnostics.Process]::GetCurrentProcess().Id
Stop-Process $process_id