# NoteBook


# AD

用于启动页的广告，支持本地缓存

目前LaunchScreen.storyboard 是不支持自定义类关联的，如果通过LaunchScreen.storyboard的方式来设置LaunchImage，可以再这里加一句很关键的代码

> [self.window makeKeyAndVisible]; 

在此默默感谢Desgard 大神的项目[DGAdLaunchView](https://github.com/Desgard/DGAdLaunchView)提供了这个思路

为什么说这句代码很关键呢，如果你的App结构是tab-nav,或者 nav，那么通过xib的方式是无法正确显示广告页的，因为你直接在didFinishLaunchingWithOptions是无法获取到keywindow 的。
之前看到一个解决思路是在RootVC对应的那个VC里面的DidAppear里面加载启动广告，但是这会存在页面闪烁的情况。如果提前到ViewWillAppear又会出现广告页被遮挡的问题。这个问题可以在RockerHX大神的 [LaunchScreenAnimation-Storyboard](https://github.com/RockerHX/LaunchScreenAnimation-Storyboard)这个项目中了解更多的信息。

上面添加的这个代码作用也很明朗，提前将window创建好并可见，就可以避免xib加载时在`didFinishLaunchingWithOptions `中keyWindow为null的问题（这里要注意一下，在`didFinishLaunchingWithOptions` 如果不手动指定keyWindow，那么一直到LaunchImage消失，系统是不会自动自定keyWindow的）
顺便提一下，DGAdLaunchView 几乎可以满足常见的业务需求，至于网易新闻那样的广告页，我猜想应该是用自定义VC加转场动画做的，而不单单是一层轻量的View了吧。

***
ps：[XHLaunchAd](https://github.com/CoderZhuXH/XHLaunchAd) 这个项目的广告页支持视频播放。


# MMKit

对YY大神的膜拜项目，主要是在拜读大神的代码过程中对未知的问题进行的一些总结

# MMToast

提示窗一共有顶部、中部、底部三种样式，颜色也是黑底白字，白底黑字，模糊样式三种

# 算法之swift实现

通过swift来实现常见的算法题解，首先来看一下算法中两个比较重要的点

关于算法的更多基础知识可以点击[这里](https://github.com/mumusa/mumuno/blob/master/MarkDown/%E5%B8%B8%E8%A7%81%E7%AE%97%E6%B3%95%E8%A7%A3%E6%9E%90.md)

# MMAvoidCrash

实现了Foundation中基础类的防Crash

> + NSObject
> + NSString/NSMutableString
> + NSAttributeString/NSMutableAttributeString
> + NSArray/NSMutableArray
> + NSDictionary/NSMutableDictionary

# Apache配置

如果哪天手抖不小心删掉了Mac系统自带的Apache的配置文件，[这里](https://github.com/mumusa/mumuno/blob/master/%E7%9B%B8%E5%85%B3%E6%96%87%E6%A1%A3/httpd.conf.txt)是备份
下面这些命令可能会用到

这是vim 操作的退出命令

:wq     保存退出
:q!     强制退出

````Shell
sudo apachectl start   

sudo apachectl stop

sudo apachectl restart

以下命令可以调试出httpd.conf 中不对的信息

sudo apachectl configtest

sudo /usr/sbin/httpd/ -k start  

sudo lsof -iTCP:80 -sTCP:LISTEN  //验证其他程序是否占用80端口

````


# MMExam

纯Swift 练手项目，有一个小坑，在iOS10上`UITableViewCell`手势响应没有问题，但是在iOS11下出现了手势冲突，需要手动解决一下，如果有兴趣可以测试一下。


