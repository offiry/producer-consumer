# docker build --progress=plain --no-cache -t net-rabbitmq-api -f .\examples\.net\RabbitMQProducerConsumerSSL\Dockerfile .

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y ca-certificates

# ENV Kestrel__Certificates__Default__Path=/etc/ssl/private/service_certificate.pfx
# ENV Kestrel__Certificates__Default__Password=MySecretPassword
# ENV Kestrel__Certificates__Default__AllowInvalid=true
# ENV Kestrel__EndPointDefaults__Protocols=Http1AndHttp2

RUN chmod 710 /etc/ssl/private
COPY httpsca/service_certificate.pfx /etc/ssl/private/service_certificate.pfx
RUN chmod 640 /etc/ssl/private/service_certificate.pfx

RUN chmod -R -f 777 /usr/local/share/ca-certificates
COPY httpsca/ca_certificate.pem /usr/local/share/ca-certificates/service_certificate.crt
RUN chmod 644 /usr/local/share/ca-certificates/service_certificate.crt && update-ca-certificates

EXPOSE  80
EXPOSE  443

COPY testca/ca_certificate.pem /usr/local/share/ca-certificates/ca_certificate.crt
# COPY testca/ca_certificate.pem /etc/ssl/certs/ca_certificate.crt
RUN chmod 644 /usr/local/share/ca-certificates/ca_certificate.crt && update-ca-certificates
# RUN chmod 644 /etc/ssl/certs/ca_certificate.crt && update-ca-certificates

WORKDIR /app

RUN mkdir /settings \
    && chown -R 1000:1000 /app \
    && chown -R 1000:1000 /settings

USER 1000

COPY client/client_certificate.p12 /app/settings/client_certificate.p12

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY  ["examples/.net/RabbitMQProducerConsumerSSL/ProducerConsumerApi/ProducerConsumerApi.csproj", "ProducerConsumerApi/"]

RUN dotnet restore "ProducerConsumerApi/ProducerConsumerApi.csproj"
COPY . .
WORKDIR "/src/examples/.net/RabbitMQProducerConsumerSSL/ProducerConsumerApi"
RUN dotnet build "ProducerConsumerApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ProducerConsumerApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ProducerConsumerApi.dll"]