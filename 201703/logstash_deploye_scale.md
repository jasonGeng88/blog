# 【译】Logstash的部署与扩展
 
> 摘要：本文属于原创，未经允许不得转载！
 
## 原文链接

[https://www.elastic.co/guide/en/logstash/current/deploying-and-scaling.html#deploying-and-scaling](https://www.elastic.co/guide/en/logstash/current/deploying-and-scaling.html#deploying-and-scaling)


## 最简安装
Logstash的最简安装是一个Logstash实例、一个Elasticsearch实例。两者之间是直接相连的。按照Logstash的处理流程，使用了一个采集数据的INPUT插件，一个在Elasticsearch上索引数据的OUTPUT插件。Logstash实例按照配置文件上的固定流程来启动。你必须指明一个INPUT插件，OUTPUT默认输出方式是stdout，FILTER是可选的，下文会讲到。

![](assets/logstash_scale_01.png)

## 使用 Filters
日志数据一般都是无结构化的，经常包含与你使用使用场景无关的信息，或者有时丢失一些能够从日志内容中获取的相关信息。你可以使用[filter plugin](https://www.elastic.co/guide/en/logstash/5.2/filter-plugins.html)来解析你的日志，移除无用的信息，提取有效字段，并可以在此基础上提取额外的信息。例如，filters可以从IP地址中获取地理信息，将其添加进日志中，可以使用[grok filter](https://www.elastic.co/guide/en/logstash/5.2/plugins-filters-grok.html)解析文本信息，使其结构化。

添加filter plugin最明显的是会影响性能，这取决于filter plugin执行的计算量，以及处理的日志大小。grok filter的正则计算尤其占用资源。处理计算资源消耗大的一种方式是采用计算机的多核进行并行计算。使用 -w 参数来设置Logstash filter任务的执行线程数。例如，bin/logstash -w 8 命令使用的是8个不同的线程来处理filter。

![](assets/logstash_scale_02.png)

## 使用 Filebeat
[Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html) 是一款有Go语言编写的轻量级、资源消耗低的日志收集工具，主要作用是收集服务器上的日志，并将其传输到其他机器上进行处理。Filebeat 使用[Beats](https://www.elastic.co/guide/en/beats/libbeat/current/index.html)协议与一个Logstash实例进行通信。使用[Beats input plugin](https://www.elastic.co/guide/en/logstash/5.2/plugins-inputs-beats.html)来配置你的Logstash的实例，让其接收Beats传来的数据。

Filebeat使用的是源数据所在机器的计算资源，Beats input plugin 最小化了Logstash实例的资源需求，这种架构对于有资源限制要求的场景来说，非常有用。

![](assets/logstash_scale_03.png)

## 扩展到更大的Elasticsearch集群

Logstash 一般不直接和Elasticsearch的单节点进行通信，而是和多个节点组成的Elasticsearch集群进行通信。而不是和单个节点通信。Logstash默认采用HTTP协议将数据传输进集群。

你可以使用Elasticsearch提供的REST接口向集群索引数据。这些接口提供的数据都是JSON形式的。使用REST接口不需要引入任何JAVA的客户端类以及额外的JAR文件，并且相比节点协议与传输，都没有性能上的损失。可以在REST接口中使用[X-Pack Security](https://www.elastic.co/guide/en/x-pack/current/xpack-security.html)达到安全传输的目的，它支持SSL与HTTP basic的安全校验。

当你使用HTTP协议，你可以在Logstash配置Elasticsearch output plugin时，根据提供Elasticsearch集群的多个地址，自动做到请求的负载均衡。多个指定的Elasticsearch节点通过路由流量到已激活节点的方式，为群集提供了高可用性。

你也可以使用Elasticsearch JAVA APIs将数据序列化为二进制，再以二进制协议进行传输。该协议可以嗅出请求的终端，该终端可以选择任意的客户端或集群中的任意节点。

使用HTTP或二进制协议，使Elasticsearch 集群与你有Logstash实例相分离。 同时，该节点协议又把这两者连接在一起。 需要同步的数据从一个节点传输至集群中的其余节点。当该机器作为集群的一部分，集群拓扑是可用的，对使用相对少量的持久连接的场景，使用节点协议是较合适的。

你也可以使用第三方的负载均衡硬件或软件，来处理Logstash与外部应用的连接。

*注意：确保你的Logstash配置不直接连接到Elasticsearch 的[管理集群的主节点](https://www.elastic.co/guide/en/elasticsearch/reference/5.2/modules-node.html)上。将Logstash连接到客户端或数据节点上，来保护你有Elasticsearch 集群的稳定性*

![](assets/logstash_scale_04.png)

## 通过消息队列来管理吞吐量峰值

当进入Logstash的数据超过了Elasticsearch集群处理数据的能力时，你可以使用一个消息协商器来作为缓冲。默认情况下，当数据的处理速率低于接收速率，Logstash的接收事情会产生瓶颈。因为该瓶颈会导致事件在数据源进行了缓冲，所以防止消息协商器的压力将成为你部署中的重要环节。

添加一个消息协商器到你的Logstash部署中对数据丢失也提供一定的保护。当Logstash实例在消息xieshangqi中消费数据失败时，消息协商器中的数据将被回放到Logstash已激活的实例中。

几个第三方的消息队列，如Redis，Kafka，RabbitMQ。Logstash在input、output中提供了相应的插件来集成这些第三方的消息队列。当你的Logstash部署配置了消息队列，Logstash的处理分为了两个阶段：第一阶段，传输实例，负责处理数据采集，并将其存入消息队列；第二阶段，索引实例，从消息队列中获取数据，应用所配置的filter，将处理过的数据写入Elasticsearch中。

![](assets/logstash_scale_05.png)

## 采用多连接的方式保证Logstash的高可用

为了使你的Logstash部署在单个实例失败的场景下更有弹性，你可以在你的数据源与Logstash集群间建立一个负载均衡。这个负载均衡处理与Logstash实例的独立连接，保证了在单个实例不可用的情况下，数据采集与处理的正常进行。

![](assets/logstash_scale_06.png)

上面的架构中存在一种问题，它不能处理来自某一特定类型的Input，例如RSS订阅或文件输入，只提供一种Input类型的Logstash实例会使这架构变得不可用。为了使input更健壮，每个Logstash实例都要配置多个input通道，如下图：

![](assets/logstash_scale_07.png)

该架构基于你配置的input，可以使Logstash的工作量得到并行处理。对于更多的input输入，你可以增加更多的Logstash实例进行水平扩展。每个单独且平行的实例，也增加了你技术架构的可靠性，消除了单点故障。

## 扩展Logstash

一个成熟的Logstash部署有下面：

* input层从数据源中消费数据，并且使用合适的input plugins组成Logstash实例。
* 消息队列作为一个缓冲，保障了数据的采集与失败转移的保护。
* filter层对从消息队列中获取的数据进行解析和其他操作。
* indexing层将处理的数据输送到Elasticsearch。

这其中的每一层都可以通过增加计算资源进行扩展。随着你使用场景的发展与所需资源的增加，定期检查这些组件的性能。一旦当Logstash遇到输入的瓶颈，可考虑增加消息队列的存储。另一种方式，通过增加更多的Logstash索引实例来增加Elasticsearch集群的数据消费速率。