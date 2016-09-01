#import "KeyboardInfo.h"

@implementation KeyboardInfo

- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction {
    self.animationDuration = duration;
    self.frameBegin = frameBegin;
    self.frameEnd = frameEnd;
    self.heightIncrement = heightIncrement;
    self.action = action;
    self.isSameAction = isSameAction;
}

@end
