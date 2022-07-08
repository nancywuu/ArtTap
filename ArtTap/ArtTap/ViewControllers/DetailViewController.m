//
//  DetailViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/7/22.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.username.text = self.obj.author.username;
    self.postImage.file = self.obj.image;
    self.profileImage.file = self.obj.author.profilePic;
    self.caption.text = self.obj.caption;
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
