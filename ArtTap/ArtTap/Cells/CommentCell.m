//
//  CommentCell.m
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import "CommentCell.h"
#import "CommentLikes.h"
#import "PopUpViewController.h"

@implementation CommentCell
- (IBAction)hitLike:(id)sender {
    if(self.liked){
        self.liked = NO;
        [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        
        PFQuery *query = [PFQuery queryWithClassName:@"CommentLikes"];
        [query includeKey:@"userID"];
        [query includeKey:@"commentID"];
        [query whereKey:@"commentID" equalTo: self.comment.objectId];
        [query whereKey:@"userID" equalTo: User.currentUser.objectId];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable like, NSError * _Nullable error) {
            if (like != nil) {
                [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"succeeded in deleting like boolean obj");
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
        }];
         
        int temp = [self.comment.likeCount intValue];
        self.comment.likeCount = [NSNumber numberWithInt:temp - 1];
        self.likeCount.text = [self.comment.likeCount stringValue];
        [Comment favorite:self.comment withValue:self.comment.likeCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error updating comment like count: %@", error.localizedDescription);
            }
        }];
        
        
    } else {
        self.liked = YES;
        [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        
        [CommentLikes favorite:self.comment.objectId withUser:User.currentUser.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error saving comment like bool: %@", error.localizedDescription);
            }
        }];
        int temp = [self.comment.likeCount intValue];
        self.comment.likeCount = [NSNumber numberWithInt:temp + 1];
        self.likeCount.text = [self.comment.likeCount stringValue];
        [Comment favorite:self.comment withValue:self.comment.likeCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error updating comment like count: %@", error.localizedDescription);
            }
        }];
        
    }
    
}

- (IBAction)tapMarkUp:(id)sender {
    [self.delegate didDisplayMarkUp:self.comment.author.username withImage:self.comment.markUp];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
