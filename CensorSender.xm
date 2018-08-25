#import <objc/runtime.h>

@interface NCNotificationListCollectionView : UICollectionView
@end

@interface NCNotificationContentView : UIView
	@property(nonatomic, retain) NSString * primaryText;
	@property(nonatomic, retain) NSString * secondaryText;
@end

@interface UIView (associatedObject)
	@property(nonatomic, strong) NSString * originalTitle;
	@property(nonatomic, strong) NSString * originalMessage;
@end


@implementation UIView (associatedObject)
	@dynamic originalTitle;
	@dynamic originalMessage;

	- (void)setOriginalTitle: (id)object {
	     objc_setAssociatedObject(self, @selector(originalTitle), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	- (id)originalTitle {
	    return objc_getAssociatedObject(self, @selector(originalTitle));
	}

	- (void)setOriginalMessage: (id)object {
	     objc_setAssociatedObject(self, @selector(originalMessage), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	- (id)originalMessage {
	    return objc_getAssociatedObject(self, @selector(originalMessage));
	}

@end


NCNotificationListCollectionView *notificationList = nil;

static BOOL enabled;
static BOOL messageEnabled;
static NSString *censorText;
static BOOL locked = YES;

static void changeTitles(UIView *view, BOOL deviceLocked) {
    for (UIView *subview in view.subviews) {
    	if([subview isKindOfClass: [%c(NCNotificationContentView) class]]) {
    		NCNotificationContentView *notificationCell = (NCNotificationContentView *)subview;
    		if(notificationCell.primaryText) {
    			if (!censorText || censorText.length > 25) censorText = @"Protected by CensorSender";
    			notificationCell.primaryText = deviceLocked ? notificationCell.originalTitle : censorText;
    		}
    		if(notificationCell.secondaryText && messageEnabled)
    			notificationCell.secondaryText = deviceLocked ? notificationCell.originalMessage : @"Notification";
    	}
        changeTitles(subview, deviceLocked);
    }
}

static void loadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Library/Preferences/%s.plist", "com.dunkston.censorsender"]];
	
	enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	messageEnabled = prefs[@"messageEnabled"] ? [prefs[@"messageEnabled"] boolValue] : NO;
	censorText = prefs[@"censorText"] && !([prefs[@"censorText"] isEqualToString:@""]) ? [prefs[@"censorText"] stringValue] : @"Protected by CensorSender";

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
		[self setOriginalMessage: self.secondaryText];
		if(enabled && locked && self.primaryText) self.primaryText = censorText;
		if(enabled && messageEnabled && locked && self.secondaryText) self.secondaryText = @"Notification";
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