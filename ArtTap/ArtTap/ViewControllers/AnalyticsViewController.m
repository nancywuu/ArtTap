//
//  AnalyticsViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()
@property (nonatomic, strong) NSArray *engageArray;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.views.text = [NSString stringWithFormat: @"%@%s", self.post.numViews, " views" ];
    self.likes.text = [NSString stringWithFormat: @"%@%s", self.post.likeCount, " likes" ];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Liked"];
    [query includeKey:@"postID"];
    [query includeKey:@"userID"];
    [query includeKey:@"isEngage"];
    [query whereKey:@"postID" equalTo: self.post.objectId];
    [query whereKey:@"isEngage" equalTo: [NSNumber numberWithBool:YES]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *res, NSError *error) {
        if (res != nil) {
            self.engageArray = res;
            self.engaged.text = [NSString stringWithFormat: @"%lu%s", self.engageArray.count, " users engaged" ];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)fetchData {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
