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
    cell.username.text = [NSString stringWithFormat:@"%s%@", "@", temp.username];
    
    cell.profileImage.file = temp.profilePic;
    [cell.profileImage loadInBackground];
    
    
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
