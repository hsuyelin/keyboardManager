#import "UIView+FindController.h"

@implementation UIView (FindController)

- (void)findControllerWithResultController:(UIViewController **)resultController {
    UIResponder *responder = [self nextResponder];
    if (!responder) {
        return;
    }
    if ([responder isKindOfClass:[UIViewController class]]) {
        *resultController = (UIViewController *)responder;
    } else if ([responder isKindOfClass:[UIView class]]) {
        [(UIView *)responder findControllerWithResultController:resultController];
    }
}

@end
