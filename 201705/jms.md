# JAVA 消息服务 - JMS
> 摘要：本文属于原创，欢迎转载，转载请保留出处：[https://github.com/jasonGeng88/blog](https://github.com/jasonGeng88/blog)

> 上周有幸参与了并发编程网发起的《Spring 5 官方文档》的翻译工作，我在其中翻译了有关 JAVA 消息服务（JMS）的部分，译文地址：[http://ifeve.com/spring-5-26-jms-java-message-service](http://ifeve.com/spring-5-26-jms-java-message-service/)。

## Using JMS
### JmsTemplate
### Connections

	ConnectionFactory->Connection->Session->MessageProducer->send
	
* SingleConnectionFactory
* CachingConnectionFactory

### Destination
### Message Listener Container
* SimpleMessageListenerContainer
* DefaultMessageListenerContainer

### Transaction

## Send Message
### MessageConverter
### SessionCallback & ProducerCallback

## Receive Message
### receive message synchronously
### receive asynchronously - Message-Driven POJOs
### SessionAwareMessageListener
### MessageListenerAdapter
### Transaction

## JCA

## Annotation
* @JmsListener
* @EnableJms
* @SendTo

