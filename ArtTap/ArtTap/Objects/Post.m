//
//  Post.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//
//  Post.m
#import "Post.h"
@implementation Post
    
@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic likeCount;
@dynamic commentCount;
@dynamic createdAt;
@dynamic critBool;
@dynamic numViews;
@dynamic viewTrack;


+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserImage: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [User currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.critBool = critBool;
    newPost.numViews = @(0);
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (void) favorite: (Post * _Nullable)post withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Post *temp = post;
    temp.likeCount = value;
    [temp saveInBackgroundWithBlock: completion];
}

+ (void) viewed: (Post * _Nullable)post withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Post *temp = post;
    int val = [temp.numViews intValue];
    temp.numViews = [NSNumber numberWithInt:val + 1];
    
    NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];

    NSMutableArray *tempViewArr = [NSMutableArray new];
    
    if(temp.viewTrack.count != 0){
        tempViewArr = [temp.viewTrack mutableCopy];
    } else {
        [tempViewArr addObject:@(0)];
    }

    
    if(hours > tempViewArr.count - 1){
        for(int i = (int)tempViewArr.count - 1; i <= hours; i++){
            [tempViewArr addObject:@(0)];
        }
    }
    
    tempViewArr[hours] = [NSNumber numberWithInteger:[tempViewArr[hours] integerValue] + 1];
    
    temp.viewTrack = [tempViewArr copy];
    
    [temp saveInBackgroundWithBlock: completion];
}

+ (void) comment: (Post * _Nullable)post withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Post *temp = post;
    temp.commentCount = value;
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
