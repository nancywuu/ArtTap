//
//  CommentLikes.m
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import "CommentLikes.h"

@implementation CommentLikes
@dynamic commentID;
@dynamic userID;

+ (nonnull NSString *)parseClassName {
    return @"CommentLikes";
}

+ (void) favorite: ( NSString * _Nullable )commentID withUser: ( NSString * _Nullable )userID withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    CommentLikes *newLike = [CommentLikes new];
    newLike.commentID = commentID;
    newLike.userID = userID;
    
    [newLike saveInBackgroundWithBlock: completion];
}

@end
