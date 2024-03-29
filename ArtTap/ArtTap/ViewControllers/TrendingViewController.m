//
//  TrendingViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import "TrendingViewController.h"
#import "ProfileViewController.h"
#import "DetailViewController.h"
#import "TrendTableCell.h"
#import "DateTools.h"

@interface TrendingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *postArray;
@property BOOL isByView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *smallView;

@property UIColor *backColor;
@property UIColor *frontColor;
@property UIColor *secondaryColor;
@property UIColor *customColor;
@property UIColor *customColorDarker;

@end

@implementation TrendingViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 150;
    self.customColor = [UIColor colorWithRed: 0.82 green: 0.72 blue: 0.94 alpha: 1.00];
    self.customColorDarker = [UIColor colorWithRed: 0.64 green: 0.48 blue: 0.90 alpha: 1.00];
    
    [self fetchPosts];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setColors];
}

#pragma mark - Color Mode

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
    self.smallView.backgroundColor = self.backColor;
    self.topTitle.textColor = self.frontColor;
    self.segCon.backgroundColor = self.customColor;
    self.timeCon.backgroundColor = self.customColor;
    [self.tableView setSeparatorColor:self.frontColor];
    
    self.tabBarController.tabBar.tintColor = self.customColorDarker;
    self.tabBarController.tabBar.unselectedItemTintColor = self.customColor;
    self.tabBarController.tabBar.backgroundColor = self.backColor;
    self.navigationController.navigationBar.tintColor = self.customColorDarker;
    self.navigationController.navigationBar.backgroundColor = self.backColor;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:self.frontColor}];
    [self.tabBarController.tabBar setBarTintColor: self.backColor];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)didChangeSeg:(id)sender {
    [self fetchPosts];
}
- (IBAction)didChangeTime:(id)sender {
    [self fetchPosts];
}

#pragma mark - Tableview

- (void) fetchPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"likeCount"];
    [query includeKey:@"numViews"];
    
    // fetch based on views or likes selection
    NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
    if([title isEqualToString:@"Views"]){
        [query orderByDescending:(@"numViews")];
    } else {
        [query orderByDescending:(@"likeCount")];
    }
    
    NSString *time = [self.timeCon titleForSegmentAtIndex:self.timeCon.selectedSegmentIndex];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];

    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *tonightEnd = [calendar dateFromComponents:components];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:1];
    if([time isEqualToString:@"Today"]){
        NSDate *start = [calendar dateFromComponents:components];
        [query whereKey:@"createdAt" greaterThan:start];
        [query whereKey:@"createdAt" lessThan:tonightEnd];
    } else if([time isEqualToString:@"This Week"]){
        NSDate *start = [now dateByAddingTimeInterval: -518400.0];
        [query whereKey:@"createdAt" greaterThan:start];
        [query whereKey:@"createdAt" lessThan:tonightEnd];
    }
    
    query.limit = 10;

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TrendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trendCell" forIndexPath:indexPath];
    Post *post = self.postArray[indexPath.row];
    cell.name.text = post.author.name;
    cell.username.text = [@"@" stringByAppendingString:post.author.username];
    cell.date.text = post.createdAt.shortTimeAgoSinceNow;
    cell.caption.text = post.caption;
    
    cell.previewImage.file = post.image;
    [cell.previewImage loadInBackground];
    
    NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
    if([title isEqualToString:@"Views"]){
        cell.value.text = [NSString stringWithFormat:@"%@%s", post.numViews, " views"];
    } else {
        cell.value.text = [NSString stringWithFormat:@"%@%s", post.likeCount, " likes"];
    }
    
    cell.backgroundColor = self.backColor;
    cell.name.textColor = self.frontColor;
    cell.username.textColor = self.frontColor;
    cell.date.textColor = self.frontColor;
    cell.caption.textColor = self.frontColor;
    cell.value.textColor = self.frontColor;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = self.secondaryColor;
    [cell setSelectedBackgroundView:bgColorView];

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
    if([segue.identifier isEqualToString:@"trendDetailSegue"]){
        TrendTableCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Post *dataToPass = self.postArray[path.row];
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.obj = dataToPass;
    }
}


@end
