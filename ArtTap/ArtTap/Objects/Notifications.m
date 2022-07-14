//
//  Notifications.m
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import "Notifications.h"

@implementation Notifications

@dynamic post;
@dynamic author;
@dynamic creator;
@dynamic notifType;
@dynamic text;

+ (nonnull NSString *)parseClassName {
    return @"Notifications";
}

+ (void) notif: (Post * _Nullable)post withAuthor: ( User * _Nullable)author withType: ( NSNumber * _Nullable )type withText: ( NSString * _Nullable)text withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Notifications *notif = [Notifications new];
    notif.post = post;
    notif.author = author;
    notif.creator = User.currentUser;
    notif.notifType = type;
    notif.text = text;
    
    [notif saveInBackgroundWithBlock: completion];
}

@end
