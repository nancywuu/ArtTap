//
//  FollowListViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/11/22.
//

#import "FollowListViewController.h"
#import "ProfileViewController.h"
#import "FollowTableViewCell.h"
#import "User.h"
#import "Follower.h"

@interface FollowListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation FollowListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowCell" forIndexPath:indexPath];
    NSLog(@"follow user found");
    
    Follower *temp = self.userArray[indexPath.row];
    
    if (self.isFollowing) {
        cell.username.text = [NSString stringWithFormat:@"%s%@", "@", temp.user.username];
        cell.name.text = temp.user.name;
        if(temp.user.profilePic != nil){
            cell.image.file = temp.user.profilePic;
            cell.image.layer.cornerRadius = cell.image.frame.size.width/2;
            cell.image.clipsToBounds = YES;
            [cell.image loadInBackground];
        }
        cell.bio.text = temp.user.bio;
    } else {
        cell.username.text = [NSString stringWithFormat:@"%s%@", "@", temp.follower.username];
        cell.name.text = temp.follower.name;
        if(temp.follower.profilePic != nil){
            cell.image.file = temp.follower.profilePic;
            cell.image.layer.cornerRadius = cell.image.frame.size.width/2;
            cell.image.clipsToBounds = YES;
            [cell.image loadInBackground];
        }
        cell.bio.text = temp.follower.bio;
    }
    
    return cell;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userArray.count;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"followerToProfileSegue"]){
        FollowTableViewCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Follower *dataToPass = self.userArray[path.row];
        ProfileViewController *profileVC = [segue destinationViewController];
        profileVC.isFromTimeline = YES;
        if(self.isFollowing){
            profileVC.currentUser = dataToPass.user;
        } else {
            profileVC.currentUser = dataToPass.follower;
        }
        
    }
}


@end
