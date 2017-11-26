# 线程池的正确打开方式
> 摘要：本文属于原创，欢迎转载，转载请保留出处：[https://github.com/jasonGeng88/blog](https://github.com/jasonGeng88/blog)

## 前言
今天，想拿快递公司举个例子，和大家聊聊线程池相关的几个核心参数。这里，我们把线程池比作快递公司，把对线程池的调用比作投递包裹，而线程就看作是快递员，负责把快递送到指定地点。

首先，我们得成立一个公司，这样才有人来找我们邮寄包裹。这就是“线程池的创建过程”。

既然是公司，那得有员工吧。于是就有了

* 首先，我们得创建一个工厂。

* corePoolSize：核心线程数
* maximumPoolSize：最大线程数
* keepAliveTime：线程存活时间
* workQueue：工作队列
* ThreadFactory：线程工厂
* RejectedExecutionHandler：丢弃策略

## 核心参数

* corePoolSize：核心线程数
* maximumPoolSize：最大线程数
* keepAliveTime：线程存活时间
* workQueue：工作队列
* ThreadFactory：线程工厂
* RejectedExecutionHandler：丢弃策略

## scheduling delayQueue

LockSupport.parkNanos(Object blocker, long nanos);

## shutdown && shutdownNow





