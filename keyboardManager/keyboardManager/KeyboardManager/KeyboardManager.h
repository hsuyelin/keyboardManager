#import <Foundation/Foundation.h>

#import "KeyboardInfo.h"

#define MARGIN_KEYBOARD_DEFAULT 10.0f
#define DURATION_ANIMATION 0.15f

@protocol KeyboardManagerProtocol <NSObject>
- (void)adaptiveViewHandleWithAdaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION;
- (void)adaptiveViewHandleWithController:(UIViewController *)viewController adaptiveView:(UIView *)adaptiveView, ...NS_REQUIRES_NIL_TERMINATION;
@end

@interface KeyboardManager : NSObject <KeyboardManagerProtocol>

typedef void (^animateWhenKeyboardAppearBlock) (int appearPostIndex, CGRect keyboardRect, CGFloat keyboardHeight, CGFloat keyboardHeightIncrement);
typedef void (^animateWhenKeyboardDisappearBlock) (CGFloat keyboardHeight);
typedef void (^printKeyboardInfoBlock) (KeyboardManager *keyboardManager, KeyboardInfo *keyboardInfo);
typedef void (^animateWhenKeyboardAppearAutomaticAnimBlock) (KeyboardManager *keyboardUtil);

- (void)setAnimateWhenKeyboardAppearBlock:(animateWhenKeyboardAppearBlock)animateWhenKeyboardAppearBlock;
- (void)setAnimateWhenKeyboardAppearAutomaticAnimBlock:(animateWhenKeyboardAppearAutomaticAnimBlock)animateWhenKeyboardAppearAutomaticAnimBlock;
- (void)setAnimateWhenKeyboardDisappearBlock:(animateWhenKeyboardDisappearBlock)animateWhenKeyboardDisappearBlock;
- (void)setPrintKeyboardInfoBlock:(printKeyboardInfoBlock)printKeyboardInfoBlock;

@end
