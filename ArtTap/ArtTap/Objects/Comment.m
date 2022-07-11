//
//  Comment.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "Comment.h"
@implementation Comment

@dynamic postID;
@dynamic text;
@dynamic author;
@dynamic createdAt;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void) postComment: ( NSString * _Nullable )post withUser: ( User * _Nullable )user withText: ( NSString * _Nullable )text withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Comment *newComment = [Comment new];
    newComment.postID = post;
    newComment.text = text;
    newComment.author = user;
    
    [newComment saveInBackgroundWithBlock:completion];
}


@end
