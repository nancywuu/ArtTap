//
//  CommentLikes.h
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentLikes : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *userID;

+ (void) favorite: ( NSString * _Nullable )commentID withUser: ( NSString * _Nullable )userID withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
