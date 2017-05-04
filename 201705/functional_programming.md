# [译] 2017年你应该了解的函数式编程
> 摘要：本文属于原创，欢迎转载，转载请保留出处：[https://github.com/jasonGeng88/blog](https://github.com/jasonGeng88/blog)

**原文：[https://hackernoon.com/you-should-learn-functional-programming-in-2017-91177148ec00](https://hackernoon.com/you-should-learn-functional-programming-in-2017-91177148ec00)**

函数式编程已经存在了很长了时间，早在50年代 [Lisp](https://zh.wikipedia.org/wiki/LISP) 编程语言的介绍中就有提过。如果你有关注近两年里内热门的 Clojure，Scala，Erlang，Haskell，Elixir 等语言的话，其中都有函数式编程的概念。

那么到底什么是函数式编程，为什么每个人都痴迷于它？在这篇文章中，作者将试图回答以上问题，并且激起你对函数式编程的兴趣。

## 函数式编程的简要历史
正如我们所说的，早在50年代函数式编程开始之前，Lisp 语言就已经在 IBM 700/7000 系列的科学计算机上运行了。Lisp 引入了很多与我们现在的函数式编程有关的示例与功能，我们甚至可以称 Lisp 是所有函数式编程语言的鼻祖。

这也是函数式编程中最有趣的方面，所有函数式编程语言都是基于相同的 [λ演算](https://zh.wikipedia.org/wiki/%CE%9B%E6%BC%94%E7%AE%97)，这种简单数学基础。

*λ演算是由图灵完成的，它是一种通用的计算模型，可用于模拟任何一台单带图灵机。它名字中的希腊字母 lambda（λ），被使用在了 lambda 表达式和 lambda 项绑定函数中的变量中。*

λ演算是一个极其简单但又十分强大的概念。它的核心主要有两个概念：

* 函数的抽象，通过引入变量来归纳得出表达式；
* 函数的应用，通过给变量赋值来对已得出的表达式进行计算；

让我们来看个小例子，单参数函数 f，将参数递增1。

```
f = λ x. x+1
```

假设我们应用函数在数字5上，那么函数读取如下：

```
f(5) => 5 + 1
```

## 函数式编程的基本原理
现在，数学知识已经够了。让我们看一下使函数式编程变得强大的特性有哪些？

### 头等函数（first-class function）
在函数式编程中，函数是一等公民，意思是说函数可以赋值给变量，例如在 [elixir](http://elixir-lang.org/getting-started/introduction.html) 中，

	double = fn(x) -> x * 2 end

然后我们可以如下来调用函数：

	double.(2)

### 高阶函数（higher-order function）
高阶函数的定义是，接收一个或多个函数变量作为参数，然后生成的新函数，即为高阶函数。让我们再次使用函数 double 来说明这个概念：

	double = fn(x) -> x * 2 end 
	Enum.map(1..10, double)
	
这例子中，Enum.map 将一个枚举列表作为第一参数，之前定义的函数作为第二参数；然后将这个函数应用到枚举中的每一个元素，结果为：

	[2,4,6,8,10,12,14,16,18,20]
	
### 不可变状态（Immutable State）
在函数式编程语言中，状态是不可变的。这意味着一旦一个变量被绑定了一个值，它将不能再被重新定义。这在防止副作用与条件竞争上有明显的优势，使并发编程更简单。

和上面一样，让我们使用 Elixir 来说明一下这概念：

	iex> tuple = {:ok, "hello"}
	{:ok, "hello"}
	iex> put_elem(tuple, 1, "world")
	{:ok, "world"}
	iex> tuple
	{:ok, "hello"}
	
这个例子中，tuple 的值从来没有改变过，第三行 put_elem 是返回了一个完全新的 tuple， 而没有去修改原有的值。


## 函数式编程应用
作为一个程序员，我们生活在激动人心的时代，云端的承诺已经兑现。与此同时，我们每个人都能获取前所未有的计算机资源。不幸的是，随之带来的扩展性、性能、并发性的需求。

面向对象编程根本不能简单的解决这些需求，尤其是在处理并发和并行计算的时候。尝试添加并发性和并行性，只会使语言增加它的复杂性，以及差的性能表现。

函数式编程在另一方面是非常适合这些挑战的，不可变状态、闭包和高阶函数等概念，在对于编写高度并发和分布式应用程序而言，它们非常适合。

你可以通过查看“WhatsApp和Discord”等创业公司的技术资料，找到足够的证明：

* [WhatsApp](https://www.wired.com/2015/09/whatsapp-serves-900-million-users-50-engineers/) 仅通过50个使用 Erlang 的开发工程师，就能够支持9亿的用户；
* [Discord](https://blog.discordapp.com/how-discord-handles-push-request-bursts-of-over-a-million-per-minute-with-elixirs-genstage-8f899f0221b4) 以类似的方式使用 Elixir 处理每分钟超过一百万次的请求；

这些公司和团队能够处理这种巨大的增长，要感谢函数式编程的优势。随着函数式编程得到越来越多的认同，我坚信像 WhatsApp 和 Discord 的例子会越来越普遍。