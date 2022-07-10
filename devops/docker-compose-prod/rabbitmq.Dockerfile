FROM rabbitmq:3.9-management

RUN apt-get update -y \
    && apt-get upgrade -y

COPY rabbitmq.config /etc/rabbitmq/rabbitmq.conf
COPY testca/ca_certificate.pem /var/lib/rabbitmq/cacert.pem
COPY server/private_key.pem /var/lib/rabbitmq/key.pem
COPY server/server_certificate.pem /var/lib/rabbitmq/cert.pem

EXPOSE 15671
EXPOSE 15672
EXPOSE 5671
EXPOSE 5672