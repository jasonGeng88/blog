# ELK实战之解析各类日志文件
 
> ELK环境是基于docker进行的容器化部署
 
## 当前环境
1. docker 1.12.1
2. logstash：5.2


## 介绍


## 原理
1. logstash：input -> filter -> output
	1. input: 日志收集；
	2. filter：日志解析（本文主要围绕它讲述）；
	3. output：日志输出；
2. filter常用插件：
	1. grok：解析原始日志格式，使其结构化（还提供了[120种日志模板](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)）；
	2. geoip：根据IP字段，解析出对应的地理位置、经纬度等；
	3. date：解析选定时间字段，将其时间作为logstash每条记录产生的时间；

## 场景
1. Nginx访问日志

```
log_format  main  '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"'; 
```

	112.65.171.98 - - [15/Mar/2017:18:18:06 +0800] "GET /index.html HTTP/1.1" 200 1150 "http://www.yourdomain.com/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36" "-"



2. Tomcat日志（多行）
3. NodeJS日志
```
2017-03-15 18:34:14.535 INFO /root/ws/socketIo.js - xxxxxx与ws server断开连接
```
4. 

## 总结


