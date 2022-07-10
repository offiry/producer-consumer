from sys import stdout
import docker
import sys
import subprocess
from termcolor import colored
from python_on_whales import DockerClient
import asyncio
import warnings
import functools

def deprecated(func):
    """This is a decorator which can be used to mark functions
    as deprecated. It will result in a warning being emitted
    when the function is used."""
    @functools.wraps(func)
    def new_func(*args, **kwargs):
        warnings.simplefilter('always', DeprecationWarning)  # turn off filter
        warnings.warn("Call to deprecated function {}.".format(func.__name__),
                      category=DeprecationWarning,
                      stacklevel=2)
        warnings.simplefilter('default', DeprecationWarning)  # reset filter
        return func(*args, **kwargs)
    return new_func
    
async def run_rabbitmq():
    import docker
    answer = input(colored("run rabbitmq server and management-ui ? [enter] - yes, other - no", 'yellow'))
    if answer is not None and answer == "":
        print(colored(f"docker image building...", 'blue'))
        client = docker.from_env()
        # If you are having caching issues or the docker image wont update after build, set nocache=True
        image = client.images.build(path="./", tag="rabbitmq-ssl", dockerfile="devops/docker-compose/Dockerfile", forcerm=True, nocache=False) # docker build -t rabbitmq-ssl -f .\devops\docker-compose\Dockerfile .
        print(colored(f"docker image build {image} successfully.", 'green'))
        docker = DockerClient(compose_files=["./devops/docker-compose/docker-compose.yml"], compose_env_file="./devops/docker-compose/rabbitmq.env")
        print(colored(f"docker compose down...", 'blue'))
        docker.compose.down()
        # docker.compose.build()
        print(colored(f"docker compose up...", 'green'))
        await asyncio.create_task(docker.compose.up(detach=True))

@deprecated
async def run_rabbitmq_net_api_with_ssl():
    import docker
    answer = input(colored("run rabbitmq .net api producer-consumer ? [enter] - yes, other - no", 'yellow'))
    if answer is not None and answer == "":
        print(colored(f"docker image building...", 'blue'))
        client = docker.from_env()
        image = client.images.build(path="./", tag="net-rabbitmq-api", dockerfile="examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/ssl.Dockerfile", forcerm=True, nocache=False) # docker build -t net-rabbitmq-api -f .\examples\.net\RabbitMQProducerConsumerSSL\ssl.Dockerfile .
        print(colored(f"docker image build {image} successfully.", 'green'))
        docker = DockerClient(compose_files=["./examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/docker-compose.yml"], compose_env_file="./examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/services.env")
        print(colored(f"docker compose down...", 'blue'))
        docker.compose.down()
        # docker.compose.build()
        print(colored(f"docker compose up...", 'green'))
        await asyncio.create_task(docker.compose.up(detach=True))

async def run_ssl_base_image():
    import docker
    answer = input(colored("run ssl base image ? [enter] - yes, other - no", 'yellow'))
    if answer is not None and answer == "":
        print(colored(f"docker image building...", 'blue'))
        client = docker.from_env()
        image = client.images.build(path="./", tag="base-image-ssl", dockerfile="devops/baseImage/baseImage.Dockerfile", forcerm=True, nocache=True) # docker build -t base-image-ssl -f .\devops\baseImage\baseImage.Dockerfile .
        print(colored(f"docker image build {image} successfully.", 'green'))
        await asyncio.create_task()

async def run_rabbitmq_net_api():
    import docker
    answer = input(colored("run rabbitmq .net api producer-consumer ? [enter] - yes, other - no", 'yellow'))
    if answer is not None and answer == "":
        print(colored(f"docker image building...", 'blue'))
        client = docker.from_env()
        image = client.images.build(path="./", tag="net-rabbitmq-api", dockerfile="examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/Dockerfile", forcerm=True, nocache=False) # docker build -t net-rabbitmq-api -f .\examples\.net\RabbitMQProducerConsumerSSL\ssl.Dockerfile .
        print(colored(f"docker image build {image} successfully.", 'green'))
        docker = DockerClient(compose_files=["./examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/docker-compose.yml"], compose_env_file="./examples/.net/RabbitMQProducerConsumerSSL/devops/docker-compose/services.env")
        print(colored(f"docker compose down...", 'blue'))
        docker.compose.down()
        # docker.compose.build()
        print(colored(f"docker compose up...", 'green'))
        await asyncio.create_task(docker.compose.up(detach=True))

loop = asyncio.get_event_loop()

tasks = [
    asyncio.ensure_future(run_rabbitmq()),
    asyncio.ensure_future(run_ssl_base_image()),
    asyncio.ensure_future(run_rabbitmq_net_api()),
]

loop.run_until_complete(asyncio.gather(*tasks))
loop.close()
