1. jsBridge交互：使用WKWebView新控件、具体js交互协商，后续根据业务完善
2. 列表组件化：tableview和CollectionView
3. Debug：Flex、CPU检测、fb工具

1. App模块化架构方案，统一文档输出。
	> * 阶段一：本周周末抽离出架构大纲。
	> * 阶段二：下周细化大纲，输出架构图以及文档
	> * 阶段三：后续业务开发前以及开发中，实施架构文档内容，逐步丰富完善​
	
	
---

1. 目的主要为业务


2. 项目中，warning的处理态度


---
1. 业务
2. 网络模块：基于Net库，优化网络使用而封装的模块（含网络请求、网络可达性检测等）
3. Net库：Pods资源，如AFNetworking
4. 扩展：类似NSString、NSArray、NSDic效率、功能性扩展，UIKit的各种扩展
5. 系统信息：一些宏定义、系统信息相关的接口整合
6. runtime：swizzling、AOP技术模块的文件整合
7. Events：监听相关模块：noti名称定义和处理时机
8. Service：全局服务类，如LBS、Scheme路由、Page路由、APP更新服务、埋点、Push，timeasyc等
9. UIs：通用的UIView、UIcontrol以及其它定制控件、Splash，引导页都属于该模块
10. Debug工具：基于FLEX或者其它效率检测工具的封装整合
11. Loader加载器：APP启动初始化流程，启动各模块
12. Pattern模块：MVP等设计模式
13. Base Ctrls：基类Ctrls
14. Resource：获取资源文件的类别，以及各种资源文件



资源：

1. https://nicolastinkl.gitbooks.io/maker/content/iosteo.html
2. 