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

The first thre are downloaded automatically and belong to the elk stack. The forth one downloads automatically as well. It is required for running the Zero ESB. The fifth and the sixth images need to be build on your own (step 3 & 4).

## Setup

1.  Clone this repository:
    ```
    git clone https://github.com/aoacse/docker.git
    ```

2. set your hosts file 
   ```
   127.0.0.1   kafka1
   ```
3. Build soapuimock image
   ```
      cd soapuimock/
      docker build -t soapui .
    ```
4. Build elastisearchconnector image
   ```
      cd elasticsearchconnector/
      docker build -t elasticsearchkafkaconnector .
     ```
5. Change to the root of this git repo and use docker-compose to start
    ``` 
    docker-compose up
    ``` 

## Test
1. Start your local SOAP-UI
2. Import the SOAP-UI Project from 
    ```
    soapuimock/
    ```
3. Start a test request

## Configure Kabana
1. Log in to Kabana
2. Create an index called
```logs_index
```
3. select timestamp. If you cannot see the timestamp, press "refresh fields". Important: You have ti send some requests before you can create the index.

### URLs:
1. Admin Zero ESB: http://kafka1:8080/esb0/admin
2. Kibana: http://localhost:5601/

# Hints
remove dangling images (none) -> docker rmi $(docker images -a|grep "<none>"|awk '$1=="<none>" {print $3}')
