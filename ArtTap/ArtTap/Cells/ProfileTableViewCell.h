//
//  ProfileTableViewCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (nonatomic, strong) Post *post;

@end

NS_ASSUME_NONNULL_END
