#import "Tweak.h"
#define plistPath @"/var/mobile/Library/Preferences/com.captmegacharlie.hazmat.plist"
#define prefsNoti CFSTR("com.captmegacharlie.hazmat.reloadprefs")
#define bundlesFolder @"/var/mobile/Library/Application Support/Hazmat"
#define maskFileName @"mask.png"
#define overlayFileName @"overlay.png"

BOOL tweakEnabled;
NSString *selectedBundleName;
CGFloat chosenOffset;
NSMutableArray *HZPMaskStorage = [NSMutableArray array];
NSMutableArray *HZPOverlayStorage = [NSMutableArray array];

UIImage *imageForName(NSString *name) {
    NSString *bundlePath = [bundlesFolder stringByAppendingPathComponent:selectedBundleName];
    NSString *overlayPath = [bundlePath stringByAppendingPathComponent:name];
    return [UIImage imageWithContentsOfFile:overlayPath];
}

UIView *subviewOfClass(UIView *sender, Class theClass) {
    for (UIView *sv in sender.subviews) {
        if ([sv isKindOfClass:theClass]) {
            return sv;
        }
    }
    return nil;
}

void addMask(UIView *target, UIView<HZPMask> *storage) {
    if (tweakEnabled) {
        UIImage *maskImage = imageForName(maskFileName);
        if (maskImage) {
            UIImageView *maskView = [[UIImageView alloc] initWithImage:maskImage];
            target.maskView = maskView;
            storage.hazmatMask = maskView;
        }
    }
}

void updateMask(UIView<HZPMask> *sender, CGRect f) {
    if (tweakEnabled) {
        UIImageView *maskView = sender.hazmatMask;
        if (maskView) {
            maskView.frame = CGRectMake(0, 0, f.size.width, f.size.height);
        }
    }
}

void addOverlay(UIView<HZPOverlay> *sender, BOOL addToSuperview) {
    if (tweakEnabled) {
        UIImage *overlayImage = imageForName(overlayFileName);
        if (overlayImage) {
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [(addToSuperview) ? sender.superview : sender addSubview:overlayView];
            sender.hazmatOverlay = overlayView;
        }
    }
}

void updateOverlay(UIView<HZPOverlay> *sender, CGRect f) {
    if (tweakEnabled) {
        UIImageView *overlayView = sender.hazmatOverlay;
        if (overlayView) {
            CGFloat baseSize = f.size.width;
            CGFloat extra = (baseSize * chosenOffset) - baseSize;
            CGFloat newSize = (extra * 2) + baseSize;
            overlayView.frame = CGRectMake(f.origin.x - extra, f.origin.y - extra, newSize, newSize);
        }
    }
}

void reloadPrefs() {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath] ?: [NSDictionary dictionary];
    tweakEnabled = [[dict objectForKey:@"enabled"] ?: @YES boolValue];
    selectedBundleName = [dict objectForKey:@"currentMask"] ?: @"Slime";
    chosenOffset = [[dict objectForKey:@"offset"] ?: @(1.05) doubleValue];
    
    if (tweakEnabled) {
        for (UIView<HZPMask> *storage in HZPMaskStorage) {
            UIView *target = [storage isKindOfClass:objc_getClass("MediaControlsHeaderView")] ? ((MediaControlsHeaderView *)storage).artworkView : storage;
            addMask(target, storage);
        }
        for (UIView<HZPOverlay> *storage in HZPOverlayStorage) {
            BOOL isSpringBoard = [storage isKindOfClass:objc_getClass("MediaControlsHeaderView")];
            BOOL isSpotify = [storage isKindOfClass:objc_getClass("SPTNowPlayingCoverArtImageView")];
            
            [storage.hazmatOverlay removeFromSuperview];
            addOverlay(storage, isSpotify);
            
            if (isSpringBoard) {
                MediaControlsHeaderView *storage2 = (MediaControlsHeaderView *)storage;
                if (storage2.style == 1) {
                    storage2.hazmatOverlay.hidden = YES;
                }
            }
            if (isSpotify) {
                SPTNowPlayingCoverArtImageView *storage2 = (SPTNowPlayingCoverArtImageView *)storage;
                storage2.image = storage2.image;
            }
        }
    }
    else {
        for (UIView<HZPMask> *storage in HZPMaskStorage) {
            storage.hazmatMask.superview.maskView = nil;
            storage.hazmatMask = nil;
        }
        for (UIView<HZPOverlay> *storage in HZPOverlayStorage) {
            [storage.hazmatOverlay removeFromSuperview];
            storage.hazmatOverlay = nil;
        }
    }
}

//--------------------------------------------------------------------------------------------------------------------------
%group SpringBoard
%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    reloadPrefs();
}
%end

%hook MediaControlsHeaderView
%property (strong) UIImageView *hazmatMask;
%property (strong) UIImageView *hazmatOverlay;
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    [HZPMaskStorage addObject:self];
    [HZPOverlayStorage addObject:self];
    addMask(self.artworkView, self);
    addOverlay(self, NO);
    self.hazmatOverlay.hidden = YES;
    self.artworkBackground = nil;
    self.shadow = nil;
    return self;
}

- (void)setFrame:(CGRect)frame {
    %orig;
    updateMask(self, self.artworkView.frame);
    updateOverlay(self, self.artworkView.frame);
}
%end

%hook MRPlatterViewController
- (void)setStyle:(NSInteger)style {
    %orig;
    if (self.style == 3) { //3 = lock screen music player
        self.nowPlayingHeaderView.hazmatOverlay.hidden = NO;
    }
    else {
        if (self.artworkCatalog) { //only affect music controls (not Apple TV controls)
            if (style == 0) { //0 = opened CC music screen (full-screen music controls are now the current focus)
                self.nowPlayingHeaderView.hazmatOverlay.hidden = NO;
            }
            else if (style == 1) { //1 = closed CC music screen (music controls are now just the 2x2 platter)
                self.nowPlayingHeaderView.hazmatOverlay.hidden = YES;
            }
        }
    }
}
%end
%end

%group AppleMusic
%hook AMArtworkComponentImageView
%property (strong) UIImageView *hazmatMask;
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    [HZPMaskStorage addObject:self];
    return self;
}

- (void)setFrame:(CGRect)frame {
    %orig;
    UIView *sv = [self superview];
    if ([sv isKindOfClass:objc_getClass("MusicApplication.NowPlayingContentView")]) {
        updateMask(self, frame);
        updateOverlay((AMNowPlayingContentView *)sv, frame);
    }
}
%end

%hook AMNowPlayingContentView
%property (strong) UIImageView *hazmatOverlay;
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    [HZPOverlayStorage addObject:self];
    AMArtworkComponentImageView *av = (AMArtworkComponentImageView *)subviewOfClass(self, objc_getClass("MusicApplication.ArtworkComponentImageView"));
    [av setClipsToBounds:NO];
    addMask(av, av);
    addOverlay(self, NO);
    return self;
}
%end
%end

%group Spotify
%hook SPTNowPlayingCoverArtImageView
%property (strong) UIImageView *hazmatMask;
%property (strong) UIImageView *hazmatOverlay;
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    [HZPMaskStorage addObject:self];
    [HZPOverlayStorage addObject:self];
    addMask(self, self);
    return self;
}

- (void)setImage:(UIImage *)image {
    %orig;
    updateMask(self, self.frame);
    updateOverlay(self, self.frame);
}
%end

%hook SPTNowPlayingCoverArtCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    addOverlay(self.imageView, YES);
    return self;
}
%end

%hook SPTNowPlayingBarLeftAccessoryCoverArtViewController
- (void)viewDidLoad {
    %orig;
    addOverlay(self.coverArtImageView, YES);
}
%end
%end

//--------------------------------------------------------------------------------------------------------------------------
%ctor {
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
    if ([bundleID isEqualToString:@"com.apple.springboard"]) {
        %init(SpringBoard);
    }
    else if ([bundleID isEqualToString:@"com.apple.Music"]) {
        %init(AppleMusic, AMArtworkComponentImageView = objc_getClass("MusicApplication.ArtworkComponentImageView"), AMNowPlayingContentView = objc_getClass("MusicApplication.NowPlayingContentView"));
        reloadPrefs();
    }
    else if ([bundleID isEqualToString:@"com.spotify.client"]) {
        %init(Spotify);
        reloadPrefs();
    }
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, prefsNoti, NULL, NULL);
}
