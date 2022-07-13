//
//  User.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "User.h"

@implementation User

@dynamic username;
@dynamic password;
@dynamic profilePic;
@dynamic name;
@dynamic bio;
@dynamic backgroundPic;


+ (void) updateUser: ( UIImage * _Nullable )image withBackground: (UIImage * _Nullable )bgImage withName: ( NSString * _Nullable )name withUsername: ( NSString * _Nullable )username withBio: (NSString * _Nullable)bio withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    User *user = User.currentUser;
    if(image != nil){
        user[@"profilePic"] = [self getPFFileFromImage:image];
    }
    if(bgImage != nil){
        user[@"backgroundPic"] = [self getPFFileFromImage:bgImage];
    }
    if(![username isEqualToString:@""]){
        user.username = username;
    }
    if(![name isEqualToString:@""]){
        user.name = name;
    }
    if(![bio isEqualToString:@""]){
        user.bio = bio;
    }

    [user saveInBackgroundWithBlock: completion];
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
