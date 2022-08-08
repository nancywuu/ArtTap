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
#import "ArtTap-Swift.h"
#import "PopUpViewController.h"
#import "STPopup/STPopup.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CreateViewControllerDelegate, CHTCollectionViewDelegateWaterfallLayout, UIScrollViewDelegate, HomePhotoCellDelegate>
@property (nonatomic, strong) NSMutableArray *postArray;
@property (nonatomic, strong) NSMutableArray *suggestedArray;
@property (nonatomic, strong) NSMutableArray *homeArray;
@property (nonatomic, strong) NSMutableArray *followFeedArray;
@property (nonatomic, strong) NSArray *followingArray;

@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) BOOL isForYou;
@property (assign, nonatomic) BOOL isGlobal;
@property (assign, nonatomic) BOOL didInitSuggested;
@property (assign, nonatomic) BOOL showHUD;

@property (nonatomic) int postCount;
@property (nonatomic) int suggestedCount;
@property (nonatomic) int incre;
@property (nonatomic) int maxLim;

@property UIColor *backColor;
@property UIColor *frontColor;
@property UIColor *secondaryColor;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet CHTCollectionViewWaterfallLayout *layout;

@end

@implementation HomeViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.incre = 8;
    self.postCount = 8;
    self.suggestedCount = 8;
    self.isForYou = NO;
    self.isGlobal = YES;
    self.didInitSuggested = NO;
    self.showHUD = NO;
    self.postArray = [[NSMutableArray alloc] init];
    self.suggestedArray = [[NSMutableArray alloc] init];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.layout.minimumInteritemSpacing = 0;
    self.layout.minimumColumnSpacing = 0;
    UIEdgeInsets photoInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.layout.sectionInset = photoInsets;
    
    [self makeQuery];
    [self.segCon addTarget:self action:@selector(animate) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(makeQuery) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (void) viewDidAppear:(BOOL)animated {
    [self getMax];
    [self loadFollowers];
    if(!self.didInitSuggested){
        [self loadhud];
    }
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
    self.collectionView.backgroundColor = self.backColor;
    self.tabBarController.tabBar.tintColor = self.secondaryColor;
    self.tabBarController.tabBar.backgroundColor = self.backColor;
    self.navigationController.navigationBar.backgroundColor = self.backColor;

    self.segCon.backgroundColor = self.secondaryColor;
    self.segCon.tintColor = self.frontColor;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:self.frontColor}];
    [self.tabBarController.tabBar setBarTintColor: self.backColor];
}

#pragma mark - Response

- (IBAction)changedFeedType:(id)sender {
    NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
    if([title isEqualToString:@"Following"]){
        self.postCount = (int)self.followingArray.count + self.incre;
        self.isForYou = NO;
        self.isGlobal = NO;
        self.postArray = [self.followingArray mutableCopy];
        [self.collectionView reloadData];
        [self makeQuery];
    } else if([title isEqualToString:@"Suggested"]){
        self.postCount = self.suggestedCount;
        self.isForYou = YES;
        self.isGlobal = NO;

        self.postArray = [self.suggestedArray mutableCopy];
        [self.collectionView reloadData];
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        [self.refreshControl endRefreshing];
        [self.collectionView setContentOffset:CGPointZero animated:YES];
    } else {
        self.postCount = (int)self.homeArray.count + self.incre;
        self.isForYou = NO;
        self.isGlobal = YES;
        self.postArray = [self.homeArray mutableCopy];
        [self.collectionView reloadData];
        [self makeQuery];
    }
}

- (void)animate {
    [UIView animateWithDuration:1 animations:^{ self.collectionView.alpha = 0.3; self.collectionView.alpha = 0.3; }];
    [UIView animateWithDuration:1 animations:^{ self.collectionView.alpha = 1; self.collectionView.alpha = 1; }];
}

- (IBAction)didLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }];
}

// delegate method to act after creating a new post
- (void) didPost {
    self.postCount = self.incre;
    [self.postArray removeAllObjects];
    [self makeQuery];
}

// delegate method to act after long gesture recognizer to preview post in feed
- (void) didPreview:(Post *)current {
    Post *ourPost = current;
    PopUpViewController *ourPopController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpPreviewController"];
    //ourPopController.currentPost = ourPost;
    ourPopController.chosenImage = ourPost.image;
    ourPopController.chosenUsername = ourPost.author.username;
    
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:ourPopController];
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.containerView.backgroundColor = [UIColor clearColor];

    [popupController presentInViewController:self];
}

#pragma mark - Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFFileObject *temp = self.postArray[indexPath.row][@"image"];
    NSData *data = [temp getData];
    UIImage *tempImage = [UIImage imageWithData:data];
    return CGSizeMake(tempImage.size.width, tempImage.size.height);
}

#pragma mark - Feed Management

/* This method is used to find the maximum amount of posts we can query for
 the suggested feed. This is to insure that we do not query for more beyond
 the limit which would cause errors */
- (void) getMax {
    PFQuery *sampleQuery = [PFQuery queryWithClassName:@"Post"];
    [sampleQuery includeKey:@"author"];
    [sampleQuery includeKey:@"createdAt"];
    [sampleQuery orderByDescending:(@"numViews")];
    PFUser *temp = User.currentUser;
    [sampleQuery whereKey:@"author" notEqualTo:temp];
    NSArray *arr = [sampleQuery findObjects];
    
    self.maxLim = (int)arr.count;
}

/* loads a list of users that the current user is following. This is used for
 the 'Following' feed */
- (void) loadFollowers {
    PFQuery *followingQ = [PFQuery queryWithClassName:@"Follower"];
    [followingQ includeKey:@"user"];
    [followingQ includeKey:@"follower"];
    [followingQ whereKey:@"follower" equalTo: User.currentUser];
    
    [followingQ findObjectsInBackgroundWithBlock:^(NSArray *res, NSError *error) {
        if (res != nil) {
            NSMutableArray *tempArr = [NSMutableArray new];
            for(int i = 0; i < res.count; i++){
                Follower *current = res[i];
                [tempArr addObject:current.user];
            }
            self.followingArray = [tempArr copy];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

/* Queries for ten more posts for the suggested feed based on view count,
 and sorts them depending on similarity to the current user's posts */
- (void) loadSuggested {

    Suggested *creator = [[Suggested alloc] init];

    // query for next ten posts to sort
    PFQuery *sampleQuery = [PFQuery queryWithClassName:@"Post"];
    [sampleQuery includeKey:@"author"];
    [sampleQuery includeKey:@"createdAt"];
    [sampleQuery orderByDescending:(@"numViews")];
    PFUser *temp = User.currentUser;
    [sampleQuery whereKey:@"author" notEqualTo:temp];
    sampleQuery.limit = self.suggestedCount;
    
    NSRange range;
    range.location = self.suggestedCount - self.incre;
    NSArray *firstres = [sampleQuery findObjects];
    
    if((int)firstres.count >= range.location){
        if((int)firstres.count < self.suggestedCount){
            range.length = (int)firstres.count - range.location;
        } else {
            range.length = self.incre;
        }
        creator.sampleArray = [firstres subarrayWithRange:range];
        
        // query for user's own posts to compare to
        PFQuery *origQuery = [PFQuery queryWithClassName:@"Post"];
        [origQuery includeKey:@"author"];
        [origQuery includeKey:@"createdAt"];
        [origQuery orderByDescending:(@"createdAt")];
        [origQuery whereKey:@"author" equalTo: temp];
        origQuery.limit = 1;

        NSArray *tempRes = [origQuery findObjects];
        
        NSMutableArray *tempArr = [NSMutableArray new];
        
        for(int i = 0; i < tempRes.count; i++){
            Post *temp = tempRes[i];
            NSURL *url = [NSURL URLWithString:temp.image.url];
            tempArr[i] = url;
        }
        
        creator.urlArray = tempArr;
        [creator processImages];
        
        [self.suggestedArray addObjectsFromArray:creator.resArray];
    }
}

/* load suggested posts in the background using low priority queue
 used to load suggested posts even when not looking at suggested feed */
- (void) loadhud {
    if(self.suggestedCount + self.incre < self.maxLim){
        self.suggestedCount += self.incre;
        if(self.isForYou && self.showHUD){
            // we only want to show the activity loader if we are at the bottom
            // of the feed
            [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self loadSuggested];
                [self completehud];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self loadSuggested];
                [self completehud];
            });
        }
        
    }
}

/* complete loading in background, HUD loader must be hidden using the
 main queue, but we want this to happen after we've finished loading
 suggested posts in the low priority queue.
 If we are on the suggested feed, load into collectionview */
- (void) completehud {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.isForYou){
            self.postCount = self.suggestedCount;
            self.postArray = [self.suggestedArray mutableCopy];
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
            if(self.showHUD){
                [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
                self.showHUD = NO;
            }
        }
        if(!self.didInitSuggested){
            self.didInitSuggested = YES;
        }
    });
}

/* queries for Global and Following feed */
- (void) makeQuery {
    if(self.isForYou && !self.didInitSuggested){
        if(self.suggestedCount > self.incre){
            [self loadhud];
        }
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        [query includeKey:@"author"];
        [query includeKey:@"createdAt"];
        [query includeKey:@"likeCount"];
        [query includeKey:@"commentCount"];
        [query orderByDescending:(@"createdAt")];
        
        // if on Following feed, we need to filter the posts
        if(!self.isGlobal){
            [self loadFollowers];
            [query whereKey:@"author" containedIn:self.followingArray];
        }
        
        query.limit = self.postCount;
        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
            int base = (int)self.postArray.count;
            int end = (int)posts.count;
            if(base != end){
                for(int i = base; i < end; i++){
                    [self.postArray addObject:posts[i]];
                }
                if(self.isGlobal){
                    self.homeArray = [self.postArray mutableCopy];
                } else {
                    self.followingArray = [self.postArray mutableCopy];
                }
                [self.collectionView reloadData];
            }
        }];
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Collection View Loading

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomePhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"homeCell" forIndexPath:indexPath];
    cell.image.file = self.postArray[indexPath.row][@"image"];
    cell.clipsToBounds = true;
    cell.layer.cornerRadius = 40;
    cell.layer.masksToBounds = YES;

    cell.post = self.postArray[indexPath.row];
    cell.delegate = self;
    [cell.image loadInBackground];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.postArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.navigationController.navigationBar.backgroundColor = self.backColor;
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    // if we are scrolling in the feed, we want to load posts in advance
    int multiplier = 1;
    if(self.isForYou){
        // want to load posts further in advance if directly on Suggested Feed, because the user will be scrolling
        multiplier = 2.5;
    }

    if(indexPath.row + self.incre*multiplier >= self.suggestedCount && self.didInitSuggested){
        [self loadhud];
    }
    
    // if we've hit the bottom of the currently loaded posts
    if(indexPath.row + 1 == [self.postArray count]){
        if(self.isForYou){
            self.showHUD = YES;
            [self loadhud];
        } else {
            self.postCount += self.incre;
            [self makeQuery];
        }
        
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
