#import "HZRootController.h"

#define versionNumber @"v1.0"
#define plistPath @"/var/mobile/Library/Preferences/com.captmegacharlie.hazmat.plist"
#define prefsNoti CFSTR("com.captmegacharlie.hazmat.reloadprefs")
#define bundlesFolder @"/var/mobile/Library/Application Support/Hazmat"

@implementation HZRootController
- (NSMutableArray *)specifiers {
    if (!_specifiers) {
        NSFileManager *fileMan = [NSFileManager defaultManager];
        NSArray *items = [fileMan contentsOfDirectoryAtPath:bundlesFolder error:nil] ?: [NSArray array];
        items = [items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        PSSpecifier *spec1 = [PSSpecifier preferenceSpecifierNamed:@"Current mask" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:[PSListItemsController class] cell:PSLinkListCell edit:nil];
        [spec1 setProperty:@"currentMask" forKey:@"key"];
        [spec1 setProperty:@"Slime" forKey:@"default"];
        [spec1 setProperty:items forKey:@"validTitles"];
        [spec1 setProperty:items forKey:@"validValues"];
        [spec1 setValues:items titles:items];
        
        NSString *theFooter = [NSString stringWithFormat:@"All changes take effect immediately!\n%@ | Capt Inc, MegaDev, Charlie While | © 2020", versionNumber];
        PSSpecifier *spec2 = [PSSpecifier preferenceSpecifierNamed:nil target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [spec2 setProperty:theFooter forKey:@"footerText"];
        
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        [_specifiers addObject:spec1];
        [_specifiers addObject:spec2];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"uwu" style:UIBarButtonItemStylePlain target:self action:@selector(omegalul)];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath] ?: [NSDictionary dictionary];
    return [dict objectForKey:[specifier propertyForKey:@"key"]] ?: [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath] ?: [NSMutableDictionary dictionary];
    [dict setObject:value forKey:[specifier propertyForKey:@"key"]];
    [dict writeToFile:plistPath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), prefsNoti, NULL, NULL, TRUE);
}

- (void)omegalul {
    NSString *url = @"https://www.youtube.com/watch?v=Et1b_qxxqjI";
    NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly:@NO};
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:options completionHandler:nil];
}
@end
