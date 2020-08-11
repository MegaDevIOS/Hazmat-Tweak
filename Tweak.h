#import <objc/runtime.h>

@protocol HZPMask
@property UIImageView *hazmatMask;
@end

@protocol HZPOverlay
@property UIImageView *hazmatOverlay;
@end

@interface SpringBoard : UIApplication
- (void)applicationDidFinishLaunching:(UIApplication *)application;
@end

@interface MTMaterialView : UIView
@end

@interface MPArtworkCatalog : NSObject
@end

@interface MediaControlsHeaderView : UIView <HZPMask, HZPOverlay>
@property NSInteger style;
@property UIImageView *artworkView;
@property MTMaterialView *artworkBackground;
@property UIView *shadow;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setFrame:(CGRect)frame;
@end

@interface MRPlatterViewController : UIViewController
@property NSInteger style;
@property MediaControlsHeaderView *nowPlayingHeaderView;
@property MPArtworkCatalog *artworkCatalog;
- (void)setStyle:(NSInteger)style;
@end

@interface AMArtworkComponentImageView : UIImageView <HZPMask>
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setFrame:(CGRect)frame;
@end

@interface AMNowPlayingContentView : UIView <HZPOverlay>
- (instancetype)initWithFrame:(CGRect)frame;
@end

@interface SPTNowPlayingCoverArtImageView : UIImageView <HZPMask, HZPOverlay>
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setImage:(UIImage *)image;
@end

@interface SPTNowPlayingCoverArtCell : UICollectionViewCell
@property SPTNowPlayingCoverArtImageView *imageView;
- (instancetype)initWithFrame:(CGRect)frame;
@end

@interface SPTNowPlayingBarLeftAccessoryCoverArtViewController : UIViewController
@property SPTNowPlayingCoverArtImageView *coverArtImageView;
- (void)viewDidLoad;
@end
