//
//  User.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface User : PFUser<PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) PFFileObject *profilePic;
@property (nonatomic, strong) PFFileObject *backgroundPic;
@property BOOL darkmode;


+ (void) updateUser: ( UIImage * _Nullable )image withBackground: (UIImage * _Nullable )bgImage withName: ( NSString * _Nullable )name withUsername: ( NSString * _Nullable )username withBio: (NSString * _Nullable)bio withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (void) switchColorMode: ( User * _Nullable )user;

@end

NS_ASSUME_NONNULL_END
