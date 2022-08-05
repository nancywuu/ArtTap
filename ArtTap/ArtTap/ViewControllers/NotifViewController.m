//
//  NotifViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "NotifViewController.h"
#import "ProfileViewController.h"
#import "DetailViewController.h"
#import "User.h"
#import "NotifCell.h"
#import "Notifications.h"
@import Parse;

@interface NotifViewController () <UITableViewDataSource, UITableViewDelegate, NotifCellDelegate>
@property (nonatomic, strong) NSArray *notifArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NotifCell *selectedCell;

@property UIColor *backColor;
@property UIColor *frontColor;
@property UIColor *secondaryColor;

@end

@implementation NotifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    [self.tabBarController.tabBar setBarTintColor: self.backColor];
    
    [self fetchNotifs];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchNotifs) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setColors];
}

- (void) setColors {
    if(User.currentUser.darkmode == YES){
        self.backColor = UIColor.blackColor;
        self.frontColor = UIColor.whiteColor;
        self.secondaryColor = UIColor.darkGrayColor;
    } else {
        self.backColor = UIColor.whiteColor;
        self.frontColor = UIColor.blackColor;
        self.secondaryColor = UIColor.lightGrayColor;
    }
    
    self.view.backgroundColor = self.backColor;
    self.tableView.backgroundColor = self.backColor;
    self.tabBarController.tabBar.tintColor = self.secondaryColor;
    self.tabBarController.tabBar.backgroundColor = self.backColor;
    self.navigationController.navigationBar.backgroundColor = self.backColor;

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:self.frontColor}];
    [self.tabBarController.tabBar setBarTintColor: self.backColor];
    [self.tableView reloadData];
}

- (void) fetchNotifs {
    PFQuery *query = [PFQuery queryWithClassName:@"Notifications"];
    [query includeKey:@"author"];
    [query includeKey:@"post"];
    [query includeKey:@"text"];
    [query includeKey:@"creator"];
    [query includeKey:@"createdAt"];
    [query whereKey:@"author" equalTo: [User currentUser]];
    [query orderByDescending:(@"createdAt")];

    query.limit = 10;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *notifs, NSError *error) {
        if (notifs != nil) {
            self.notifArray = notifs;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)didTapNotif:(NotifCell *)cell {
    NSLog(@"delegate triggered");
    if(cell.isFollow){
        [self performSegueWithIdentifier:@"notifToProfile" sender:cell];
    } else {
        [self performSegueWithIdentifier:@"notifToDetail" sender:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotifCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notifCell" forIndexPath:indexPath];
    Notifications *notif = self.notifArray[indexPath.row];
    
    int temp = [notif.notifType intValue];
    
    if(temp == 0){
        // comment
        cell.title.text = [NSString stringWithFormat:@"%s%@%s", "@", notif.creator.username, " commented on your post"];
        cell.text.text = [NSString stringWithFormat:@"\"%@\"", notif.text];
        cell.previewImage.file = notif.post.image;
        [cell.previewImage loadInBackground];
        cell.isFollow = NO;
    } else if (temp == 1){
        // critique
        cell.title.text = [NSString stringWithFormat:@"%s%@%s", "@", notif.creator.username, " left a critique on your post"];
        cell.text.text = [NSString stringWithFormat:@"\"%@\"", notif.text];
        cell.previewImage.file = notif.post.image;
        [cell.previewImage loadInBackground];
        cell.isFollow = NO;
    } else if (temp == 2){
        // like
        cell.title.text = [NSString stringWithFormat:@"%s%@%s", "@", notif.creator.username, " liked your post"];
        cell.text.text = @"";
        cell.previewImage.file = notif.post.image;
        [cell.previewImage loadInBackground];
        cell.isFollow = NO;
    } else if (temp == 3){
        // follow
        cell.title.text = [NSString stringWithFormat:@"%s%@%s", "@", notif.creator.username, " followed you"];
        cell.text.text = @"";
        cell.previewImage.file = notif.creator.profilePic;
        [cell.previewImage loadInBackground];
        cell.isFollow = YES;
    }
    
    cell.backgroundColor = self.backColor;
    cell.title.textColor = self.frontColor;
    cell.text.textColor = self.frontColor;
    
    cell.delegate = self;
    return cell;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notifArray.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (([segue.identifier isEqualToString:@"notifToProfile"])){
        NotifCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Notifications *dataToPass = self.notifArray[path.row];
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.isFromTimeline = YES;
        profileViewController.currentUser = dataToPass.creator;
    } else if (([segue.identifier isEqualToString:@"notifToDetail"])){
        NotifCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Notifications *dataToPass = self.notifArray[path.row];

        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.obj = dataToPass.post;
        
//        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
//        [query includeKey:@"author"];
//        [query includeKey:@"objectId"];
//        [query includeKey:@"createdAt"];
//        [query includeKey:@"likeCount"];
//        [query includeKey:@"commentCount"];
//        [query orderByDescending:(@"createdAt")];
//        NSString *temp = dataToPass.post.objectId;
//        [query whereKey:@"objectId" equalTo: temp];
//
//        NSLog(@"%@", dataToPass.post.objectId);
//
//        query.limit = 2;
//
//        // fetch data asynchronously
//        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
//            if (posts != nil) {
//                NSLog(@"found the post, trying to segue");
//
//            } else {
//                NSLog(@"%@", error.localizedDescription);
//            }
//        }];
    }
}


@end
