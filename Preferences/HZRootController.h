#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>

@interface PSSpecifier ()
- (void)setValues:(NSArray *)values titles:(NSArray *)titles;
@end

@interface HZRootController : PSListController
- (NSMutableArray *)specifiers;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
- (void)omegalul;
@end
