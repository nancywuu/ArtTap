//
//  CommentCell.h
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import "Comment.h"
#import "User.h"
#import "CommentLikes.h"
#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN
@protocol CommentCellDelegate;
@interface CommentCell : UITableViewCell

@property (nonatomic, weak) id<CommentCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *markUpView;
@property BOOL liked;
@property (nonatomic, strong) Comment *comment;

@end

@protocol CommentCellDelegate
- (void)didLikeComment;
- (void)didDisplayMarkUp:(NSString *)username withImage: (PFFileObject *)image;
@end

NS_ASSUME_NONNULL_END
