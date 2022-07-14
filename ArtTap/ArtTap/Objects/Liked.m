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
@dynamic isEngage;

+ (nonnull NSString *)parseClassName {
    return @"Liked";
}

+ (void) favorite: ( NSString * _Nullable )postID withUser: ( NSString * _Nullable )userID withDef: (BOOL)engage withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Liked *newLike = [Liked new];
    newLike.postID = postID;
    newLike.userID = userID;
    newLike.isEngage = engage;
    
    [newLike saveInBackgroundWithBlock: completion];
}

@end
