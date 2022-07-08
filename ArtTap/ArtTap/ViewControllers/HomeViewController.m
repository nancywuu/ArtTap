//
//  HomeViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DetailViewController.h"
#import "CreateViewController.h"
#import "UIImageView+AFNetworking.h"
#import "HomePhotoCell.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "DateTools.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CreateViewControllerDelegate, CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *tempImage;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self makeQuery];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(makeQuery) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)didLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
//        [self dismissViewControllerAnimated:true completion:nil];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        NSLog(@"tapped logout");
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFFileObject *temp = self.postArray[indexPath.row][@"image"];
    NSLog(@"%@", temp.url);
    
    [temp getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error == nil) {
//            self.tempImage = [UIImage imageWithData:data];
            self.tempImage = [UIImage imageWithData:data];
//            width = image.size.width;
//            height = image.size.height;
            NSLog(@"%lf", self.tempImage.size.width);
            NSLog(@"%lf", self.tempImage.size.height);
            NSLog(@"Image loaded");
            return CGSizeMake(self.tempImage.size.width, self.tempImage.size.height);
        } else {
            NSLog(@"Error loading image");
        }
    }];
    NSLog(@"%lf", self.tempImage.size.width);
    NSLog(@"%lf", self.tempImage.size.height);
    return CGSizeMake(400, 600);
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
    //query.limit = self.postCount;

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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    int totalwidth = self.collectionView.bounds.size.width;
//    int numberOfCellsPerRow = 3;
//    //int oddEven = indexPath.row / numberOfCellsPerRow % 2;
//    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow) - 10;
//    return CGSizeMake(dimensions, dimensions);
//}

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //NSLog(@"ahhh collect cell");
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
