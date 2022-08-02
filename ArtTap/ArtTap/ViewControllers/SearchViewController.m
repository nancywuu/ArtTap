//
//  SearchViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "UIImageView+AFNetworking.h"
#import "ProfileViewController.h"
#import "User.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *searchData;
@property (nonatomic, strong) NSArray *userArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *searchTitle;
@property (weak, nonatomic) IBOutlet UIView *smallView;

@property UIColor *backColor;
@property UIColor *frontColor;
@property UIColor *secondaryColor;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchbar.delegate = self;
    self.tableView.rowHeight = 200;
    
    [self fetchUsers];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchUsers) forControlEvents:UIControlEventValueChanged];
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
    self.smallView.backgroundColor = self.backColor;
    self.tableView.backgroundColor = self.backColor;
    self.searchbar.barTintColor = self.secondaryColor;
    self.searchTitle.textColor = self.frontColor;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:self.frontColor}];
    [self.tabBarController.tabBar setBarTintColor: self.backColor];
    [self.tableView reloadData];
}

- (void) fetchUsers {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.userArray = users;
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(User *evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject.username lowercaseString] containsString:[searchText lowercaseString]];
        }];
        self.searchData = [self.userArray filteredArrayUsingPredicate:predicate];
    }

    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    User *temp = self.searchData[indexPath.row];
    cell.name.text = temp.name;
    cell.bio.text = temp.bio;
    cell.username.text = [NSString stringWithFormat:@"%s%@", "@", temp.username];
    
    cell.profileImage.file = temp.profilePic;
    [cell.profileImage loadInBackground];
    
    PFQuery *followerQ = [PFQuery queryWithClassName:@"Follower"];
    [followerQ includeKey:@"user"];
    [followerQ includeKey:@"follower"];
    [followerQ whereKey:@"user" equalTo: temp];
    
    [followerQ findObjectsInBackgroundWithBlock:^(NSArray *res, NSError *error) {
        if (res != nil) {
            cell.followCount.text = [NSString stringWithFormat:@"%ld%@",(long) res.count, @" followers"];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    cell.backgroundColor = self.backColor;
    cell.name.textColor = self.frontColor;
    cell.username.textColor = self.frontColor;
    cell.bio.textColor = self.frontColor;
    
    return cell;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchData.count;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"searchShow"]){
        SearchCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        User *dataToPass = self.searchData[path.row];
        ProfileViewController *profileVC = [segue destinationViewController];
        profileVC.isFromTimeline = YES;
        profileVC.currentUser = dataToPass;
    }
}

@end
