@interface NCNotificationContent
- (id) header;
@end


static BOOL enabled;
static NSString *censorText;


static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSHomeDirectory() stringByAppendingFormat:@"/Library/Preferences/%s.plist", "com.dunkston.censorsender"]];
	
	enabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	censorText = prefs[@"censorText"] && !([prefs[@"censorText"] isEqualToString:@""]) ? prefs[@"censorText"] : @"Protected by CensorSender";

	[prefs release];
}


%hook NCNotificationContent

	- (id)title {
		%orig;
		if(enabled && [[self header] isEqualToString:@"Messages"]) return censorText;
		else return %orig;
	}

%end


%ctor
{

	loadPrefs();

}