#import <objc/runtime.h>

@interface NCNotificationListCollectionView : UICollectionView
@end

@interface NCNotificationContentView : UIView
	@property(nonatomic, retain) NSString * primaryText;
@end

@interface UIView (originalTitle)
	@property(nonatomic, strong) NSString * originalTitle;
@end


@implementation UIView (originalTitle)
	@dynamic originalTitle;

	- (void)setOriginalTitle: (id)object {
	     objc_setAssociatedObject(self, @selector(originalTitle), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	- (id)originalTitle {
	    return objc_getAssociatedObject(self, @selector(originalTitle));
	}
@end


NCNotificationListCollectionView *notificationList = nil;

static BOOL enabled;
static NSString *censorText;
static BOOL locked = YES;

static void changeTitles(UIView *view, BOOL deviceLocked) {
    for (UIView *subview in view.subviews) {
    	if([subview isKindOfClass: [%c(NCNotificationContentView) class]]) {
    		NCNotificationContentView *notificationCell = (NCNotificationContentView *)subview;
    		if(notificationCell.primaryText) {
    			notificationCell.primaryText = deviceLocked ? notificationCell.originalTitle : censorText;
    		}
    	}
        changeTitles(subview, deviceLocked);
    }
}

static void loadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Library/Preferences/%s.plist", "com.dunkston.censorsender"]];
	
	enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	censorText = prefs[@"censorText"] && !([prefs[@"censorText"] isEqualToString:@""]) ? prefs[@"censorText"] : @"Protected by CensorSender";

	[prefs release];
}

%hook NCNotificationListCollectionView

	- (void)layoutSubviews {
		%orig;
		notificationList = self;
	}

%end

%hook NCNotificationContentView

	- (void)setMessageNumberOfLines:(unsigned long long)arg1 {
		%orig;
		[self setOriginalTitle: self.primaryText];
		if(enabled && locked && self.primaryText) self.primaryText = censorText;
	}

%end

%hook SBDashBoardViewController

	- (void)setAuthenticated:(BOOL)arg1 {
		%orig;
		locked = !arg1;
		if(enabled && notificationList) changeTitles(notificationList, !locked);
	}

%end


%ctor {
	loadPrefs(nil, nil, nil, nil, nil);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)loadPrefs,
		CFSTR("com.dunkston.censorsender.preferencesChanged"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}