# ELK实战之解析各类日志文件
 
> ELK环境是基于docker进行的容器化部署 <br>
> 关于容器化部署，详情见上一篇 [“ELK：基于ELK+Filebeat的日志搭建”](https://github.com/jasonGeng88/blog/blob/master/201703/elk.md)
 
## 当前环境
1. logstash：5.2


## 介绍
基于上一篇讲述了ELK日志系统的搭建，那么就该讲讲ELK在生产中的实际使用场景了。<br>

作为一个日志中心，肯定不单单只收集一种日志，那每种不同的日志，它的存储格式势必有所差异，但同时又存在一些共性的东西（如日志级别，记录时间等）。我们如何去解析不同类型的日志、提炼共性的字段，这就是我写本篇文章的主旨。

## 原理
依照前文，使用filebeat作为日志上传，logstash进行日志处理，elasticsearch作为日志存储与搜索，最后使用kibana作为日志的可视化呈现。所以不难发现，日志解析主要还是logstash做的事情。<br>

说到logstash，它到底有哪些东西呢？我们来简单看下：
![](assets/elk_parse_log_01.png)

从上图中可以看到，logstash主要包含三大模块：

1. INPUTS: 收集所有数据源的日志数据（[源有file、redis、beats等](https://www.elastic.co/guide/en/logstash/current/input-plugins.html),*filebeat就是使用了beats源*）；
2. FILTERS: 解析、整理日志数据（**本文重点**）；
3. OUTPUTS: 将解析的日志数据输出至存储器（[elasticseach、file、syslog等](https://www.elastic.co/guide/en/logstash/current/output-plugins.html)）；


下面来讲讲filter中的常用几个插件（*后面日志解析会用到*）：

1. grok：采用正则的方式，解析原始日志格式，使其结构化（还提供了[120种正则模板](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)）；
2. geoip：根据IP字段，解析出对应的地理位置、经纬度等；
3. date：解析选定时间字段，将其时间作为logstash每条记录产生的时间（*若没有指定该字段，默认使用read line的时间作为该条记录时间*）；

*注意：codec也是经常会使用到的，它主要作用在INPUTS和OUTPUTS中，[提供有json的格式转换、multiline的多行日志合并等](https://www.elastic.co/guide/en/logstash/current/codec-plugins.html)*

## 场景
1. Nginx访问日志

* filebeat配置

```
filebeat:
  prospectors:
    - document_type: nginx #申明type字段为nginx，默认为log
      paths:
        - /var/log/nginx/access.log #日志文件地址
      input_type: log #从文件中读取
      tail_files: true #以文件末尾开始读取数据
output:
  logstash:
      hosts: ["${LOGSTASH_IP}:5044"]
shipper:
  name: "server1" #设置filebeat的名称，默认为主机hostname ？？
```

* 日志格式
 
``` 
log_format  main  '$remote_addr - $remote_user [$time_local] 
"$request" $status $body_bytes_sent "$http_referer" 
"$http_user_agent" "$http_x_forwarded_for"'; 
```

* 日志内容

```
112.65.171.98 - - [15/Mar/2017:18:18:06 +0800] "GET /index.html HTTP/1.1" 200 1150 "http://www.yourdomain.com/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" "-"
```

* logstash中FILTERS配置

```
filter {
    grok{
       match => { "message" => "%{COMBINEDAPACHELOG}" }
    }

   date {
        match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z", "ISO8601" ]
        target => "@timestamp" #将match中匹配的时间替换该字段，默认替换@timestamp，可省略
    }
}
```

* 结果

```
{
  "_index": "logstash-2017.03.15",
  "_type": "nginx",
  "_id": "AVrTEhH598gzB26fVsxM",
  "_score": 1,
  "_source": {
    "request": "/index.html",
    "agent": "\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36\"",
    "offset": 960,
    "auth": "-",
    "ident": "-",
    "input_type": "log",
    "verb": "GET",
    "source": "/root/elk/logs/nginx_access.log",
    "message": "112.65.171.98 - - [15/Mar/2017:18:21:06 +0800] \"GET /index.html HTTP/1.1\" 200 1150 \"http://www.yourdomain.com/\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36\" \"-\"",
    "type": "nginx",
    "tags": [
      "beats_input_codec_plain_applied"
    ],
    "referrer": "\"http://www.yourdomain.com/\"",
    "@timestamp": "2017-03-15T10:21:06.000Z",
    "response": "200",
    "bytes": "1150",
    "clientip": "112.65.171.98",
    "@version": "1",
    "beat": {
      "hostname": "iZ2ze5m5k5v2yoarjn31sqZ",
      "name": "iZ2ze5m5k5v2yoarjn31sqZ",
      "version": "5.2.2"
    },
    "host": "iZ2ze5m5k5v2yoarjn31sqZ",
    "httpversion": "1.1",
    "timestamp": "15/Mar/2017:18:21:06 +0800"
  },
  "fields": {
    "@timestamp": [
      1489573266000
    ]
  }
}
```






2. Tomcat日志（多行）
3. NodeJS日志
```
2017-03-15 18:34:14.535 INFO /root/ws/socketIo.js - xxxxxx与ws server断开连接
```
4. 日志整合

## 总结


