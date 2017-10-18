//
//  MMRootViewController.m
//  PracticeKit
//
//  Created by 李晓东 on 2017/10/16.
//  Copyright © 2017年 Xiaodong. All rights reserved.
//

#import "MMRootNavigationController.h"


@interface MMContainerController ()
@property (nonatomic, strong) __kindof UIViewController *contentViewController;
@property (nonatomic, strong) UINavigationController *containerNavigationController;
+ (instancetype)containerControllerWithController:(UIViewController *)controller;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)YesOrNo;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)YesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle;
- (instancetype)initWithController:(UIViewController *)controller;
- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass;
@end


static inline UIViewController *MMSafeUnwrapViewController(UIViewController *controller) {
    if ([controller isKindOfClass:[MMContainerController class]]) {
        return ((MMContainerController *)controller).contentViewController;
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *MMSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder, UIBarButtonItem *backItem, NSString *backTitle) {
    if (![controller isKindOfClass:[MMContainerController class]]) {
        return [MMContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder
                                                      backBarButtonItem:backItem
                                                              backTitle:backTitle];
    }
    return controller;
}
__attribute((overloadable)) static inline UIViewController *MMSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder) {
    if (![controller isKindOfClass:[MMContainerController class]]) {
        return [MMContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder];
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *MMSafeWrapViewController(UIViewController *controller, Class navigationBarClass) {
    return MMSafeWrapViewController(controller, navigationBarClass, NO);
}

@implementation MMContainerController

+ (instancetype)containerControllerWithController:(UIViewController *)controller {
    return [[self alloc] initWithController:controller];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass {
    return [[self alloc] initWithController:controller];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)YesOrNo{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:YesOrNo];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)YesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle {
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:YesOrNo
                          backBarButtonItem:backItem
                                  backTitle:backTitle];
}

- (instancetype)initWithContentController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        [self addChildViewController:self.contentViewController];
        [self.contentViewController didMoveToParentViewController:self];
        
        /**
         [self addChildViewController: vc];
         [vc willMoveToParentViewController: self]; //(自动调用 省略)
         [vc didMoveToParentViewController: self];  //可省略
         
         [vc willMoveToParentViewController: nil];
         [vc removeFromParentViewController];
         [vc didMoveToParentViewController: nil];   //(自动调用 省略)
         
         [vc willMoveToParentViewController: nil];
         [self transitionFromViewController: vc toViewController: secondVC];
         [secondVC didMoveToParentViewController: self];
         */
        
    }
    return self;
}

- (instancetype)initWithController:(UIViewController *)controller {
    return [self initWithController:controller navigationBarClass:nil];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass {
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:NO];
}

- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)YesOrNo {
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:YesOrNo
                  backBarButtonItem:nil
                          backTitle:nil];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
         withPlaceholderController:(BOOL)YesOrNo
                 backBarButtonItem:(UIBarButtonItem *)backItem
                         backTitle:(NSString *)backTitle {
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        self.containerNavigationController = [[MMContainerNavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:nil];
        if (YesOrNo) {
            UIViewController *vc = [UIViewController new];
            vc.title = backTitle;
            vc.navigationItem.backBarButtonItem = backItem;
            self.containerNavigationController.viewControllers = @[vc, controller];
            NSLog(@"placeholderRoot----%@",self.containerNavigationController.viewControllers);
        } else {
            self.containerNavigationController.viewControllers = @[controller];
        }
        
        [self addChildViewController:self.containerNavigationController];
        [self.containerNavigationController didMoveToParentViewController:self];
    }
    NSLog(@"containerVC_parent-----%@",self.parentViewController);
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (BOOL)becomeFirstResponder {
    return [self.contentViewController becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return [self.contentViewController canBecomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.contentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.contentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)shouldAutorotate {
    return self.contentViewController.shouldAutorotate;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.contentViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.contentViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIView *)rotatingHeaderView {
    return self.contentViewController.rotatingHeaderView;
}

- (nullable UIView *)rotatingFooterView {
    return self.contentViewController.rotatingFooterView;
}

- (BOOL)hidesBottomBarWhenPushed {
    return self.contentViewController.hidesBottomBarWhenPushed;
}

- (NSString *)title {
    return self.contentViewController.title;
}

- (UITabBarItem *)tabBarItem {
    return self.contentViewController.tabBarItem;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    return [self.contentViewController viewControllerForUnwindSegueAction:action
                                                       fromViewController:fromViewController
                                                               withSender:sender];
}

#if MM_INTERACTIVE_PUSH
- (nullable __kindof UIViewController *)mm_nextSiblingController {
    return self.contentViewController.mm_nextSiblingController;
}
#endif
@end


@interface UIViewController(MMContainerNavigationController)
@property (nonatomic, assign, readonly) BOOL mm_hasSetInteractivePop;
@end
@implementation UIViewController(MMContainerNavigationController)
- (BOOL)mm_hasSetInteractivePop {
    
    BOOL res = objc_getAssociatedObject(self, @selector(mm_disableInteractivePop));
    NSLog(@"containerNavVC_hasPop---%u",res);
    return  res;
}
@end



@implementation MMContainerNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithNavigationBarClass:rootViewController.mm_navigationBarClass toolbarClass:nil];
    if (self) {
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = NO;
    if (self.mm_navigationController.transiferNavigationBarAttributes) {
        UINavigationBar *currentBar = self.navigationBar;
        UINavigationBar *wrapBar = self.navigationController.navigationBar;
        
        currentBar.translucent = wrapBar.isTranslucent;
        currentBar.tintColor = wrapBar.tintColor;
        currentBar.barTintColor = wrapBar.barTintColor;
        currentBar.barStyle = wrapBar.barStyle;
        currentBar.backgroundColor = wrapBar.backgroundColor;
        
        [currentBar setBackgroundImage:[wrapBar backgroundImageForBarMetrics:UIBarMetricsDefault]
                         forBarMetrics:UIBarMetricsDefault];
        
        [currentBar setTitleVerticalPositionAdjustment:[wrapBar titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault]
                                         forBarMetrics:UIBarMetricsDefault];
        
        currentBar.titleTextAttributes = wrapBar.titleTextAttributes;
        currentBar.shadowImage = wrapBar.shadowImage;
        currentBar.backIndicatorImage = wrapBar.backIndicatorImage;
        currentBar.backIndicatorTransitionMaskImage = wrapBar.backIndicatorTransitionMaskImage;
    }
    [self.view layoutIfNeeded];
}

- (UITabBarController *)tabBarController {
    UITabBarController *tab = [super tabBarController];
    MMRootNavigationController *nav = self.mm_navigationController;
    if (tab) {
        if (nav.tabBarController != tab) return tab;
        else {
            __block BOOL res;
            [nav.mm_viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                res = obj.hidesBottomBarWhenPushed;
            }];
            
            return !tab.tabBar.isTranslucent || res ? nil : tab;
        }
    }
    return nil;
}

- (NSArray *)viewControllers {
    if (self.navigationController) {
        if ([self.navigationController isKindOfClass:[MMRootNavigationController class]]) {
            return self.mm_navigationController.mm_viewControllers;
        }
    }
    return [super viewControllers];
}

#pragma mark    是否有navigationController
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    if (self.navigationController) {
        return [self.navigationController viewControllerForUnwindSegueAction:action
                                                          fromViewController:self.parentViewController
                                                                  withSender:sender];
    }
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

- (NSArray<UIViewController *> *)allowedChildViewControllersForUnwindingFromSource:(UIStoryboardUnwindSegueSource *)source {
    if (self.navigationController) {
        return [self.navigationController allowedChildViewControllersForUnwindingFromSource:source];
    }
    return [super allowedChildViewControllersForUnwindingFromSource:source];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) {
        return [self.navigationController popViewControllerAnimated:animated];
    }
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (self.navigationController) return [self.navigationController popToRootViewControllerAnimated:animated];
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController) return [self.navigationController popToViewController:viewController animated:animated];
    return [super popToViewController:viewController animated:animated];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    if (self.navigationController) {
        [self.navigationController setViewControllers:viewControllers
                                             animated:animated];
    } else {
        [super setViewControllers:viewControllers animated:animated];
    }
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (self.navigationController)
        self.navigationController.delegate = delegate;
    else
        [super setDelegate:delegate];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    if (!self.visibleViewController.mm_hasSetInteractivePop) {
        self.visibleViewController.mm_disableInteractivePop = hidden;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.topViewController preferredStatusBarUpdateAnimation];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.navigationController respondsToSelector:aSelector]) return self.navigationController;
    return nil;
}
@end


@interface MMRootNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<UINavigationControllerDelegate> mm_delegate;
@property (nonatomic, copy) void(^animationBlock)(BOOL finished);
@end

@implementation MMRootNavigationController

- (void)onBack:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)_commonInit {
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.viewControllers = [super viewControllers];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:[[MMContainerController alloc] initWithContentController:rootViewController]];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [super setDelegate:self];
    [super setNavigationBarHidden:YES animated:NO];
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    UIViewController *vc = [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
    if (!vc) {
        NSInteger index = [self.viewControllers indexOfObject:fromViewController];
        if (index != NSNotFound) {
            for (NSInteger i = index-1; i >= 0; i--) {
                vc = [self.viewControllers[i] viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
                if (vc) break;
            }
        }
    }
    return vc;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        UIViewController *currentlast = MMSafeUnwrapViewController(self.viewControllers.lastObject);
        [super pushViewController:MMSafeWrapViewController(viewController,
                                                           viewController.mm_navigationBarClass,
                                                           self.useSystemBackBarButtonItem,
                                                           currentlast.navigationItem.backBarButtonItem,
                                                           currentlast.title)
                         animated:animated];
    } else {
        [super pushViewController:MMSafeWrapViewController(viewController,
                                                           viewController.mm_navigationBarClass)
                         animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return MMSafeUnwrapViewController([super popViewControllerAnimated:animated]);
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    __block NSMutableArray *arr = @[].mutableCopy;
    [[super popToRootViewControllerAnimated:animated] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:MMSafeUnwrapViewController(obj)];
    }];
    return arr.copy;
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    __block UIViewController *contarollerToPop = nil;
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (MMSafeUnwrapViewController(obj) == viewController) {
            contarollerToPop = obj;
            *stop = YES;
        }
    }];
    if (contarollerToPop) {
        __block NSMutableArray *arr = @[].mutableCopy;
        [[super popToViewController:contarollerToPop animated:animated] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arr addObject:MMSafeUnwrapViewController(obj)];
        }];
        return arr.copy;
    }
    return nil;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    __block NSMutableArray *arr = @[].mutableCopy;
    
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.useSystemBackBarButtonItem && idx > 0) {
            [arr addObject:MMSafeWrapViewController(obj,
                                                    obj.mm_navigationBarClass,
                                                    self.useSystemBackBarButtonItem,
                                                    viewControllers[idx - 1].navigationItem.backBarButtonItem,
                                                    viewControllers[idx - 1].title)];
        } else {
            [arr addObject:MMSafeWrapViewController(obj, obj.mm_navigationBarClass)];
        }
    }];
    [super setViewControllers:arr.copy animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.mm_delegate = delegate;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (nullable UIView *)rotatingHeaderView {
    return self.topViewController.rotatingHeaderView;
}

- (nullable UIView *)rotatingFooterView {
    return self.topViewController.rotatingFooterView;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) return YES;
    return [self.mm_delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.mm_delegate;
}

- (UIViewController *)mm_topViewController {
    return MMSafeUnwrapViewController([super topViewController]);
}
- (NSArray<__kindof UIViewController *> *)mm_viewControllers {
    __block NSMutableArray *arr = @[].mutableCopy;
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:MMSafeUnwrapViewController(obj)];
    }];
    return arr.copy;
}

- (void)removeViewController:(UIViewController *)controller {
    [self removeViewController:controller animated:NO];
}

- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag {
    NSMutableArray<__kindof UIViewController *> *controllers = [self.viewControllers mutableCopy];
    __block UIViewController *controllerToRemove = nil;
    [controllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (MMSafeUnwrapViewController(obj) == controller) {
            controllerToRemove = obj;
            *stop = YES;
        }
    }];
    if (controllerToRemove) {
        [controllers removeObject:controllerToRemove];
        [super setViewControllers:[NSArray arrayWithArray:controllers] animated:flag];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) self.animationBlock(NO);
    self.animationBlock = block;
    [self pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) self.animationBlock(NO);
    self.animationBlock = block;
    UIViewController *vc = [self popViewControllerAnimated:animated];
    if (!vc) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return vc;
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) self.animationBlock(NO);
    self.animationBlock = block;
    NSArray <__kindof UIViewController *> *arr = [self popToViewController:viewController animated:animated];
    if (!arr.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return arr;
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControlleranimated:(BOOL)animated complete:(void (^)(BOOL))block {
    if (self.animationBlock) self.animationBlock(NO);
    self.animationBlock = block;
    NSArray <__kindof UIViewController *> *arr = [self popToRootViewControllerAnimated:animated];
    if (!arr.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return arr;
}


@end
