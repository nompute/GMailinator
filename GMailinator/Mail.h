@interface MailApp : NSApplication
{}
- (NSArray *)accounts;
@end

@interface MailAccount : NSObject
{}
- (bool) isActive;
- (NSArray *)mailboxes;
@end

@interface MailboxUid : NSObject
{}
- (MailboxUid *)parent;
- (NSString *)displayName;
@end
