until $(curl --output /dev/null --silent --head --fail https://producer-consumer-rabbitmq.cf/rabbit/); do
    echo "waiting for rabbitmq service.."
    sleep 5
done

# url=https://producer-consumer-rabbitmq.cf/rabbit/
# curl ${url} -I -o headers -s
# cat  headers
# cat headers | head -n 1 | cut '-d ' '-f2'
# sleep 10

dotnet ProducerConsumerApi.dll