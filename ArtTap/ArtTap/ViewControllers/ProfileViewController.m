//
//  ProfileViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "ProfileViewController.h"
#import "EditViewController.h"
#import "DetailViewController.h"
#import "FollowListViewController.h"
#import "ProfileTableViewCell.h"
#import "Notifications.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, EditViewDelegate>
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) NSArray *followingArray;
@property (nonatomic, strong) NSArray *followersArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.isFromTimeline){
        self.currentUser = User.currentUser;
        self.followButton.hidden = YES;
    } else if ([self.currentUser.objectId isEqualToString:User.currentUser.objectId]){
        self.followButton.hidden = YES;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = 300;

    [self fetchProfile];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchProfile) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) fetchProfile {
    [self checkFollow];
    [self loadFollowers];

    self.username.text = [@"@" stringByAppendingString:self.currentUser.username];
    self.name.text = self.currentUser.name;
    self.bio.text = self.currentUser.bio;

    //self.data = self.currentUser.profileImage.getData();
    if(self.currentUser.profilePic != nil){
        self.profileImg.file = self.currentUser.profilePic;
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2;
        self.profileImg.clipsToBounds = YES;
        [self.profileImg loadInBackground];
    }
    self.backgroundImg.file = self.currentUser.backgroundPic;
    [self.backgroundImg loadInBackground];
    
    NSLog(@"%lu", self.followersArray.count);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query orderByDescending:(@"createdAt")];
    PFUser *temp = self.currentUser;
    [query whereKey:@"author" equalTo: temp];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postArray = posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void) loadFollowers {
    PFQuery *followerQ = [PFQuery queryWithClassName:@"Follower"];
    [followerQ includeKey:@"user"];
    [followerQ includeKey:@"follower"];
    [followerQ whereKey:@"user" equalTo: self.currentUser];
    
    [followerQ findObjectsInBackgroundWithBlock:^(NSArray *res, NSError *error) {
        if (res != nil) {
            self.followersArray = res;
            [self.followersButton setTitle:[NSString stringWithFormat:@"%lu%s", self.followersArray.count, " followers"] forState:UIControlStateNormal];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    PFQuery *followingQ = [PFQuery queryWithClassName:@"Follower"];
    [followingQ includeKey:@"user"];
    [followingQ includeKey:@"follower"];
    [followingQ whereKey:@"follower" equalTo: self.currentUser];
    
    [followingQ findObjectsInBackgroundWithBlock:^(NSArray *res, NSError *error) {
        if (res != nil) {
            self.followingArray = res;
            [self.followingButton setTitle:[NSString stringWithFormat:@"%lu%s", self.followingArray.count, " following"] forState:UIControlStateNormal];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) checkFollow {
    PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
    [query includeKey:@"user"];
    [query includeKey:@"follower"];
    [query whereKey:@"user" equalTo: self.currentUser];
    [query whereKey:@"follower" equalTo: User.currentUser];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable follow, NSError * _Nullable error) {
        if (follow != nil) {
            NSLog(@"found a follow obj in setup");
            self.isFollowing = YES;
            [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor blackColor];
        } else {
            NSLog(@"did not find a follow obj in setup");
            self.isFollowing = NO;
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            self.followButton.backgroundColor = [UIColor systemBlueColor];
        }
    }];
}

- (IBAction)didFollow:(id)sender {
    if(self.isFollowing){
        // unfollow
        self.isFollowing = NO;
        //self.followButton.backgroundColor = [UIColor systemBlueColor];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
        [query includeKey:@"user"];
        [query includeKey:@"follower"];
        [query whereKey:@"user" equalTo: self.currentUser];
        [query whereKey:@"follower" equalTo: User.currentUser];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable follow, NSError * _Nullable error) {
            if (follow != nil) {
                NSLog(@"found a follow obj in setup");
                [follow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"succeeded in deleting like boolean obj");
                        [self loadFollowers];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"none found or error");
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
    } else {
        // follow
        self.isFollowing = YES;
        //self.followButton.backgroundColor = [UIColor blackColor];
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        
        [Follower follow:self.currentUser withFollower:User.currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error following: %@", error.localizedDescription);
            } else {
                 NSLog(@"Successfully followed user: %@", self.currentUser.objectId);
                [self loadFollowers];
            }
        }];
        
        [Notifications notif:nil withAuthor:self.currentUser withType:@(3) withText:@"" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully send like notif");
             }
        }];
    }
    [self loadFollowers];
}

- (void) didEdit {
    [self fetchProfile];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"ahhh collect cell");
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    cell.post = self.postArray[indexPath.row];
    cell.image.file = self.postArray[indexPath.row][@"image"];
    
    
    [cell.image loadInBackground];
    return cell;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.postArray.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if([segue.identifier isEqualToString:@"editSegue"]){
//         *detailVC = [segue destinationViewController];
//    } else if ([segue.identifier isEqualToString:@"insightsSegue"]) {
//        UINavigationController *nav = [segue destinationViewController];
//        ComposeViewController *composeVC = (ComposeViewController *)nav.topViewController;
//        composeVC.delegate = self;
//    }
    if([segue.identifier isEqualToString:@"detailFromProfileSegue"]){
        ProfileTableViewCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Post *dataToPass = self.postArray[path.row];
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.obj = dataToPass;
    } else if ([segue.identifier isEqualToString:@"editSegue"]){
        EditViewController *editVC = [segue destinationViewController];
        editVC.delegate = self;
        editVC.currentProfileImage = self.profileImg.image;
        editVC.currentBackgroundImage = self.backgroundImg.image;
    } else if ([segue.identifier isEqualToString:@"followingSegue"]){
        FollowListViewController *followVC = [segue destinationViewController];
        followVC.userArray = self.followingArray;
        followVC.isFollowing = YES;
    } else if ([segue.identifier isEqualToString:@"followerSegue"]){
        FollowListViewController *followVC = [segue destinationViewController];
        followVC.userArray = self.followersArray;
        followVC.isFollowing = NO;
    }
}


@end
