//
//  CreateViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CreateViewControllerDelegate

- (void)didPost;
@end

@interface CreateViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) id<CreateViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *captionField;
@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UIImageView *displayVideo;
@property (weak, nonatomic) IBOutlet UISwitch *critSwitch;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *cache;

@end

NS_ASSUME_NONNULL_END
