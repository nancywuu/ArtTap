//
//  Post.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//
//  Post.m
#import "Post.h"
#import "Liked.h"
#import "Comment.h"
@implementation Post
    
@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic speedpaint;
@dynamic likeCount;
@dynamic commentCount;
@dynamic createdAt;
@dynamic critBool;
@dynamic numViews;
@dynamic viewTrack;


+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserImage: ( UIImage * _Nullable )image withVideo: ( NSData * _Nullable )video withCaption: ( NSString * _Nullable )caption withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [User currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.critBool = critBool;
    newPost.numViews = @(0);
    if(video != nil){
        //newPost.speedpaint = [PFFileObject fileObjectWithData:video];
        newPost.speedpaint = [PFFileObject fileObjectWithData:video contentType:@"video/mp4"];
    }
    
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

- (void) getPostData: (NSMutableArray *)tempEngageArr withLikeArr: (NSMutableArray *)tempLikeArr withComArr: (NSMutableArray *)tempComArr
         withCritArr: (NSMutableArray *)tempCritArr {
    PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
    [query includeKey:@"postID"];
    [query includeKey:@"userID"];
    [query includeKey:@"isEngage"];
    [query includeKey:@"createdAt"];
    [query whereKey:@"postID" equalTo: self.objectId];

    NSArray *tempRes = [query findObjects];
    
    PFQuery *comquery = [PFQuery queryWithClassName:@"Comment"];
    [comquery includeKey:@"postID"];
    [comquery includeKey:@"createdAt"];
    [comquery whereKey:@"postID" equalTo: self.objectId];

    NSArray *comRes = [comquery findObjects];
    
    for(int i = 0; i < tempRes.count; i++){
        Liked *temp = tempRes[i];
        NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];

        if(hours < 730){
            if(temp.isEngage){
                tempEngageArr[hours] = [NSNumber numberWithInteger:[tempEngageArr[hours] integerValue] + 1];
            } else {
                tempLikeArr[hours] = [NSNumber numberWithInteger:[tempLikeArr[hours] integerValue] + 1];
            }

        }
    }
    
    for(int i = 0; i < comRes.count; i++){
        Comment *temp = comRes[i];
        NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];

        if(hours < 730){
            if(temp.critBool){
                tempCritArr[hours] = [NSNumber numberWithInteger:[tempCritArr[hours] integerValue] + 1];
            } else {
                tempComArr[hours] = [NSNumber numberWithInteger:[tempComArr[hours] integerValue] + 1];
            }
        }
    }
}

@end
