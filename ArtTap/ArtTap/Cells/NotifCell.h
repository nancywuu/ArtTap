//
//  NotifCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/13/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN
@protocol NotifCellDelegate;
@interface NotifCell : UITableViewCell

@property (nonatomic, weak) id<NotifCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIButton *trigger;
@property BOOL isFollow;

@end

@protocol NotifCellDelegate
- (void)didTapNotif:(NotifCell *)cell;
@end

NS_ASSUME_NONNULL_END
