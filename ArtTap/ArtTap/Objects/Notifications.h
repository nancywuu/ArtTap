//
//  Notifications.h
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "User.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Notifications : PFObject<PFSubclassing>

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) User *creator;
@property (nonatomic, strong) NSNumber *notifType;
@property (nonatomic, strong) NSString *text;

//typedef NS_ENUM(NSUInteger, notifType) {
//    commentNotif = 0,
//    likeNotif = 1,
//    followNotif = 2,
//};

+ (void) notif: (Post * _Nullable)post withAuthor: ( User * _Nullable)author withType: ( NSNumber * _Nullable )type withText: ( NSString * _Nullable)text withCompletion: (PFBooleanResultBlock _Nullable)completion;


@end

NS_ASSUME_NONNULL_END
