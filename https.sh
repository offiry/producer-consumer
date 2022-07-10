rm -rf httpsca

mkdir httpsca
cd httpsca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt