//
//  ProfileViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "ProfileViewController.h"
#import "DetailViewController.h"
#import "ProfileCell.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"loaded in PROFILE");
    if(!self.isFromTimeline){
        NSLog(@"detected as not from timeline");
        self.currentUser = User.currentUser;
    } else {
        NSLog(@"from timeline");
    }
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    NSLog(@"%@", self.currentUser.username);

    [self fetchProfile];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchProfile) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (void) fetchProfile {
    self.username.text = self.currentUser.username;
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
            NSLog(@"refresh makequery triggered");
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFFileObject *temp = self.postArray[indexPath.row][@"image"];
    NSLog(@"%@", temp.url);

    //NSURL *url = [NSURL URLWithString:temp.url];

//    [self.tempImage setImageWithURL:url];
//    NSLog(@"%lf", self.tempImage.image.size.width);
//    NSLog(@"%lf", self.tempImage.image.size.height);
    return CGSizeMake(400, 700);
}


- (void) didEdit {
    [self fetchProfile];
}

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //NSLog(@"ahhh collect cell");
    ProfileCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell" forIndexPath:indexPath];
    cell.post = self.postArray[indexPath.row];
    cell.image.file = self.postArray[indexPath.row][@"image"];
    
    
    [cell.image loadInBackground];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
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
        ProfileCell *cell = sender;
        NSIndexPath *path = [self.collectionView indexPathForCell:cell];
        Post *dataToPass = self.postArray[path.row];
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.obj = dataToPass;
    }
}


@end
