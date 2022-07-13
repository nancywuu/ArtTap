//
//  TrendTableCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface TrendTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet PFImageView *previewImage;
@property (nonatomic, strong) Post *obj;


@end

NS_ASSUME_NONNULL_END
