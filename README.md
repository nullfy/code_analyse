# NoteBook


# AD

用于启动页的广告，支持本地缓存

目前LaunchScreen是不支持自定义类的，如果通过LaunchScreen.storyBoard的方式来设置LaunchImage，可以再这里加一句很关键的代码
> [self.window makeKeyAndVisible]; 

在此默默感谢Desgard 大神的项目[DGAdLaunchView](https://github.com/Desgard/DGAdLaunchView)提供了这个思路

为什么说这句代码很关键呢，如果你的App结构是tab-nav,或者 nav，那么通过xib的方式是无法正确显示广告页的，因为你直接在didFinishLaunchingWithOptions是无法获取到keywindow 的。
之前看到一个解决思路是在RootVC对应的那个VC里面的DidAppear里面加载启动广告，但是这会存在页面闪烁的情况。如果提前到ViewWillAppear又会出现广告页被遮挡的问题。这个问题可以在RockerHX大神的 [LaunchScreenAnimation-Storyboard](https://github.com/RockerHX/LaunchScreenAnimation-Storyboard)这个项目中了解更多的信息。

上面添加的这个代码作用也很明朗，提前将window创建好并可见，就可以避免xib加载时在didFinishLaunchingWithOptions 中无法获取windown的问题
顺便提一下，DGAdLaunchView 几乎可以满足常见的业务需求，至于网易新闻那样的广告页，我猜想应该是用自定义VC加转场动画做的，而不单单是一层轻量的View了吧。

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


