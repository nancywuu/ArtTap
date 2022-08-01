//
//  PopUpViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PopUpViewController : UIViewController
@property (nonatomic, strong) Post *currentPost;
@end

NS_ASSUME_NONNULL_END
