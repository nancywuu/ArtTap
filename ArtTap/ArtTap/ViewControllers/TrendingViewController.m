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
@end

@implementation TrendingViewController
- (IBAction)didChangeSeg:(id)sender {
    [self fetchPosts];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = 150;
    
    [self fetchPosts];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

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
    NSLog(@"comment found");
    Post *post = self.postArray[indexPath.row];
    cell.name.text = post.author.name;
    
    cell.username.text = [@"@" stringByAppendingString:post.author.username];
    cell.date.text = post.createdAt.shortTimeAgoSinceNow;
    
    
    cell.caption.text = post.caption;
    
    cell.previewImage.file = post.image;
    [cell.previewImage loadInBackground];
    
    // get value depending on like or view selection
    NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
    if([title isEqualToString:@"Views"]){
        cell.value.text = [NSString stringWithFormat:@"%@%s", post.numViews, " views"];
    } else {
        cell.value.text = [NSString stringWithFormat:@"%@%s", post.likeCount, " likes"];
    }

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
