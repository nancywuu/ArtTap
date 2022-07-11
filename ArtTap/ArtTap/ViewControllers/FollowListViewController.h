//
//  FollowListViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FollowListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *userArray;
@property BOOL isFollowing;

@end

NS_ASSUME_NONNULL_END
