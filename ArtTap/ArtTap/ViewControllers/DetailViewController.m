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

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CommentCellDelegate>
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (nonatomic, strong) NSArray *commentArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DetailViewController
- (IBAction)segChanged:(id)sender {
    [self fetchComments];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self refreshUser];
    [self checkEngage];
    // update post views
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
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
    
    [self fetchComments];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self performSegueWithIdentifier:@"profileSegue" sender:self.obj.author];
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

    // fetch data asynchronously
    self.obj = res[0];
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
    
    [Liked favorite:self.obj.objectId withUser:User.currentUser.objectId withDef:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
        [Comment postComment:self.obj.objectId withUser:User.currentUser withText:self.commentField.text withBool:temp withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully commented on post: %@", self.commentField.text);
                 [self fetchComments];
                 
                 int temp = [self.obj.commentCount intValue];
                 self.obj.commentCount = [NSNumber numberWithInt:temp + 1];
                 [Post comment:self.obj withValue:self.obj.commentCount withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                     if(error){
                           NSLog(@"Error posting: %@", error.localizedDescription);
                      }
                      else{
                          NSLog(@"Successfully updated comment count: %@", self.obj.commentCount);
                      }
                 }];
                 
                 [Notifications notif:self.obj withAuthor:self.obj.author withType:typeTemp withText:self.commentField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                     if(error){
                           NSLog(@"Error posting: %@", error.localizedDescription);
                      }
                      else{
                          NSLog(@"Successfully updated comment count: %@", self.obj.commentCount);
                      }
                 }];
                 self.commentField.text = @"";
             }
        }];
    }
}

- (void)didLikeComment{
    //[self fetchComments];
}

- (void)setDetails {
    // FIX: temporarily commented out due to unsolved bug
    self.username.text = self.obj.author.username;

    User *temp = self.obj.author;
    self.username.text = [@"@" stringByAppendingString:temp.username];

    self.name.text = self.obj.author.name;

    
    self.date.text = self.obj.createdAt.shortTimeAgoSinceNow;
    self.postImage.file = self.obj.image;
    self.profileImage.file = self.obj.author.profilePic;
    [self.profileImage loadInBackground];
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
    [self checkCommentLikes:cell];
    
    
    return cell;
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentArray.count;
}

// methods for arranging dates for post analysis

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([date compare:endDate] == NSOrderedDescending)
        return NO;

    return YES;
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
    } else if (([segue.identifier isEqualToString:@"analytics"])){
        GraphViewController *graphVC = [segue destinationViewController];
        graphVC.post = self.obj;
    
        PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
        [query includeKey:@"postID"];
        [query includeKey:@"userID"];
        [query includeKey:@"isEngage"];
        [query includeKey:@"createdAt"];
        [query whereKey:@"postID" equalTo: self.obj.objectId];

        NSArray *tempRes = [query findObjects];
        
        PFQuery *comquery = [PFQuery queryWithClassName:@"Comment"];
        [comquery includeKey:@"postID"];
        [comquery includeKey:@"createdAt"];
        [comquery whereKey:@"postID" equalTo: self.obj.objectId];

        NSArray *comRes = [comquery findObjects];
        
        // week: 168
        // month: 730
        
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
            
        for(int i = 0; i < tempRes.count; i++){
            Liked *temp = tempRes[i];
            NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];
    
            if(hours < 730){
                // TODO: CUMULATIVE:
//                if(temp.isEngage){
//                    for(int j = 0; j < hours; j++){
//                        tempEngageArr[j] = [NSNumber numberWithInteger:[tempEngageArr[j] integerValue] + 1];
//                    }
//                } else {
//                    for(int j = 0; j < hours; j++){
//                        tempLikeArr[j] = [NSNumber numberWithInteger:[tempLikeArr[j] integerValue] + 1];
//                    }
//                }
                
                // TODO: NON-CUMULATIVE:
                if(temp.isEngage){
                    tempEngageArr[hours] = [NSNumber numberWithInteger:[tempEngageArr[hours] integerValue] + 1];
                } else {
                    tempLikeArr[hours] = [NSNumber numberWithInteger:[tempLikeArr[hours] integerValue] + 1];
                }

            }
        }
        
        for(int i = 0; i < comRes.count; i++){
            Comment *temp = comRes[i];
            NSInteger hours = [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:temp.createdAt toDate:[NSDate date] options:0] hour];
    
            if(hours < 730){
                // TODO: CUMULATIVE:
//                for(int j = 0; j < hours; j++){
//                    tempComArr[j] = [NSNumber numberWithInteger:[tempComArr[j] integerValue] + 1];
//                }
                
                // TODO: NON-CUMULATIVE:
                if(temp.critBool){
                    tempCritArr[hours] = [NSNumber numberWithInteger:[tempCritArr[hours] integerValue] + 1];
                } else {
                    tempComArr[hours] = [NSNumber numberWithInteger:[tempComArr[hours] integerValue] + 1];
                }
            }
        }

        graphVC.engageArray = tempEngageArr;
        graphVC.likeArray = tempLikeArr;
        graphVC.commentArray = tempComArr;
        graphVC.critArray = tempCritArr;
        graphVC.viewArray = self.obj.viewTrack;
    }
}


@end
