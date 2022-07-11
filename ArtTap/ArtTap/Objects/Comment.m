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
@dynamic critBool;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void) postComment: ( NSString * _Nullable )post withUser: ( User * _Nullable )user withText: ( NSString * _Nullable )text withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Comment *newComment = [Comment new];
    newComment.postID = post;
    newComment.text = text;
    newComment.author = user;
    newComment.critBool = critBool;
    
    [newComment saveInBackgroundWithBlock:completion];
}


@end
