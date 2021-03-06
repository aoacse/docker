# Protoype of MVP Integration Plattform

* ELK Stack for logging
* Zero ESB as service gateway
* SOAP-UI Mock Server for demonstration
* Elasticsearchconnector to connect kafka with the ELK stack and not using Logstash.

# Docker Images:
In docker-compose.yml are 11 images:

* elasticsearch
* kafka1
* kibana
* tomcat1
* soapuimock
* elasticsearchkafkaconnector
* gravitee API management UI
* gravitee API management API
* gravitee API Gateway
* MongoDB
* Zookeeper

The first three are downloaded automatically and belong to the elk stack. The forth one downloads automatically as well. It is required for running the Zero ESB. The fifth and the sixth images need to be build on your own (step 3 & 4). The other images are also downlowed automacically.

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
3. Send few test requests

## Configure Kibana
1. Log in to Kibana -  http://localhost:5601/
2. In Kibana got to "Management" (left menue bottom item) and create an index.
```
logs_index
```
3. select timestamp. If you cannot see the timestamp, press "refresh fields". Important: You have to send some requests before you can create the index.

4. Next go to "Saved Objects" and import the json file from the kibana git folder.

5. you can also use the API Management to define your own API. Login into API Management UI: http://localhost:8002/#!/ admin/admin and start publishing an API.

### URLs:
1. Admin Zero ESB: http://kafka1:8080/esb0/admin
2. Kibana: http://localhost:5601/
3. API Management UI: http://localhost:8002/#!/ admin/admin
4. API Gateway URL: http://localhost:8000 - KONTEXT_PATH

# Hints
1. remove dangling images (none) -> docker rmi $(docker images -a|grep "<none>"|awk '$1=="<none>" {print $3}')
2. Windows user please set autocrlf=false for this git repository
