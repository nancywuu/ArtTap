//
//  Liked.m
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import "Liked.h"
@implementation Liked

@dynamic postID;
@dynamic userID;

+ (nonnull NSString *)parseClassName {
    return @"Liked";
}

+ (void) favorite: ( NSString * _Nullable )postID withUser: ( NSString * _Nullable )userID withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Liked *newLike = [Liked new];
    newLike.postID = postID;
    newLike.userID = userID;
    
    [newLike saveInBackgroundWithBlock: completion];
}

@end
