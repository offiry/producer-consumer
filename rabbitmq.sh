rm -rf client
rm -rf server
rm -rf testca

mkdir testca
cd testca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt