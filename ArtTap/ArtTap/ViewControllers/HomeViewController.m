//
//  HomeViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "DetailViewController.h"
#import "CreateViewController.h"
#import "UIImageView+AFNetworking.h"
#import "HomePhotoCell.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "DateTools.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CreateViewControllerDelegate, CHTCollectionViewDelegateWaterfallLayout, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *tempImage;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (nonatomic) int postCount;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postCount = 8;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self makeQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(makeQuery) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}


- (IBAction)didLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFFileObject *temp = self.postArray[indexPath.row][@"image"];
    NSData *data = [temp getData];
    self.tempImage = [UIImage imageWithData:data];
    return CGSizeMake(772, 960);
}

- (void) didPost {
    NSLog(@"didPost delegate triggered");
    [self makeQuery];
}

- (void) makeQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"likeCount"];
    [query includeKey:@"commentCount"];
    [query orderByDescending:(@"createdAt")];
    query.limit = self.postCount;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postArray = posts;
            NSLog(@"refresh makequery triggered");
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomePhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"homeCell" forIndexPath:indexPath];
    cell.image.file = self.postArray[indexPath.row][@"image"];
    cell.clipsToBounds = true;
    cell.layer.cornerRadius = 15;
    
    cell.post = self.postArray[indexPath.row];
    [cell.image loadInBackground];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.postArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading){
        int scrollViewContentHeight = self.collectionView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.collectionView.bounds.size.height;
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging) {
            self.isMoreDataLoading = true;
            [self makeQuery];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row + 1 == [self.postArray count]){
        self.postCount += 8;
        [self makeQuery];
    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"composeSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        CreateViewController *createVC = (CreateViewController *)nav.topViewController;
        createVC.delegate = self;
    } else if([segue.identifier isEqualToString:@"detailsSegue"]){
        HomePhotoCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        Post *dataToPass = self.postArray[path.row];
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.obj = dataToPass;
    } else if (([segue.identifier isEqualToString:@"profileSegue"])){
        User *temp = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.isFromTimeline = YES;
        profileViewController.currentUser = temp;
    }
}


@end
