//
//  EditViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "User.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN
@protocol EditViewDelegate
- (void)didEdit;
@end

@interface EditViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) id<EditViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *bioField;
@property (nonatomic, strong) UIImage *currentProfileImage;
@property (nonatomic, strong) UIImage *currentBackgroundImage;
@property (nonatomic) BOOL fromBg;

@end

NS_ASSUME_NONNULL_END
