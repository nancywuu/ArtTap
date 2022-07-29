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
#import "Liked.h"
#import "Comment.h"
#import "ArtTap-Swift.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, EditViewDelegate>
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) NSArray *postIDArray;
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
    self.tableView.rowHeight = 500;

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

    if(self.currentUser.profilePic != nil){
        self.profileImg.file = self.currentUser.profilePic;
        self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2;
        self.profileImg.clipsToBounds = YES;
        [self.profileImg loadInBackground];
    }
    self.backgroundImg.file = self.currentUser.backgroundPic;
    [self.backgroundImg loadInBackground];
    
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
            NSMutableArray *temp = [NSMutableArray new];
            for(int i = 0; i < posts.count; i++){
                Post *current = posts[i];
                [temp addObject: current.objectId];
            }
            self.postIDArray = [temp copy];
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
        self.isFollowing = NO;
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Follower"];
        [query includeKey:@"user"];
        [query includeKey:@"follower"];
        [query whereKey:@"user" equalTo: self.currentUser];
        [query whereKey:@"follower" equalTo: User.currentUser];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable follow, NSError * _Nullable error) {
            if (follow != nil) {
                [follow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"succeeded in deleting like boolean obj");
                        [self loadFollowers];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        
    } else {
        // follow
        self.isFollowing = YES;
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        
        [Follower follow:self.currentUser withFollower:User.currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error following: %@", error.localizedDescription);
            } else {
                [self loadFollowers];
            }
        }];
        
        [Notifications notif:nil withAuthor:self.currentUser withType:@(3) withText:@"" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
        }];
    }
    [self loadFollowers];
}

- (void) didEdit {
    [self fetchProfile];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    } else if (([segue.identifier isEqualToString:@"insightsSegue"])){
        GraphViewController *graphVC = [segue destinationViewController];
    
        PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
        [query includeKey:@"postID"];
        [query includeKey:@"userID"];
        [query includeKey:@"isEngage"];
        [query includeKey:@"createdAt"];
        [query whereKey:@"postID" containedIn:self.postIDArray];

        NSArray *tempRes = [query findObjects];
        
        PFQuery *comquery = [PFQuery queryWithClassName:@"Comment"];
        [comquery includeKey:@"postID"];
        [comquery includeKey:@"createdAt"];
        [comquery whereKey:@"postID" equalTo: self.postIDArray];

        NSArray *comRes = [comquery findObjects];
        
        NSMutableArray *tempEngageArr = [NSMutableArray new];
        NSMutableArray *tempLikeArr = [NSMutableArray new];
        NSMutableArray *tempComArr = [NSMutableArray new];
        NSMutableArray *tempCritArr = [NSMutableArray new];
        for (int i = 0; i < 730; ++i){
            [tempEngageArr addObject:[NSNumber numberWithInt:0]];
            [tempLikeArr addObject:[NSNumber numberWithInt:0]];
            [tempComArr addObject:[NSNumber numberWithInt:0]];
            [tempCritArr addObject:[NSNumber numberWithInt:0]];
        }
            
        for(int i = 0; i < tempRes.count; i++){
            Liked *temp = tempRes[i];
            NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];
    
            if(hours < 730){
                if(temp.isEngage){
                    tempEngageArr[hours] = [NSNumber numberWithInteger:[tempEngageArr[hours] integerValue] + 1];
                } else {
                    tempLikeArr[hours] = [NSNumber numberWithInteger:[tempLikeArr[hours] integerValue] + 1];
                }

            }
        }
        
        for(int i = 0; i < comRes.count; i++){
            Comment *temp = comRes[i];
            NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];
    
            if(hours < 730){
                if(temp.critBool){
                    tempCritArr[hours] = [NSNumber numberWithInteger:[tempCritArr[hours] integerValue] + 1];
                } else {
                    tempComArr[hours] = [NSNumber numberWithInteger:[tempComArr[hours] integerValue] + 1];
                }
            }
        }

        graphVC.engageArray = tempEngageArr;
        graphVC.likeArray = tempLikeArr;
        graphVC.commentArray = tempComArr;
        graphVC.critArray = tempCritArr;
        //graphVC.viewArray = self.obj.viewTrack;
    }
}


@end
