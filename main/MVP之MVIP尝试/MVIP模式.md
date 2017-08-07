## 提要

* MVIP模式属于MVP的一种尝试。即在View和Presenter之间添加了一个交互层（Interactor），主要来处理它们之间的绑定操作。

## 一、View

### 1. Render View

具体视图Render：如UIButton、UITextView、UITableView（含协议实现）添加

### 2. Order 外放
Action、render data具体实现交于Interactor：如UIButton Action、UITableView数据获取等。


## 二、Interactor

### Order：action + render data

1. action：如UIButton的Action具体实现、UITableView的点击事件
2. render data：与Data+View相关，如UITextView的占位符、UITableView的数据回执


## 三、Presenter

### 响应Interactor

1. action：需要集合业务逻辑的功能
2. ret data：具体的数据请求工作

	> 数据来源：Model层

## 四、Model

* 涵盖Entity、Net、Cache等功能，具体略

----

## 具体实现细节

### Ⅰ、View
1. 创建Interactor，并执行初始化
2. Interactor挂载View，即弱引用View
3. Action、Render data行为注入。

	> 具体行为实现在Interactor中
	
### Ⅱ、Interactor

1. 初始化：创建Presenter，并初始化之
2. Presenter挂载Interactor，即弱引用Interactor。
3. Presenter实现代理
3. action、render data实现：响应View

	> 是否需要业务逻辑部分协助，是具体情况而定。如render data一般获取需要Presenter协助。
	
4. Presenter通过业务处理，将结果回执。

	> 1. 通过委托方式返回。
	> 2. 回执结果，可能进一步展示在View上，此时可能会调动View。
	
	
### Ⅲ、Presenter

1. 初始化工作.
2. 业务逻辑执行，响应自Interactor的事件。
3. 回执结果（代理方式、Block）

### Ⅳ、Model

* 略