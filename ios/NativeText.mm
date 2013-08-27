#import "NativeText.h"
#import "TeaLeafAppDelegate.h"

static NativeText* instance = nil;

@implementation NativeText

@synthesize textField = _textField;
@synthesize tap = _tap;

+ (NativeText*) get {
	if (!instance) {
		instance = [[NativeText alloc] init];
	}
    
	return instance;
}

// The plugin must call super dealloc.
- (void) dealloc {
	if(self.textField) {
        if(self.tap) [self.textField.superview removeGestureRecognizer:self.tap];
        [self.textField removeFromSuperview];
    }
    
    self.tap = nil;
    self.textField = nil;
	
	[super dealloc];
}

// The plugin must call super init.
- (id) init {
	self = [super init];
	if (!self) {
		return nil;
	}
    //	[self showKeyboard:self.GCid withString:@"" andID:++self.GCid];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
	return self;
}

-(void)dismissKeyboard {
    [self hideKeyboard];
}

- (void) initializeWithManifest:(NSDictionary *)manifest appDelegate:(TeaLeafAppDelegate *)appDelegate {
	NSLOG(@"{nativeText} Initialized with manifest");
}

- (void)showKeyboard:(int)keyboardType withString:(NSString*)showText andID:(int)fieldID {
    if (self.textField) [self hideKeyboard];
	NSLOG(@"{nativeText} Showing Keyboard:%i withString:%@ andID:%i", keyboardType, showText, fieldID);
    //	id topView = (TeaLeafAppDelegate *)[[UIApplication sharedApplication] delegate].tealeafViewController.view;
	id topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];;
	self.GCid = fieldID;
	
    //	CGRect passwordTextFieldFrame = CGRectMake(20.0f, 100.0f, 280.0f, 31.0f);
	CGRect passwordTextFieldFrame = CGRectMake(0.0f, 0.0f, 0.0f, -100.0f);
	self.textField = [[UITextField alloc] initWithFrame:passwordTextFieldFrame];
	if(showText) self.textField.placeholder = showText;
	self.textField.backgroundColor = [UIColor whiteColor];
	self.textField.textColor = [UIColor blackColor];
	self.textField.font = [UIFont systemFontOfSize:14.0f];
	self.textField.borderStyle = UITextBorderStyleRoundedRect;
	self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	self.textField.returnKeyType = UIReturnKeyDone;
	self.textField.textAlignment = UITextAlignmentLeft;
	self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.textField.tag = 2;
	self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
 	self.textField.delegate = self;
    if (showText.length > 0)
 		self.textField.text = showText;
   	switch (keyboardType) {
        case EmailKeyboard:
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        case URLKeyboard:
            self.textField.keyboardType = UIKeyboardTypeURL;
            break;
        case PhoneKeyboard:
            self.textField.keyboardType = UIKeyboardTypePhonePad;
            break;
        default:
 			self.textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:self.textField];
    
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];
    
    [topView addGestureRecognizer:self.tap];
    
	[topView addSubview:self.textField];
    
	[self.textField becomeFirstResponder];
    // 	[topView addSubview:self.textField];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
	NSLOG(@"{nativeText} Showing Keyboard");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSString* idString = [NSString stringWithFormat:@"%i",self.GCid];
    NSString* heightString = [NSString stringWithFormat:@"%f",kbSize.height];
	[[PluginManager get] dispatchJSEvent:[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"nativeText", @"name",
                                          @"keyboardShown", @"method",
                                          heightString, @"keyboardHeight",
                                          idString, @"id", nil]];
}

- (void)hideKeyboard {
	NSLOG(@"{nativeText} Hiding Keyboard");
    [self.textField.superview removeGestureRecognizer:self.tap];
    self.textField.hidden = YES;
    [self.textField resignFirstResponder];
	[self.textField removeFromSuperview];
    NSString* idString = [NSString stringWithFormat:@"%i",self.GCid];
	[[PluginManager get] dispatchJSEvent:[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"nativeText", @"name",
                                          @"hideKeyboard", @"method",
                                          idString, @"id", nil]];
}

-(void)textFieldDidChange:(UITextField *)textField {
    //	Return was pressed - save and close
	NSLOG(@"{nativeText} text: %@", self.textField.text);
	if([self.textField.text rangeOfString:@"\n"].length > 0) {
		[self hideKeyboard];
		return;
	}
    NSString* idString = [NSString stringWithFormat:@"%i",self.GCid];
	[[PluginManager get] dispatchJSEvent:[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"nativeText", @"name",
                                          @"textChanged", @"method",
                                          idString, @"id",
                                          self.textField.text, @"showText", nil]];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
	NSLOG(@"{nativeText} text should return");
	[self hideKeyboard];
	return YES;
}

- (void) onRequest:(NSDictionary *)jsonObject {
	@try {
		NSLOG(@"{nativeText} Got request");
        
		NSString *method = [jsonObject valueForKey:@"method"];
        
		if ([method isEqualToString:@"showKeyboard"]) {
			int kbType = [[jsonObject valueForKey:@"keyboardType"] intValue];
			NSString *showText = [jsonObject valueForKey:@"showText"];
			int fieldID = [[jsonObject valueForKey:@"id"] intValue];
			
			[[NativeText get] showKeyboard:kbType withString:showText andID:fieldID];
            // 			[[PluginManager get] dispatchJSEvent:[NSDictionary dictionaryWithObjectsAndKeys:
            // 			@"geoloc",@"name", kCFBooleanTrue, @"failed", nil]];
		}
		if ([method isEqualToString:@"hideKeyboard"]) {
			[[NativeText get] hideKeyboard];
            // 			[[PluginManager get] dispatchJSEvent:[NSDictionary dictionaryWithObjectsAndKeys:
            // 			@"geoloc",@"name", kCFBooleanTrue, @"failed", nil]];
		}
	}
	@catch (NSException *exception) {
		NSLOG(@"{nativeText} Exception while processing event: ", exception);
	}
}
@end

