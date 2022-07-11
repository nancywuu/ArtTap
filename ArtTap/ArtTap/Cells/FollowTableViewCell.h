//
//  FollowTableViewCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface FollowTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bio;

@end

NS_ASSUME_NONNULL_END
