# Protoype of MVP Integration Plattform

* ELK Stack for logging
* Zero ESB as service gateway
* SOAP-UI Mock Server for demonstration

# Docker Images:
In docker-compose.yml are 6 images:

elasticsearch
kafka1
kibana
jboss
soapuimock
elasticsearchkafkaconnector

The first four are downloaded automatically. But before you start with docker-compose, you have to build the soapuimock and elastisearchconnector on your own.

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


# Hints
remove dangling images (none) -> docker rmi $(docker images -a|grep "<none>"|awk '$1=="<none>" {print $3}')




4. [Configure File Descriptors and MMap](https://www.elastic.co/guide/en/elasticsearch/guide/current/_file_descriptors_and_mmap.html)
To do so you have to type the following command:
    ```
    sysctl -w vm.max_map_count=262144
    ```
    Be aware that the previous sysctl setting vanishes when your machine restarts.
    If you want to make it permanent place `vm.max_map_count` setting in your `/etc/sysctl.conf`.
5. Create the elasticsearch volume:
    ```bash
    $ cd kafka-elk-docker-compose
    $ mkdir esdata
    ```
    By default the *docker-compose.yml* uses *esdata* as the host volumen path name. If you want to use another name you have to edit the *docker-compose.yml* file and create your own structure.
6. Create the *apache-logs* folder:
    ```bash
    $ cd kafka-elk-docker-compose
    $ mkdir apache-logs
    ```
    This repository uses a default *apache container* to generate logs and it is required for *filebeat* to be present. If you do not want to use this apache or you want to add new components to the system just use the *docker-compose.yml* as a base for your use case.

## Usage

Deploy your Kafka+ELK Stack using *docker-compose*:

```bash
$ docker-compose up -d
```
By default the apache container generating logs is exposed through port 8888. You can perform some requests to generate a few log entries for later visualization in kibana:

``` bash
$ curl http://localhost:8888/
```

The full stack takes around a minute to be fully functional as there are dependencies beteween services.
After that you should be able to hit Kibana [http://localhost:5601](http://localhost:5601)

Before you see the log entries generated before you have to configure an index pattern in kibana. Make sure you configure it with these two options:
* Index name or pattern: logstash-*
* Time-field name: @timestamp

## Configuration
The *docker-compose.yml* deploys an ELK solution using kafka as a buffer for log collection. This repository is shipped with the minimal amount of configuration needed to make the stack work. The default config files are:
### filebeat.yml:
```
filebeat.prospectors:
- paths:
    - /apache-logs/access.log
  tags:
    - testenv
    - apache_access
  input_type: log
  document_type: apache_access
  fields_under_root: true

- paths:
    - /apache-logs/error.log
  tags:
    - testenv
    - apache_error
  input_type: log
  document_type: apache_error
  fields_under_root: true

output.kafka:
  hosts: ["kafka1:9092", "kafka2:9092", "kafka3:9092"]
  topic: 'log'
  partition.round_robin:
    reachable_only: false
  required_acks: 1
  compression: gzip
  max_message_bytes: 1000000
```
As you can see it is configured to read the default apache logs and push them to kafka. Any addition or change to the filebeat agent should be perform in this config file.

### logstash.conf:
```
input {
  kafka {
    bootstrap_servers => "kafka1:9092,kafka2:9092,kafka3:9092"
    client_id => "logstash"
    group_id => "logstash"
    consumer_threads => 3
    topics => ["log"]
    codec => "json"
    tags => ["log", "kafka_source"]
    type => "log"
  }
}

filter {
  if [type] == "apache_access" {
    grok {
      match => { "message" => "%{COMMONAPACHELOG}" }
    }
    date {
      match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
      remove_field => ["timestamp"]
    }
  }
  if [type] == "apache_error" {
    grok {
      match => { "message" => "%{COMMONAPACHELOG}" }
    }
    date {
      match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"]
      remove_field => ["timestamp"]
    }
  }
}

output {
  if [type] == "apache_access" {
    elasticsearch {
         hosts => ["elasticsearch:9200"]
         index => "logstash-apache-access-%{+YYYY.MM.dd}"
    }
  }
  if [type] == "apache_error" {
    elasticsearch {
         hosts => ["elasticsearch:9200"]
         index => "logstash-apache-error-%{+YYYY.MM.dd}"
    }
  }
}
```
As you can, logstash is configured as a kafka consumer to parse apache logs and to insert them into elasticsearch. Any addition or change to the logstash behaviour should be perform in this config file.

### kibana.yml:
```
server.name: kibana
server.host: "0"
elasticsearch.url: http://elasticsearch:9200
xpack.monitoring.ui.container.elasticsearch.enabled: false
```

It is remarkable the fact that by default that both kibana and elasticsearch docker images enable by default the xpack plugin, which you will have to pay for it after the trial. This repository disables this paid feature by default. Any addition or change to the kibana behaviour should be perform in this config file.

### Other configuration:
You can configure much more each of the components of the stack. It is up to you and your use case to extend the configuration files and change the *docker-compose.yml* to make it so.
