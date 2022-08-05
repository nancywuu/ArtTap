//
//  PopUpViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface PopUpViewController : UIViewController
@property (strong, nonatomic) NSString *chosenUsername;
@property (strong, nonatomic) PFFileObject *chosenImage;
@end

NS_ASSUME_NONNULL_END
