#import "../PS.h"
#import <objcipc/objcipc.h>

extern "C" int jetslammed_updateWaterMarkForPID(int highWatermarkMB, char* requester, int pid);
NSString *KMMNotification = @"KBMoreMem_AddMem";

%ctor
{
	if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		[OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:KMMNotification handler:^NSDictionary *(NSDictionary *message) {
			int pid = [message[@"pid"] intValue];
			NSLog(@"KBMoreMem: Adding memory to PID %d", pid);
			jetslammed_updateWaterMarkForPID(100, "KBMoreMem", pid);
			return nil;
		}];
		return;
	}
	NSProcessInfo *processInfo = [NSClassFromString(@"NSProcessInfo") processInfo];
	NSArray *args = processInfo.arguments;
	NSUInteger count = args.count;
	if (count != 0) {
		NSString *executablePath = args[0];
		if (executablePath) {
			BOOL isExtensionOrApp = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
			BOOL isExtension = isExtensionOrApp && [executablePath rangeOfString:@"appex"].location != NSNotFound;
			if (isExtension) {
				id val = NSBundle.mainBundle.infoDictionary[@"NSExtension"][@"NSExtensionPointIdentifier"];
				BOOL isKeyboardExtension = val ? [val isEqualToString:@"com.apple.keyboard-service"] : NO;
				if (isKeyboardExtension) {
					int pid = processInfo.processIdentifier;
					NSLog(@"KBMoreMem: Notify adding memory for %@ (%d)", [executablePath lastPathComponent], pid);
					[OBJCIPC sendMessageToSpringBoardWithMessageName:KMMNotification dictionary:@{ @"pid": @(pid) } replyHandler:^(NSDictionary *response) {
    					// Let SpringBoard do stuff
					}];
				}
			}
		}
	}
}