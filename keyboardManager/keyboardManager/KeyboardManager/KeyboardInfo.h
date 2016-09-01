#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum _KeyboardAction {
    KeyboardActionDefault = 0,
    KeyboardActionHide = 1 << 0,
    KeyboardActionShow = 1 << 1
} KeyboardAction;

@interface KeyboardInfo : NSObject

@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) CGRect frameBegin;
@property (assign, nonatomic) CGRect frameEnd;
@property (assign, nonatomic) CGFloat heightIncrement;
@property (assign, nonatomic) KeyboardAction action;
@property (assign, nonatomic) BOOL isSameAction;

/**
 *  为KeyboardInfo各属性赋值
 *
 *  @param duration        响应动画的过程时长
 *  @param frameBegin      触发键盘事件前键盘frame
 *  @param frameEnd        变化后键盘frame
 *  @param heightIncrement 单次键盘变化增量
 *  @param action          键盘事件枚举
 *  @param isSameAction    是否同一种动作
 */
- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction;

@end
