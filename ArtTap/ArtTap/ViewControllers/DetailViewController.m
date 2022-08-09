//
//  DetailViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/7/22.
//

#import "DetailViewController.h"
#import "Comment.h"
#import "Post.h"
#import "Liked.h"
#import "CommentCell.h"
#import "ProfileViewController.h"
#import "DateTools.h"
#import "Notifications.h"
#import "ArtTap-Swift.h"
#import <AVFoundation/AVFoundation.h>
#import "PopUpViewController.h"
#import "STPopup/STPopup.h"
#import <AVKit/AVKit.h>

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CommentCellDelegate, UIGestureRecognizerDelegate,
                                    DrawViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *speedpaintButton;
@property (weak, nonatomic) IBOutlet UIButton *markUpButton;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIView *smallView;
@property (weak, nonatomic) IBOutlet UIImageView *heartPopup;

@property (nonatomic, strong) NSArray *commentArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property UIImage *markUp;
@property BOOL didMarkUp;

@property UIColor *backColor;
@property UIColor *frontColor;
@property UIColor *secondaryColor;
@property UIColor *customColor;
@property UIColor *customColorDarker;

@property AVPlayerViewController *playerController;
@property AVPlayerLayer *playerLayer;
@property AVPlayer *player;

@end

@implementation DetailViewController
- (IBAction)segChanged:(id)sender {
    [self fetchComments];
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare and initialize
    [self refreshUser];
    [self checkEngage];
    [self setTapGestures];
    self.customColor = [UIColor colorWithRed: 0.82 green: 0.72 blue: 0.94 alpha: 1.00];
    self.customColorDarker = [UIColor colorWithRed: 0.64 green: 0.48 blue: 0.90 alpha: 1.00];

    self.didMarkUp = NO;
    self.playerController = [[AVPlayerViewController alloc] init];
    if(self.obj.speedpaint == nil){
        self.speedpaintButton.hidden = YES;
    }

    [Post viewed:self.obj withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
         if(error){
              NSLog(@"Error updating post views: %@", error.localizedDescription);
         } else {
             NSLog(@"Successfully updated post views: %@", self.obj.numViews);
         }
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    
    [self fetchComments];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setColors];
}

#pragma mark - Initiators

- (void)setDetails {
    self.username.text = self.obj.author.username;

    User *temp = self.obj.author;
    self.username.text = [@"@" stringByAppendingString:temp.username];
    self.name.text = self.obj.author.name;
    self.date.text = self.obj.createdAt.shortTimeAgoSinceNow;
    self.postImage.file = self.obj.image;
    self.profileImage.file = self.obj.author.profilePic;
    [self.profileImage loadInBackground];
    self.caption.text = self.obj.caption;
    
    if([self.obj.likeCount intValue] == 1){
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " like"];
    } else {
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " likes"];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
    [query includeKey:@"postID"];
    [query includeKey:@"userID"];
    [query orderByDescending:(@"createdAt")];
    [query whereKey:@"postID" equalTo: self.obj.objectId];
    [query whereKey:@"userID" equalTo: User.currentUser.objectId];
    [query whereKey:@"isEngage" equalTo: [NSNumber numberWithBool:NO]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable like, NSError * _Nullable error) {
        if (like != nil) {
            self.liked = YES;
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        } else {
            self.liked = NO;
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }];
}

- (void)checkCommentLikes: (CommentCell *)cell {
    PFQuery *query = [PFQuery queryWithClassName:@"CommentLikes"];
    [query includeKey:@"userID"];
    [query includeKey:@"commentID"];
    [query whereKey:@"commentID" equalTo: cell.comment.objectId];
    [query whereKey:@"userID" equalTo: User.currentUser.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable like, NSError * _Nullable error) {
        if (like != nil) {
            cell.liked = YES;
            [cell.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        } else {
            cell.liked = NO;
            [cell.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }];
}

- (void) checkEngage {
    PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
    [query includeKey:@"postID"];
    [query includeKey:@"userID"];
    [query orderByDescending:(@"createdAt")];
    [query whereKey:@"postID" equalTo: self.obj.objectId];
    [query whereKey:@"userID" equalTo: User.currentUser.objectId];
    [query whereKey:@"isEngage" equalTo: [NSNumber numberWithBool:YES]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable engage, NSError * _Nullable error) {
        if (engage == nil) {
            [Liked favorite:self.obj.objectId withUser:User.currentUser.objectId withDef:YES withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(error){
                    NSLog(@"Error boolean liking: %@", error.localizedDescription);
                } else {
                    NSLog(@"Successfully updated boolean like count: %@", self.obj.likeCount);
                }
            }];
        }
    }];
}

- (void) refreshUser {
    // refresh necessary due to loss of data in segue
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"likeCount"];
    [query includeKey:@"commentCount"];
    [query orderByDescending:(@"createdAt")];
    [query whereKey:@"objectId" equalTo:self.obj.objectId];
    
    query.limit = 1;
    
    NSArray *res = [query findObjects];
    self.obj = res[0];
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
    self.likeCount.textColor = self.frontColor;
    self.name.textColor = self.frontColor;
    self.username.textColor = self.frontColor;
    self.caption.textColor = self.frontColor;
    self.date.textColor = self.frontColor;
    self.segCon.backgroundColor = self.customColor;
    self.segCon.tintColor = self.frontColor;
    self.tabBarController.tabBar.tintColor = self.customColorDarker;
    self.tabBarController.tabBar.unselectedItemTintColor = self.customColor;
    self.tabBarController.tabBar.backgroundColor = self.backColor;
    self.navigationController.navigationBar.backgroundColor = self.backColor;

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:self.frontColor}];
    [self.tableView reloadData];
}

#pragma mark - Animations

- (void) animateLike {
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.heartPopup.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.heartPopup.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.heartPopup.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.heartPopup.transform = CGAffineTransformMakeScale(1.3, 1.3);
                self.heartPopup.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.heartPopup.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }];
}

- (void) doubleTapped:(UITapGestureRecognizer *)sender{
    [self triggerLike];
}

- (void) setTapGestures {
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.postImage addGestureRecognizer:doubleTapGestureRecognizer];
    [self.postImage setUserInteractionEnabled:YES];
}

#pragma mark - Actions

- (IBAction)didLike:(id)sender {
    [self triggerLike];
}

- (IBAction)viewVideo:(id)sender {
    NSURL *url = [NSURL URLWithString: self.obj.speedpaint.url];
    self.player = [AVPlayer playerWithURL:url];
    self.playerController.player = self.player;
    self.playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    [self presentViewController:self.playerController animated:YES completion:^{
        [self.playerController.player play];
    }];
}

- (IBAction)didComment:(id)sender {
    BOOL temp = YES;
    NSNumber *typeTemp = @(0);
    NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
    if([title isEqualToString:@"Comments"]){
        temp = NO;
    } else {
        temp = YES;
        typeTemp = @(1);
    }
    
    if(![self.commentField.text isEqualToString:@""]){
        [Comment postComment:self.obj.objectId withUser:User.currentUser withText:self.commentField.text withMarkUp:self.markUp withMarkBool: self.didMarkUp withBool:temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
            } else {
                [self fetchComments];
                 
                int temp = [self.obj.commentCount intValue];
                self.obj.commentCount = [NSNumber numberWithInt:temp + 1];
                [Post comment:self.obj withValue:self.obj.commentCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error){
                        NSLog(@"Error posting: %@", error.localizedDescription);
                    }
                }];
                 
                [Notifications notif:self.obj withAuthor:self.obj.author withType:typeTemp withText:self.commentField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error){
                        NSLog(@"Error posting: %@", error.localizedDescription);
                    }
                }];
                self.commentField.text = @"";
                self.markUp = nil;
                self.didMarkUp = NO;
                self.markUpButton.tintColor = UIColor.systemBlueColor;
            }
        }];
    }
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self performSegueWithIdentifier:@"profileSegue" sender:self.obj.author];
}

// handles visually unliking a post
- (void) visUnlike {
    self.heartPopup.image = [UIImage systemImageNamed:@"heart.slash"];
    [self animateLike];

    self.liked = NO;
    int temp = [self.obj.likeCount intValue];
    self.obj.likeCount = [NSNumber numberWithInt:temp - 1];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
}

// handles visually liking a post
- (void) visLike {
    self.heartPopup.image = [UIImage systemImageNamed:@"heart.fill"];
    [self animateLike];

    self.liked = YES;
    int temp = [self.obj.likeCount intValue];
    self.obj.likeCount = [NSNumber numberWithInt:temp + 1];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    
}

// updates backend for unliking
- (void) dataUnlike {
    [Post favorite:self.obj withValue:self.obj.likeCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error posting like: %@", error.localizedDescription);
         } else {
             NSLog(@"Successfully updated post like count: %@", self.obj.likeCount);
         }
    }];
    
    // unlike like table
    PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
    [query includeKey:@"postID"];
    [query includeKey:@"userID"];
    [query orderByDescending:(@"createdAt")];
    [query whereKey:@"postID" equalTo: self.obj.objectId];
    [query whereKey:@"userID" equalTo: User.currentUser.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable like, NSError * _Nullable error) {
        if (like != nil) {
            [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"succeeded in deleting like boolean obj");
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) dataLike {
    [Post favorite:self.obj withValue:self.obj.likeCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error posting: %@", error.localizedDescription);
         } else {
             NSLog(@"Successfully updated like count: %@", self.obj.likeCount);
         }
    }];
    
    [Liked favorite:self.obj.objectId withUser:User.currentUser.objectId withDef:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error boolean liking: %@", error.localizedDescription);
        } else {
             NSLog(@"Successfully updated boolean like count: %@", self.obj.likeCount);
        }
    }];
    
    if(self.obj.author.objectId != User.currentUser.objectId){
        [Notifications notif:self.obj withAuthor:self.obj.author withType:@(2) withText:@"" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully send like notif");
             }
        }];
    }
}

- (void) triggerLike {
    if(self.liked == YES){
        [self visUnlike];
        [self dataUnlike];
    } else {
        [self visLike];
        [self dataLike];
    }
    
    // set our visual likecount
    if([self.obj.likeCount intValue] == 1){
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " like"];
    } else {
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " likes"];
    }
}

#pragma mark - Delegates

// delegate for finishing drawing for comment
- (void)drawingDidFinish:(UIImage *)finishedImage {
    self.markUp = finishedImage;
    self.didMarkUp = YES;
    self.markUpButton.tintColor = UIColor.redColor;
}

- (void) didDisplayMarkUp:(NSString *)username withImage:(PFFileObject *)image{
    PopUpViewController *ourPopController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PopUpPreviewController"];

    ourPopController.chosenImage = image;
    ourPopController.chosenUsername = username;
    
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:ourPopController];
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.containerView.backgroundColor = [UIColor clearColor];

    [popupController presentInViewController:self];
}

#pragma mark - Tableview

- (void)fetchComments {
    [self setDetails];

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query includeKey:@"postID"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"likeCount"];
    [query includeKey:@"author"];
    [query includeKey:@"critBool"];
    [query orderByDescending:(@"likeCount")];
    [query whereKey:@"postID" equalTo: self.obj.objectId];
    query.limit = 20;
    
    // check if original user allowed for crits
    if(!self.obj.critBool){
        [self.segCon removeSegmentAtIndex:1 animated:NO];
    } else {
        // crits allowed? check which is selected by segmented control
        NSString *title = [self.segCon titleForSegmentAtIndex:self.segCon.selectedSegmentIndex];
        if([title isEqualToString:@"Comments"]){
            [query whereKey:@"critBool" equalTo: [NSNumber numberWithBool:NO]];
        } else {
            [query whereKey:@"critBool" equalTo: [NSNumber numberWithBool:YES]];
        }
    }

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.commentArray = comments;
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    Comment *comment = self.commentArray[indexPath.row];
    cell.username.text = comment.author.username;
    cell.caption.text = comment.text;
    cell.comment = comment;
    cell.likeCount.text = [comment.likeCount stringValue];
    if(comment.author.profilePic != nil){
        cell.image.file = comment.author.profilePic;
        cell.image.layer.cornerRadius = cell.image.frame.size.width/2;
        cell.image.clipsToBounds = YES;
        [cell.image loadInBackground];
    }
    cell.date.text = comment.createdAt.shortTimeAgoSinceNow;
    cell.delegate = self;
    cell.backgroundColor = self.backColor;
    cell.username.textColor = self.frontColor;
    cell.caption.textColor = self.frontColor;
    cell.date.textColor = self.frontColor;
    if(comment.didMarkUp == NO){
        cell.markUpView.hidden = YES;
    }
    [self checkCommentLikes:cell];
    
    return cell;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentArray.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (([segue.identifier isEqualToString:@"profileSegue"])){
        User *temp = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.isFromTimeline = YES;
        profileViewController.currentUser = temp;
    } else if (([segue.identifier isEqualToString:@"analytics"])){
        GraphViewController *graphVC = [segue destinationViewController];

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
            
        [self.obj getPostData:tempEngageArr withLikeArr:tempLikeArr withComArr:tempComArr withCritArr:tempCritArr];

        graphVC.engageArray = tempEngageArr;
        graphVC.likeArray = tempLikeArr;
        graphVC.commentArray = tempComArr;
        graphVC.critArray = tempCritArr;
        graphVC.viewArray = self.obj.viewTrack;
    } else if (([segue.identifier isEqualToString:@"drawSegue"])){
        DrawViewController *drawVC = [segue destinationViewController];
        PFFileObject *tempObj = (PFFileObject *)self.obj.image;
        NSData *data = [tempObj getData];
        drawVC.image = [UIImage imageWithData:data];
        drawVC.delegate = self;
    } else if([segue.identifier isEqualToString:@"commentProfileSegue"]){
        CommentCell *cell = sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        Comment *currentComment = self.commentArray[path.row];
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.isFromTimeline = YES;
        profileViewController.currentUser = currentComment.author;
    }
}


@end
