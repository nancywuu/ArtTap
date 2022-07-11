//
//  Liked.h
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import <Parse/Parse.h>
#import "Post.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Liked : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;

+ (void) favorite: ( NSString * _Nullable )postID withUser: ( NSString * _Nullable )userID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) unfavorite: ( NSString * _Nullable )postID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
