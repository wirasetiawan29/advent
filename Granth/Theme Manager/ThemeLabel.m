//
//  ThemeLabel.m

#import "ThemeLabel.h"

@implementation ThemeLabel


#pragma mark -
#pragma mark - init methods

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
#pragma mark - apply theme

- (void)applyTheme {
    UIFont *font = nil;
    if(_type == 0) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize6"];
    }
    else if(_type == 1) {
        font = [[ThemeManager sharedManager] fontForKey:@"font0" withSizeKey:@"fSize3"];
    }
    else if(_type == 2) {
        font = [[ThemeManager sharedManager] fontForKey:@"font2" withSizeKey:@"fSize4"];
    }
    else if(_type == 3 || _type == 4 || _type == 5) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize2"];
    }
    else if(_type == 6 || _type == 8 || _type == 9){
        font = [[ThemeManager sharedManager] fontForKey:@"font2" withSizeKey:@"fSize2"];
    }
    else if(_type == 7) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize3"];
    }
    else if(_type == 10) {
       font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize8"];
    }
    else if(_type == 11) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize1"];
    }
    else if(_type == 12) {
        font = [[ThemeManager sharedManager] fontForKey:@"font2" withSizeKey:@"fSize1"];
    }
    else if(_type == 13) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize0"];
    }
    else if(_type == 14) {
        font = [[ThemeManager sharedManager] fontForKey:@"font1" withSizeKey:@"fSize0"];
    }
    
    
    self.font = font;
    
    UIColor *textColor = nil;
    if (_type == 0 || _type == 2 || _type == 3 || _type == 10){
        textColor = [[ThemeManager sharedManager] colorForKey:@"white"];
    }
    else if (_type == 1 || _type == 4 || _type == 8){
        textColor = [[ThemeManager sharedManager] colorForKey:@"primaryTextColor"];
    }
    else if (_type == 5 || _type == 9 || _type == 11 || _type == 13){
        textColor = [[ThemeManager sharedManager] colorForKey:@"secondaryTextColor"];
    }
    else if (_type == 6 || _type == 14){
        textColor = [[ThemeManager sharedManager] colorForKey:@"black"];
    }
    else if (_type == 7){
        textColor = [[ThemeManager sharedManager] colorForKey:@"primaryColor"];
    }

    [self setTextColor:textColor];
    
    UIColor *backgroundColor = nil;
    if (_type == 20) {
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
    }
    
    [self setBackgroundColor:backgroundColor];
}

#pragma mark -
#pragma mark - set observer for change theme

- (void)themeDidChangeNotification:(NSNotification *)notification {
    [self applyTheme];
}
@end
