# Spring Cloud 熔断器 - Hystrix
> 摘要：本文属于原创，欢迎转载，转载请保留出处：[https://github.com/jasonGeng88/blog](https://github.com/jasonGeng88/blog)
> 
> 本文所有服务均采用docker容器化方式部署 
 
 
## 当前环境
1. Mac OS 10.11.x
2. Docker >= 1.12

## 描述

## 能做什么

## 核心

## 组成
### command
* sync
* async

### fallback

### Isolation

### Strategy

### Metrics（dashboard）
* single
* turbine

## 配置
* Execution
	* execution.isolation.strategy
	* execution.isolation.thread.timeoutInMilliseconds
	* execution.timeout.enabled
	* execution.isolation.thread.interruptOnTimeout
	* execution.isolation.thread.interruptOnCancel
	* execution.isolation.semaphore.maxConcurrentRequests
* Fallback
	* fallback.isolation.semaphore.maxConcurrentRequests
	* fallback.enabled
	 
* Circuit Breaker
	* circuitBreaker.enabled
	* circuitBreaker.requestVolumeThreshold
	* circuitBreaker.sleepWindowInMilliseconds
	* circuitBreaker.errorThresholdPercentage 

## 实现（结合 springboot）

## 展示

## 总结



