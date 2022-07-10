# Production Mode:

In order to run in production mode you'll need a linux based server (in this example I used AWS and Ubuntu 20.04)
Once you created the server, you'll to enter it with SSH (I use PuTTy, make sure you generate a .ppk file)

PuTTy guide: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html

You will also need a domain, you can create a free one on https://freenom.com
You will need to create a DNS record A with the IP of the server. (you can leave Name field empty)

Once you SSH into your server:

1. Install certbot
```
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt install certbot
```

2. Create an SSL via LetsEncrypt
```
sudo certbot certonly --standalone http -d yourdomain.com
```

3. This step is optional, if you want to auto renew your certificate:
```
@weekly certbot renew --pre-hook "docker-compose -f path/to/docker-compose.yml down" --post-hook "docker-compose -f path/to/docker-compose.yml up -d"
```

4. Install Docker CE and Docker-Compose:
```
sudo apt install docker.io
sudo apt install docker-compose
```

5. Clone this repo
```
git clone https://github.com/offiry/producer-consumer.git
```

6. Enter prod folder
```
cd producer-consumer\prod
```

7. Run docker compose
```
sudo docker-compose up
```

You can test your enviroment by hitting:
https://yourdomain/api/cqrs or http://yourdomain/api/cqrs
https://yourdomain/rabbit/ or http://yourdomain/rabbit/
