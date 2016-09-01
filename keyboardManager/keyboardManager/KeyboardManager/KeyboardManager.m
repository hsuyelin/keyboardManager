#import "KeyboardManager.h"

#import "UIView+FindController.h"

static UIView *FIRST_RESPONDER;

@interface KeyboardManager()
/**
 *  键盘分次弹出情况中, 弹出的次数
 */
@property (nonatomic, assign) int appearPostIndex;
/**
 *  键盘信息的对象
 */
@property (nonatomic, strong) KeyboardInfo *keyboardInfo;
/**
 *  是否已经注册监听者
 */
@property (nonatomic, assign) BOOL haveRegisterObserver;
@property (nonatomic, weak)   UIViewController *adaptiveController;
@property (nonatomic, weak)   UIView *adaptiveView;
/**
 *  弹出键盘的Block
 */
@property (nonatomic, copy)   animateWhenKeyboardAppearBlock animateWhenKeyboardAppearBlock;
/**
 *  收起键盘的Block
 */
@property (nonatomic, copy)   animateWhenKeyboardDisappearBlock animateWhenKeyboardDisappearBlock;
/**
 *  输出键盘信息Block
 */
@property (nonatomic, copy)   printKeyboardInfoBlock printKeyboardInfoBlock;
/**
 *  自动处理键盘遮盖事件Block
 */
@property (nonatomic, copy)   animateWhenKeyboardAppearAutomaticAnimBlock animateWhenKeyboardAppearAutomaticAnimBlock;

@end

@implementation KeyboardManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerObserver {
    if (self.haveRegisterObserver == YES) {
        return;
    }
    self.haveRegisterObserver = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)adaptiveViewHandleWithController:(UIViewController *)viewController adaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *adaptiveViewList = [NSMutableArray array];
    [adaptiveViewList addObject:adaptiveView];
    
    va_list var_list;
    va_start(var_list, adaptiveView);
    UIView *view;
    while ((view = va_arg(var_list, UIView *))) {
        [adaptiveViewList addObject:view];
    }
    va_end(var_list);
    
    self.adaptiveController = viewController;
    for (UIView *adaptiveViews in adaptiveViewList) {
        FIRST_RESPONDER = nil;
        UIView *firstResponderView = [self recursionTraverseFindFirstResponderIn:adaptiveViews];
        if (nil != firstResponderView) {
            self.adaptiveView = firstResponderView;
            [self fitKeyboardAutomatically:firstResponderView controllerView:viewController.view keyboardRect:_keyboardInfo.frameEnd];
            break;
        }
    }
}

- (void)adaptiveViewHandleWithAdaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *adaptiveViewList = [NSMutableArray array];
    [adaptiveViewList addObject:adaptiveView];
    
    va_list var_list;
    va_start(var_list, adaptiveView);
    UIView *view;
    while ((view = va_arg(var_list, UIView *))) {
        [adaptiveViewList addObject:view];
    }
    va_end(var_list);
    
    UIViewController *adaptiveController;
    [adaptiveView findControllerWithResultController:&adaptiveController];
    if (adaptiveController) {
        self.adaptiveController = adaptiveController;
    } else {
        NSLog(@"ERROR: Can not find adaptiveView’s Controller");
        return;
    }
    
    for (UIView *adaptiveViews in adaptiveViewList) {
        FIRST_RESPONDER = nil;
        UIView *firstResponderView = [self recursionTraverseFindFirstResponderIn:adaptiveViews];
        if (nil != firstResponderView) {
            self.adaptiveView = firstResponderView;
            [self fitKeyboardAutomatically:firstResponderView controllerView:adaptiveController.view keyboardRect:_keyboardInfo.frameEnd];
            break;
        }
    }
}

- (UIView *)recursionTraverseFindFirstResponderIn:(UIView *)view {
    if ([view isFirstResponder]) {
        FIRST_RESPONDER = view;
    } else {
        for (UIView *subView in view.subviews) {
            if ([subView isFirstResponder]) {
                FIRST_RESPONDER = subView;
                return FIRST_RESPONDER;
            }
            [self recursionTraverseFindFirstResponderIn:subView];
        }
    }
    return FIRST_RESPONDER;
}

- (void)fitKeyboardAutomatically:(UIView *)adaptiveView controllerView:(UIView *)controllerView keyboardRect:(CGRect)keyboardRect {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect convertRect = [adaptiveView.superview convertRect:adaptiveView.frame toView:window];
    if (CGRectGetMinY(keyboardRect) - MARGIN_KEYBOARD_DEFAULT < CGRectGetMaxY(convertRect)) {
        CGFloat signedDiff = CGRectGetMinY(keyboardRect) - CGRectGetMaxY(convertRect) - MARGIN_KEYBOARD_DEFAULT;
        // updateOriginY
        CGFloat newOriginY = CGRectGetMinY(controllerView.frame) + signedDiff;
        controllerView.frame = CGRectMake(controllerView.frame.origin.x, newOriginY, controllerView.frame.size.width, controllerView.frame.size.height);
    }
}

- (void)restoreKeyboardAutomatically {
    [self textViewHandle];
    CGRect tempFrame = self.adaptiveController.view.frame;
    tempFrame.origin.y = 0.0f;
    self.adaptiveController.view.frame = tempFrame;
}

- (void)textViewHandle {
    if ([_adaptiveView isKindOfClass:[UITextView class]]) {
        [(UITextView *)_adaptiveView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - 重写KeyboardInfo set方法，调用animationBlock
- (void)setKeyboardInfo:(KeyboardInfo *)keyboardInfo {
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    _keyboardInfo = keyboardInfo;
    if(!keyboardInfo.isSameAction || (keyboardInfo.heightIncrement != 0)) {
        
        [UIView animateWithDuration:keyboardInfo.animationDuration animations:^{
            switch (keyboardInfo.action) {
                case KeyboardActionShow:
                    if(self.animateWhenKeyboardAppearBlock != nil) {
                        self.animateWhenKeyboardAppearBlock(++self.appearPostIndex, keyboardInfo.frameEnd, keyboardInfo.frameEnd.size.height, keyboardInfo.heightIncrement);
                    } else if (self.animateWhenKeyboardAppearAutomaticAnimBlock != nil) {
                        self.animateWhenKeyboardAppearAutomaticAnimBlock(self);
                    }
                    break;
                case KeyboardActionHide:
                    if(self.animateWhenKeyboardDisappearBlock != nil) {
                        self.animateWhenKeyboardDisappearBlock(keyboardInfo.frameEnd.size.height);
                        self.appearPostIndex = 0;
                    } else {
                        // auto restore
                        [self restoreKeyboardAutomatically];
                    }
                    break;
                default:
                    break;
            }
            [CATransaction commit];
        }completion:^(BOOL finished) {
            if(self.printKeyboardInfoBlock != nil && self.keyboardInfo != nil) {
                self.printKeyboardInfoBlock(self, keyboardInfo);
            }
        }];
    }
}

- (void)triggerAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.keyboardInfo = _keyboardInfo;
    });
}

#pragma mark - 重写Block的set方法, 懒加载方式注册观察者
- (void)setAnimateWhenKeyboardAppearBlock:(animateWhenKeyboardAppearBlock)animateWhenKeyboardAppearBlock {
    _animateWhenKeyboardAppearBlock = animateWhenKeyboardAppearBlock;
    [self registerObserver];
}

- (void)setAnimateWhenKeyboardAppearAutomaticAnimBlock:(animateWhenKeyboardAppearAutomaticAnimBlock)animateWhenKeyboardAppearAutomaticAnimBlock {
    _animateWhenKeyboardAppearAutomaticAnimBlock = animateWhenKeyboardAppearAutomaticAnimBlock;
    [self registerObserver];
}

- (void)setAnimateWhenKeyboardDisappearBlock:(animateWhenKeyboardDisappearBlock)animateWhenKeyboardDisappearBlock {
    _animateWhenKeyboardDisappearBlock = animateWhenKeyboardDisappearBlock;
    [self registerObserver];
}

- (void)setPrintKeyboardInfoBlock:(printKeyboardInfoBlock)printKeyboardInfoBlock {
    _printKeyboardInfoBlock = printKeyboardInfoBlock;
    [self registerObserver];
}

#pragma mark - 键盘通知事件处理
- (void)keyboardWillShow:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionShow];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if(self.keyboardInfo.action == KeyboardActionShow) {
        [self handleKeyboard:notification keyboardAction:KeyboardActionShow];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionHide];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.keyboardInfo = nil;
}

#pragma mark - 处理键盘事件
- (void)handleKeyboard:(NSNotification *)notification keyboardAction:(KeyboardAction)keyboardAction {
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    NSDictionary *infoDict = [notification userInfo];
    CGRect frameBegin = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat previousHeight;
    if(self.keyboardInfo.frameEnd.size.height > 0) {
        previousHeight = self.keyboardInfo.frameEnd.size.height;
    }else {
        previousHeight = 0;
    }
    
    CGFloat heightIncrement = frameEnd.size.height - previousHeight;
    
    BOOL isSameAction;
    if(self.keyboardInfo.action == keyboardAction) {
        isSameAction = YES;
    }else {
        isSameAction = NO;
    }
    
    KeyboardInfo *info = [[KeyboardInfo alloc] init];
    [info fillKeyboardInfoWithDuration:DURATION_ANIMATION frameBegin:frameBegin frameEnd:frameEnd heightIncrement:heightIncrement action:keyboardAction isSameAction:isSameAction];
    
    self.keyboardInfo = info;
}

@end
