//
//  ThemeButton.m

#import "ThemeButton.h"
#import "ThemeManager.h"

@implementation ThemeButton
#define OBJ_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


#pragma mark -
#pragma mark - initialization Methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (void)_init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChangeNotification:) name:ThemeManagerDidChangeThemes object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self applyTheme];
}

- (void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        // do nothing, only unregistering self from notifications
    }
}


#pragma mark -
#pragma mark - Apply Theme to Controll

- (void)applyTheme {

    //set Font
    UIFont *font = nil;
    if(_type == 0 || _type == 7) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize2"];
    }
    else if(_type == 1) {
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize2"];
    }
    else if(_type == 2 || _type == 3) {
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize1"];
    }
    
    self.titleLabel.font = font;
   
    //set text color
    UIColor *textColor = nil;
    if (_type == 0) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"white"];
    }
    else if (_type == 1 || _type == 3 || _type == 7) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"primaryColor"];
    }
    else if (_type == 2) {
        textColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
    }
    
    [self setTitleColor:textColor forState:UIControlStateNormal];
    
    //set background color
    UIColor *backgroundColor, *primaryTintColor = nil;
    if (_type == 0) {
        backgroundColor = [[ThemeManager sharedManager] colorForKey:@"primaryColor"];
        if (OBJ_IPAD) {
            self.layer.cornerRadius = 5.0;
        }else {
            self.layer.cornerRadius = 5.0;
        }
    }
    else if (_type == 3) {
        backgroundColor = [[ThemeManager sharedManager] colorForKey:@"viewAllColor"];
        if (OBJ_IPAD) {
            self.layer.cornerRadius = self.frame.size.height / 2;
        }else {
            self.layer.cornerRadius = self.frame.size.height / 2;
        }
    }
    else if (_type == 10) {
        backgroundColor = [[ThemeManager sharedManager] colorForKey:@"primaryColor"];
    }
    
    if (_type == 7) {
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[ThemeManager sharedManager] colorForKey:@"primaryColor"].CGColor;
    }
    
    self.backgroundColor = backgroundColor;
    
     if (_type == 4) {
        primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"black"];
        [self setImage:[self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
        [self setTintColor:primaryTintColor];
    }
     else if (_type == 5) {
         primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"white"];
         [self setImage:[self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
         [self setTintColor:primaryTintColor];
     }
     else if (_type == 6) {
         primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"textChildColor"];
         [self setImage:[self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
         [self setTintColor:primaryTintColor];
     }
     else if (_type == 8) {
         primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"textChildColor"];
         [self setImage:[self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
         [self setTintColor:primaryTintColor];
     }
     else if (_type == 10) {
         primaryTintColor = [[ThemeManager sharedManager] colorForKey:@"white"];
         
         [self setImage:[self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
         
         if (OBJ_IPAD) {
             self.layer.cornerRadius = self.frame.size.height / 2;
         }else {
             self.layer.cornerRadius = self.frame.size.height / 2;
         }
         
         [self setTintColor:primaryTintColor];
     }
}

+ (UIButton *)setButtonTintColor:(UIButton *)button imageName:(NSString *)imageName state:(UIControlState)state tintColor:(UIColor *)color {
    [button setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:state];
    [button setTintColor:color];
    return button;
}


#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}

@end
