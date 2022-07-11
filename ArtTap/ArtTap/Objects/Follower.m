//
//  Follower.m
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import "Follower.h"

@implementation Follower

@dynamic user;
@dynamic follower;

+ (nonnull NSString *)parseClassName {
    return @"Follower";
}

+ (void) follow: ( User * _Nullable )user withFollower: ( User * _Nullable )follower withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Follower *newFollow = [Follower new];
    newFollow.user = user;
    newFollow.follower = follower;
    
    [newFollow saveInBackgroundWithBlock: completion];
}

@end
