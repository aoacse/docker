# Protoype of MVP Integration Plattform

* ELK Stack for logging
* Zero ESB as service gateway
* SOAP-UI Mock Server for demonstration
* Elasticsearchconnector to connect kafka with the ELK stack and not using Logstash.

# Docker Images:
In docker-compose.yml are 6 images:

* elasticsearch
* kafka1
* kibana
* jboss
* soapuimock
* elasticsearchkafkaconnector

The first four are downloaded automatically and belong to the elk stack. But before you start with docker-compose, you have to build the soapuimock and elastisearchconnector on your own.

## Setup

1.  Clone this repository:
    ```
    git clone https://github.com/aoacse/docker.git
    ```

2. set you hosts file 
   ```
   127.0.0.1       localhost kafka1
   ```
3. Build soapuimock image
   ```cd soapuimock/
      docker build -t soapui
     ```
4. Build elastisearchconnector image
   ```cd elasticsearchconnector/
      docker build -t elasticsearchkafkaconnector
     ```
## Test
1. Start your local SOAP-UI
2. Import the SOAP-UI Project from soapuimock/
3. Start a test request


# Hints
remove dangling images (none) -> docker rmi $(docker images -a|grep "<none>"|awk '$1=="<none>" {print $3}')
