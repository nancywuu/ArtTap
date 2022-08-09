//
//  Post.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "User.h"
@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) User *author;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) PFFileObject *speedpaint;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *numViews;
@property (nonatomic, strong) NSArray *viewTrack;
@property BOOL critBool;

+ (void) postUserImage: ( UIImage * _Nullable )image withVideo: ( NSData * _Nullable )video withCaption: ( NSString * _Nullable )caption withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) favorite: (Post * _Nullable)post withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) viewed: (Post * _Nullable)post withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) comment: (Post * _Nullable)post withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) getPostData: (PFQuery *)query withComQuery: (PFQuery *)comquery withEngageArr:(NSMutableArray *)tempEngageArr withLikeArr: (NSMutableArray *)tempLikeArr withComArr: (NSMutableArray *)tempComArr
         withCritArr: (NSMutableArray *)tempCritArr;

@end
