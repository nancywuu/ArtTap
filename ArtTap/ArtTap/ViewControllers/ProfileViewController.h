//
//  ProfileViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "Post.h"
#import "User.h"
#import "Follower.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImg;
@property (weak, nonatomic) IBOutlet PFImageView *profileImg;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) User *currentUser;
@property BOOL isFromTimeline;
@property BOOL isFollowing;

@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;

@end

NS_ASSUME_NONNULL_END
