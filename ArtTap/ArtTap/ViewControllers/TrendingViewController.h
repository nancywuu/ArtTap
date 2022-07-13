//
//  TrendingViewController.h
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrendingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segCon;


@end

NS_ASSUME_NONNULL_END
