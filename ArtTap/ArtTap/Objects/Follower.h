//
//  Follower.h
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Follower : PFObject<PFSubclassing>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *follower;

+ (void) follow: ( User * _Nullable )user withFollower: ( User * _Nullable )follower withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
