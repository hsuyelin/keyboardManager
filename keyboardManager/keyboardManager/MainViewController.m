#import "MainViewController.h"

#import "UIColor+HexString.h"
#import "KeyboardManager.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCALE_WIDTH_L SCREEN_WIDTH / 667.0
#define SCALE_HEIGHT_L SCREEN_HEIGHT / 375.0

#define SCALE_WIDTH_P SCREEN_WIDTH / 375.0
#define SCALE_HEIGHT_P SCREEN_HEIGHT / 667.0

#define WeakSelf __weak typeof(self) weakSelf = self;

@interface MainViewController() <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) KeyboardManager *keyboardManager;

@property (nonatomic, strong) UIButton *navControlButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialData];
    [self configUI];
    [self showInput];
    [self detectOrientation];
}

#pragma mark - 初始化数据
- (void)initialData {
    _accountTextField.delegate = self;
    _pwdTextField.delegate = self;
    
    [self configKeyBoardRespond];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    // 增加监听，当屏幕旋转时感知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 配置键盘事件
- (void)configKeyBoardRespond {
    self.keyboardManager = [[KeyboardManager alloc] init];
    WeakSelf
    [self.keyboardManager setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(KeyboardManager *keyboardManager) {
        [weakSelf.keyboardManager adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.accountTextField, weakSelf.pwdTextField, nil];
    }];
    
    // get keyboard infomation
//    [self.keyboardManager setPrintKeyboardInfoBlock:^(KeyboardManager *keyboardManager, KeyboardInfo *keyboardInfo) {
//        NSLog(@"keyboard -> animationDuration: %f", keyboardInfo.animationDuration);
//        NSLog(@"keyboard -> frameBegin: x -> %f y -> %f", keyboardInfo.frameBegin.origin.x, keyboardInfo.frameBegin.origin.y);
//        NSLog(@"keyboard -> frameEnd: x -> %f y -> %f", keyboardInfo.frameEnd.origin.x, keyboardInfo.frameEnd.origin.y);
//        NSLog(@"keyboard -> heightIncrement: %f", keyboardInfo.heightIncrement);
//    }];
}


#pragma mark - UI
- (void)configUI {
    self.title = @"Keyboard Manager";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0f],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _bgImageView.image = [UIImage imageNamed:@"BG3"];
    [self.view addSubview:_bgImageView];
    
    _navControlButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 100, self.view.center.y - 25, 200, 50)];
    [_navControlButton setTitle:@"Hidden navigationBar" forState:UIControlStateNormal];
    _navControlButton.titleLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:15.0f];
    _navControlButton.backgroundColor = [UIColor colorWithHexString:@"#F7941D"];
    _navControlButton.layer.cornerRadius = 3;
    _navControlButton.tag = 0;
    [self.view addSubview:_navControlButton];
    [_navControlButton addTarget:self action:@selector(navControlOnclick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)navControlOnclick {
    _navControlButton.tag ++;
    
    if (_navControlButton.tag % 2 == 0) {
        [_navControlButton setTitle:@"Hidden navigationBar" forState:UIControlStateNormal];
        self.navigationController.navigationBar.hidden = NO;
    }else {
        [_navControlButton setTitle:@"show navigationBar" forState:UIControlStateNormal];
        self.navigationController.navigationBar.hidden = YES;
    }

}

- (void)showInput {
    
    _accountTextField = [[UITextField alloc] init];
    _accountTextField.backgroundColor = [UIColor whiteColor];
    _accountTextField.placeholder = @"account";
    _accountTextField.font = [UIFont fontWithName:@"PingFang-SC-Regular" size:14.0f];
    _accountTextField.textColor = [UIColor colorWithHexString:@"#B3B3B3"];
    _accountTextField.borderStyle = UITextBorderStyleNone;
    _accountTextField.textAlignment = NSTextAlignmentCenter;
    _accountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountTextField.layer.cornerRadius = 6.0f;
    _accountTextField.layer.masksToBounds = YES;
    
    [self.view addSubview:_accountTextField];
    
    _pwdTextField = [[UITextField alloc] init];
    _pwdTextField.placeholder = @"password";
    _pwdTextField.secureTextEntry = YES;
    _pwdTextField.font = [UIFont fontWithName:@"PingFang-SC-Regular" size:14.0f];
    _pwdTextField.textColor = [UIColor colorWithHexString:@"#B3B3B3"];
    _pwdTextField.borderStyle = UITextBorderStyleNone;
    _pwdTextField.textAlignment = NSTextAlignmentCenter;
    _pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _pwdTextField.backgroundColor = [UIColor whiteColor];
    _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pwdTextField.layer.cornerRadius = 6.0f;
    _pwdTextField.layer.masksToBounds = YES;
    
    [self.view addSubview:_pwdTextField];
}

#pragma mark - 设置屏幕旋转事件
- (void)detectOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        _bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgImageView.image = [UIImage imageNamed:@"BG3"];
        
        _accountTextField.frame = CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH - 161 * 2)) / 2, 60.0f, SCREEN_WIDTH - 161 * 2, 44 * SCALE_HEIGHT_L);
        _pwdTextField.frame = CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH - 161 * 2)) / 2, SCREEN_HEIGHT - 44 * SCALE_HEIGHT_L - 50.0f, SCREEN_WIDTH - 161 * 2, 44 * SCALE_HEIGHT_L);
        
    }else {
        _bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _bgImageView.image = [UIImage imageNamed:@"BG3"];
        
        _accountTextField.frame = CGRectMake(15 * SCALE_WIDTH_P, 72.0f, SCREEN_WIDTH - 30 * SCALE_WIDTH_P, 44 * SCALE_HEIGHT_P);
        _pwdTextField.frame = CGRectMake(15 * SCALE_WIDTH_P, SCREEN_HEIGHT - 44 * SCALE_HEIGHT_P - 50.0f, SCREEN_WIDTH - 30 * SCALE_WIDTH_P, 44 * SCALE_HEIGHT_P);
        
    }
}


#pragma mark - resign keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

#pragma mark - status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
