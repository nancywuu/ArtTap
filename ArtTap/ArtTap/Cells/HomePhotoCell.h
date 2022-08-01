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

@protocol HomePhotoCellDelegate;
@interface HomePhotoCell : UICollectionViewCell <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<HomePhotoCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (strong, nonatomic) Post *post;

@end

@protocol HomePhotoCellDelegate
- (void)didPreview:(Post *)current;
@end

NS_ASSUME_NONNULL_END
