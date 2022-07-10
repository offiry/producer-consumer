cd client
openssl s_client -connect localhost:5671 -cert client_certificate.pem -key private_key.pem -CAfile ../testca/ca_certificate.pem -verify 8 -verify_hostname testca1
cd..

cd server
openssl s_server -accept 5671 -cert server_certificate.pem -key private_key.pem -CAfile ../testca/ca_certificate.pem
cd..