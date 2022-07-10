FROM mcr.microsoft.com/dotnet/aspnet:3.1 as base

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y ca-certificates

RUN chmod 710 /etc/ssl/private
COPY httpsca/service_certificate.pfx /etc/ssl/private/service_certificate.pfx
RUN chmod 640 /etc/ssl/private/service_certificate.pfx

RUN chmod -R -f 777 /usr/local/share/ca-certificates
COPY httpsca/ca_certificate.pem /usr/local/share/ca-certificates/service_certificate.crt
RUN chmod 644 /usr/local/share/ca-certificates/service_certificate.crt && update-ca-certificates