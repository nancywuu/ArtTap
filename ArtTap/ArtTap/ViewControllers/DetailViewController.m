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

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (nonatomic, strong) NSArray *commentArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    [self fetchComments];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    //TODO: Call method delegate
    NSLog(@"TAPPED user profile");
    //[self.delegate homeTableCell:self didTap:self.post.author];
    [self performSegueWithIdentifier:@"profileSegue" sender:self.obj.author];
}

- (void) visUnlike {
    self.liked = NO;
    int temp = [self.obj.likeCount intValue];
    self.obj.likeCount = [NSNumber numberWithInt:temp - 1];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
    
    // account for plural
    if([self.obj.likeCount intValue] == 1){
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " like"];
    } else {
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " likes"];
    }
    
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
            NSLog(@"found a like obj, trying to delete");
            [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"succeeded in deleting like boolean obj");
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"none found or error");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) visLike {
    self.liked = YES;
    int temp = [self.obj.likeCount intValue];
    self.obj.likeCount = [NSNumber numberWithInt:temp + 1];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    
    // account for plural
    if([self.obj.likeCount intValue] == 1){
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " like"];
    } else {
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.obj.likeCount stringValue], " likes"];
    }
    
    [Post favorite:self.obj withValue:self.obj.likeCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error posting: %@", error.localizedDescription);
         } else {
             NSLog(@"Successfully updated like count: %@", self.obj.likeCount);
         }
    }];
    
    [Liked favorite:self.obj.objectId withUser:User.currentUser.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error boolean liking: %@", error.localizedDescription);
        } else {
             NSLog(@"Successfully updated boolean like count: %@", self.obj.likeCount);
        }
    }];
    
}

- (IBAction)didLike:(id)sender {
    if(self.liked == YES){
        // update likeCount
        [self visUnlike];
        
    } else {
        [self visLike];
    }
}

- (IBAction)didComment:(id)sender {
    if(![self.commentField.text isEqualToString:@""]){
        [Comment postComment:self.obj.objectId withUser:User.currentUser withText:self.commentField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully commented on post: %@", self.commentField.text);
                 [self fetchComments];
                 
                 int temp = [self.obj.commentCount intValue];
                 self.obj.commentCount = [NSNumber numberWithInt:temp + 1];
                 self.commentField.text = @"";
                 [Post comment:self.obj withValue:self.obj.commentCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                     if(error){
                           NSLog(@"Error posting: %@", error.localizedDescription);
                      }
                      else{
                          NSLog(@"Successfully updated comment count: %@", self.obj.commentCount);
                      }
                 }];
             }
        }];
    }
}

- (void)setDetails {
    self.username.text = self.obj.author.username;

    PFUser *temp = self.obj[@"author"];
    self.username.text = [@"@" stringByAppendingString:temp[@"username"]];

    self.name.text = self.obj.author.name;
    self.date.text = self.obj.createdAt.shortTimeAgoSinceNow;
    self.postImage.file = self.obj.image;
    self.profileImage.file = self.obj.author.profilePic;
    self.caption.text = self.obj.caption;
    
    // account for plural
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
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable like, NSError * _Nullable error) {
        if (like != nil) {
            NSLog(@"found a like obj in setup");
            self.liked = YES;
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        } else {
            NSLog(@"did not find a like obj in setup");
            self.liked = NO;
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }];
}

- (void)fetchComments {
    [self setDetails];

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query includeKey:@"postID"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"author"];
    [query orderByDescending:(@"createdAt")];
    [query whereKey:@"postID" equalTo: self.obj.objectId];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.commentArray = comments;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    NSLog(@"comment found");
    Comment *comment = self.commentArray[indexPath.row];
    cell.username.text = comment.author.username;
    cell.caption.text = comment.text;
    if(comment.author.profilePic != nil){
        cell.image.file = comment.author.profilePic;
        cell.image.layer.cornerRadius = cell.image.frame.size.width/2;
        cell.image.clipsToBounds = YES;
        [cell.image loadInBackground];
    }
    cell.date.text = comment.createdAt.shortTimeAgoSinceNow;
    
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (([segue.identifier isEqualToString:@"profileSegue"])){
        User *temp = sender;
        ProfileViewController *profileViewController = [segue destinationViewController];
        profileViewController.isFromTimeline = YES;
        profileViewController.currentUser = temp;
    }
}


@end
