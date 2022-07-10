# Offical Rabbit-MQ SSL/TLS Documentation:
https://www.rabbitmq.com/ssl.html

# Notes:
My setup is running Windows 10, Visual Studio Code, Visual Studio 2019, Powershell, Git Bash, Python 3.10.1, .Net Core 3.1.

# Prerequisites:

Install Chocolatey (Windows 10): https://chocolatey.org/install

Install OpenSSL (via chocolatey):
```
choco install openssl
```

Install Python with Pip3 (Windows 10): https://www.python.org/downloads/windows/

```
pip install termcolor
pip install python-on-whales
```

Install Docker Desktop: https://docs.docker.com/desktop/windows/install/

# App Installation:
Run install.py (from base folder):
```
python.exe ./install.py (rabbitmq, powershell for windows)
```

You can then choose what to install, hit [enter] key to install, otherwise hit every other key and then enter to skip.

To start to app (from base folder):
```
python.exe ./run.py (powershell for windows)
```

You can then choose what to run, hit [enter] key to build image and run, otherwise hit every other key and then enter to skip.

# Important:
Make sure to clone this folder to a directory without whitespace in its name! (powershell has issue with names of directories that has whitespaces)

Example: 'c:/github/rabbitmq-ssl'