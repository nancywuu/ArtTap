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
@dynamic likeCount;
@dynamic markUp;
@dynamic didMarkUp;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void) postComment: ( NSString * _Nullable )post withUser: ( User * _Nullable )user withText: ( NSString * _Nullable )text withMarkUp: ( UIImage * _Nullable )markUp withMarkBool: (BOOL)markUpBool withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Comment *newComment = [Comment new];
    newComment.markUp = [self getPFFileFromImage:markUp];
    newComment.postID = post;
    newComment.text = text;
    newComment.author = user;
    newComment.critBool = critBool;
    newComment.likeCount = @(0);
    newComment.didMarkUp = markUpBool;
    
    [newComment saveInBackgroundWithBlock:completion];
}

+ (void) favorite: (Comment * _Nullable)comment withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion{
    Comment *temp = comment;
    temp.likeCount = value;
    [temp saveInBackgroundWithBlock: completion];
}

+ (PFFileObject * )getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
