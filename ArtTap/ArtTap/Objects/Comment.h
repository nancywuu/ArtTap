//
//  Comment.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "User.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property BOOL critBool;
@property (nonatomic, strong) User *author;
@property (nonatomic, strong) NSNumber *likeCount;

+ (void) postComment: ( NSString * _Nullable )post withUser: ( User * _Nullable )user withText: ( NSString * _Nullable )text withBool: (BOOL)critBool withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) favorite: (Comment * _Nullable)comment withValue: ( NSNumber * _Nullable )value withCompletion: (PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
