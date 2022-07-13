//
//  AnalyticsViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/12/22.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.views.text = [NSString stringWithFormat: @"%@%s", self.post.numViews, " views" ];
    self.likes.text = [NSString stringWithFormat: @"%@%s", self.post.likeCount, " likes" ];
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
