//
//  HomePhotoCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface HomePhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (strong, nonatomic) Post *post;
@property (weak, nonatomic) IBOutlet UIButton *tagButton;

@end

NS_ASSUME_NONNULL_END
