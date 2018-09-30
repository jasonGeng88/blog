# 彻底搞懂 JS 中 this 机制
> 摘要：本文属于原创，欢迎转载，转载请保留出处：[https://github.com/jasonGeng88/blog](https://github.com/jasonGeng88/blog)

## 目录
* this 是什么
* this 的四种绑定规则
* 绑定规则的优先级
* 绑定例外
* 扩展：箭头函数

## this 是什么

理解this之前， 先纠正一个观点，**this 既不指向函数自身，也不指函数的词法作用域**。如果仅通过this的英文解释，太容易产生误导了。它实际是在函数被调用时才发生的绑定，也就是说this具体指向什么，取决于你是怎么调用的函数。

## this 的四种绑定规则
this的4种绑定规则分别是：默认绑定、隐式绑定、显示绑定、new 绑定。优先级从低到高。

### 默认绑定
什么叫默认绑定，即没有其他绑定规则存在时的默认规则。这也是函数调用中最常用的规则。

来看这段代码： 

```js
function foo() { 
	console.log( this.a );
}

var a = 2; 
foo(); //打印的是什么？
```

```foo()``` 打印的结果是2。

因为foo()是直接调用的（独立函数调用），没有应用其他的绑定规则，这里进行了默认绑定，将全局对象绑定this上，所以this.a 就解析成了全局变量中的a，即2。

***注意：在严格模式下（strict mode），全局对象将无法使用默认绑定，即执行会报undefined的错误***

```js
function foo() { 
	"use strict";
   console.log( this.a );
}

var a = 2; 
foo(); // Uncaught TypeError: Cannot read property 'a' of undefined
```

***

### 隐式绑定
除了直接对函数进行调用外，有些情况是，函数的调用是在某个对象上触发的，即调用位置上存在上下文对象。

```js
function foo() { 
	console.log( this.a );
}

var a = 2;

var obj = { 
	a: 3,
	foo: foo 
};

obj.foo(); // ?
```

```obj.foo()``` 打印的结果是3。

这里foo函数被当做引用属性，被添加到obj对象上。这里的调用过程是这样的：

获取obj.foo属性 -> 根据引用关系找到foo函数，执行调用

所以这里对foo的调用存在上下文对象obj，this进行了隐式绑定，即this绑定到了obj上，所以this.a被解析成了obj.a，即3。

#### 多层调用链

```js
function foo() { 
    console.log( this.a );
}

var a = 2;

var obj1 = { 
    a: 4,
    foo: foo 
};

var obj2 = { 
    a: 3,
    obj1: obj1
};

obj2.obj1.foo(); //?
```

```obj2.obj1.foo()``` 打印的结果是4。

同样，我们看下函数的调用过程：

先获取obj2.obj1 -> 通过引用获取到obj1对象，再访问 obj1.foo -> 最后执行foo函数调用

这里调用链不只一层，存在obj1、obj2两个对象，那么隐式绑定具体会绑哪个对象。这里原则是获取最后一层调用的上下文对象，即obj1，所以结果显然是4（obj1.a）。

#### 隐式丢失（函数别名）

***注意：这里存在一个陷阱，大家在分析调用过程时，要特别小心***

先看个代码：

```js
function foo() { 
	console.log( this.a );
}

var a = 2;

var obj = { 
	a: 3,
	foo: foo 
};

var bar = obj.foo;
bar(); //?
```

<font color="red">**```bar()``` 打印的结果是2。**</font>

为什么会这样，obj.foo 赋值给bar，那调用```bar()```为什么没有触发隐式绑定，使用的是默认绑定呢。

这里有个概念要理解清楚，obj.foo 是引用属性，赋值给bar的实际上就是foo函数（即：bar指向foo本身）。

那么，实际的调用关系是：通过bar找到foo函数，进行调用。整个调用过程并没有obj的参数，所以是默认绑定，全局属性a。

#### 隐式丢失（回调函数）

```js
function foo() { 
	console.log( this.a );
}

var a = 2;

var obj = { 
	a: 3,
	foo: foo 
};

setTimeout( obj.foo, 100 ); // ？
```

<font color="red">**打印的结果是2。**</font>

同样的道理，虽然参传是```obj.foo```，因为是引用关系，所以传参实际上传的就是foo对象本身的引用。对于```setTimeout```的调用，还是 setTimeout -> 获取参数中foo的引用参数 -> 执行 foo 函数，中间没有obj的参与。这里依旧进行的是默认绑定。

***

### 显示绑定
相对隐式绑定，this值在调用过程中会动态变化，可是我们就想绑定指定的对象，这时就用到了显示绑定。

显示绑定主要是通过改变对象的prototype关联对象，这里不展开讲。具体使用上，可以通过这两个方法call(...)或apply(...)来实现（大多数函数及自己创建的函数默认都提供这两个方法）。

***call与apply是同样的作用，区别只是其他参数的设置上***

```js
function foo() { 
	console.log( this.a );
}

var a = 2;

var obj1 = { 
	a: 3,
};

var obj2 = { 
	a: 4,
};
foo.call( obj1 ); // ?
foo.call( obj2 ); // ?
```

打印的结果是3, 4。

这里因为显示的申明了要绑定的对象，所以this就被绑定到了obj上，打印的结果自然就是obj1.a 和obj2.a。

#### 硬绑定

```js
function foo() { 
	console.log( this.a );
}

var a = 2;

var obj1 = { 
	a: 3,
};

var obj2 = { 
	a: 4,
};

var bar = function(){
	foo.call( obj1 );
}

bar(); // 3
setTimeout( bar, 100 ); // 3

bar.call( obj2 ); // 这是多少
```

***前面两个（函数别名、回调函数）打印3，因为显示绑定了，没什么问题。***

最后一个打印是3。

这里需要注意下，虽然bar被显示绑定到obj2上，对于bar，function(){...} 中的this确实被绑定到了obj2，而foo因为通过```foo.call( obj1 )```已经显示绑定了obj1，所以在foo函数内，this指向的是obj1，不会因为bar函数内指向obj2而改变自身。所以打印的是obj1.a（即3）。

***

### new 绑定
***js中的new操作符，和其他语言中（如JAVA）的new机制是不一样的。js中，它就是一个普通函数调用，只是被new修饰了而已。***

使用new来调用函数，会自动执行如下操作：

1. 创建一个全新的对象。
2. 这个新对象会被执行[[原型]]连接。
3. 这个新对象会绑定到函数调用的this。
4. 如果函数没有返回其他对象,那么new表达式中的函数调用会自动返回这个新对象。

从第三点可以看出，this指向的就是对象本身。

看个代码：

```js
function foo(a) { 
	this.a = a;
}

var a = 2;

var bar1 = new foo(3);
console.log(bar1.a); // ?

var bar2 = new foo(4);
console.log(bar2.a); // ?
```

最后一个打印是3, 4。

因为每次调用生成的是全新的对象，该对象又会自动绑定到this上，所以答案显而易见。

## 绑定规则优先级
上面也说过，这里在重复一下。优先级是这样的，以按照下面的顺序来进行判断:
1. 函数是否在new中调用(new绑定)?如果是的话this绑定的是新创建的对象。
     
     var bar = new foo()
2. 函数是否通过call、apply(显式绑定)或者硬绑定调用?如果是的话,this绑定的是 指定的对象。
     
     var bar = foo.call(obj2)
3. 函数是否在某个上下文对象中调用(隐式绑定)?如果是的话,this绑定的是那个上下文对象。
     
     var bar = obj1.foo()
4. 如果都不是的话,使用默认绑定。如果在严格模式下,就绑定到undefined,否则绑定到 全局对象。
     
     var bar = foo()

## 规则例外

在显示绑定中，对于null和undefined的绑定将不会生效。

代码如下：

```js
function foo() { 
	console.log( this.a );
}
var a = 2;
foo.call( null ); // 2
foo.call( undefined ); // 2
```

这种情况主要是用在不关心this的具体绑定对象（用来忽略this），而传入null实际上会进行默认绑定，导致函数中可能会使用到全局变量，与预期不符。

所以对于要忽略this的情况，可以传入一个空对象ø，该对象通过```Object.create(null)```创建。这里不用{}的原因是，ø是真正意义上的空对象，它不创建Object.prototype委托，{}和普通对象一样，有原型链委托关系。

***1. 这里传null的一种具体使用场景是函数柯里化的使用***


## 扩展：箭头函数
最后，介绍一下ES6中的箭头函数。通过“=>”而不是function创建的函数，叫做箭头函数。它的this绑定取决于外层（函数或全局）作用域。

### case 1 (正常调用)
* 普通函数

```js
function foo(){ 	
    console.log( this.a );
}

var a = 2;

var obj = { 
    a: 3,
    foo: foo 
};

obj.foo(); //3
```

* 箭头函数

```js
var foo = () => { 	
    console.log( this.a );
}

var a = 2;

var obj = { 
    a: 3,
    foo: foo 
};

obj.foo(); //2
foo.call(obj); //2 ，箭头函数中显示绑定不会生效
```


### case 2 （函数回调）
* 普通函数

```js
function foo(){ 
	return function(){
		console.log( this.a );
	}	
}

var a = 2;

var obj = { 
    a: 3,
    foo: foo 
};

var bar = obj.foo();
bar(); //2
```

* 箭头函数

```js
function foo(){ 
	return () => {
		console.log( this.a );
	}	
}



var a = 2;

var obj = { 
    a: 3,
    foo: foo 
};

var bar = obj.foo();
bar(); //3
```

通过上面两个列子，我们看到箭头函数的this绑定<font color="red">**只取决于外层（函数或全局）的作用域**</font>，对于前面的4种绑定规则是不会生效的。它也是作为this机制的一种替换，解决之前this绑定过程各种规则带来的复杂性。

***注意：对于ES6之前，箭头函数的替换版本是这样的***

```js
// es6
function foo(){ 
    return () => {
        console.log( this.a );
    }   
}

var a = 2;

var obj = { 
    a: 3,
    foo: foo 
};

var bar = obj.foo();
bar(); //3
```

通过上面两个列子，我们看到箭头函数的this绑定<font color="red">**只取决于外层（函数或全局）的作用域**</font>，对于前面的4种绑定规则是不会生效的。它也是作为this机制的一种替换，解决之前this绑定过程各种规则带来的复杂性。

***注意：对于ES6之前，箭头函数的替换版本是这样的***

```js
// es6
function foo(){ 
    return () => {
        console.log( this.a );
    }   
}

// es6之前的替代方法
function foo(){ 
	 var self = this;
    return () => {
        console.log( self.a );
    }   
}
```

## 总结
我们在使用js的过程中，对于this的理解往往觉得比较困难，再调试过程中有时也会出现一些不符合预期的现象。很多时候，我们都是通过一些变通的方式（如：使用具体对象替换this）来规避的问题。可问题一直存在那儿，我们没有真正的去理解和解决它。

本文主要参考了《你不知道的JavaScript（上卷）》，对this到底是什么，具体怎么绑定的，有什么例外情况以及ES6中的一个优化方向，来彻底搞清楚我们一直使用的this到底是怎么玩的。






