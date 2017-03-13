# 基于ELK+Filebeat搭建日志中心
 
> 本文是基于docker进行的容器化搭建ELK 
 
## 当前环境
1. 系统：centos7
2. docker 1.12.1


## 介绍

### ElasticSearch

Elasticsearch 是一个实时的分布式搜索和分析引擎，它可以用于全文搜索，结构化搜索以及分析。它是一个建立在全文搜索引擎 Apache Lucene 基础上的搜索引擎，使用 Java 语言编写。

### Logstash
Logstash 是一个具有实时渠道能力的数据收集引擎，主要用于日志的收集与解析，并将其存入
ElasticSearch中。

### Kibana
Kibana 是一款基于 Apache 开源协议，使用 JavaScript 语言编写，为 Elasticsearch 提供分析和可视化的 Web 平台。它可以在 Elasticsearch 的索引中查找，交互数据，并生成各种维度的表图。

### Filebeat
引入Filebeat作为日志搜集器，主要是为了解决Logstash开销大的问题。相比Logstash，Filebeat 所占系统的 CPU 和内存几乎可以忽略不计。

## 架构
### 不引入Filebeat
![](assets/elk_architecture_old.png)

### 引入Filebeat
![](assets/elk_architecture_new.png)

### 原因：Filebeat在服务器上的开销要比Logstash低

## 部署

### 启动ElasticSearch 
```
docker run -d -p 9200:9200 --name elasticsearch elasticsearch 

```
### 启动Logstash 
logstash.conf

```
input {
    beats {
        port => 5044
    }
}

output {
    stdout {
        codec => rubydebug
    }
    elasticsearch {
        hosts => ["10.18.29.32:9200"]
    }
}
```

```
docker run -d --expose 5400 -p 5400:5400 --name logstash -v "$PWD":/config-dir logstash -f /config-dir/logstash.conf
```

### 启动Filebeat
下载地址：[https://www.elastic.co/downloads/beats/filebeat](https://www.elastic.co/downloads/beats/filebeat)

1. 下载Filebeat压缩包
2. 解压文件：
```
tar -xvf filebeat-5.2.2-darwin-x86_64.tar.gz
```

3. 新建配置文件filebeat.yml

```
filebeat:
  prospectors:
    - paths:
        - /tmp/test.log #日志文件地址
      input_type: log #从文件中读取
      tail_files: true #以文件末尾开始读取数据
output:
  logstash:
      hosts: ["10.18.29.32:5400"]
```

4. 运行filebeat

```
./filebeat-5.2.2-darwin-x86_64/filebeat -e -c filebeat.yml
```


### 启动Kibana
```
docker run -d --name kibana -e ELASTICSEARCH_URL=http://10.18.29.32:9200 -p 5601:5601 kibana
```


## 测试
1. 向/tmp/test.log中写入数据，模拟日志数据

```
```

## 总结
本文主要讲述了如何一步步搭建ELK的过程，以及Filebeat在其中所起的作用。当然这仅仅作为大家了解ELK的基础，如果要在生产环境中部署，还需考虑服务器安全因素，如传输的安全性、端口权限的最小化暴露程度，防火墙设置等等。


