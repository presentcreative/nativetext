#import "PluginManager.h"

typedef NS_ENUM(NSInteger, KeyboardType) {
  DefaultKeyboard,
  EmailKeyboard,
  URLKeyboard,
  PhoneKeyboard
};

@interface NativeText : GCPlugin <UITextFieldDelegate> {
	UITextField *_textField;
	UITapGestureRecognizer *_tap;
}
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UITapGestureRecognizer *tap;
@property (nonatomic, assign) int GCid;

+ (NativeText*) get;
- (void)showKeyboard:(int)keyboardType withString:(NSString*)showText andID:(int)fieldID;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)hideKeyboard;
- (void)textFieldDidChange:(UITextField *)textField;
- (void) onRequest:(NSDictionary *)jsonObject;

@end