//
//  PopUpViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 8/1/22.
//

#import "PopUpViewController.h"
#import <STPopup/STPopup.h>
@import Parse;

@interface PopUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet PFImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *viewCount;
@property (weak, nonatomic) IBOutlet UILabel *commentCount;
@property (strong, nonatomic) NSString *chosenUsername;
@end

@implementation PopUpViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.username.text = [@"@" stringByAppendingString:self.currentPost.author.username];
    self.image.file = self.currentPost.image;
    
    if([self.currentPost.likeCount intValue] == 1){
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.likeCount stringValue], " like"];
    } else {
        self.likeCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.likeCount stringValue], " likes"];
    }
    
    if([self.currentPost.numViews intValue] == 1){
        self.viewCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.numViews stringValue], " view"];
    } else {
        self.viewCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.numViews stringValue], " views"];
    }
    
    if([self.currentPost.commentCount intValue] == 1){
        self.commentCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.commentCount stringValue], " comment"];
    } else {
        self.commentCount.text = [NSString stringWithFormat:@"%@%s", [self.currentPost.commentCount stringValue], " comments"];
    }

    CGFloat margin = 10;
    PFFileObject *temp = self.currentPost[@"image"];
    NSData *data = [temp getData];
    UIImage *tempImage = [UIImage imageWithData:data];
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.width - margin * 2);
    NSLog(@"%f", self.image.frame.size.width);
    NSLog(@"%f", tempImage.size.width);
    NSLog(@"%f", tempImage.size.height);
    NSLog(@"%f", ([UIScreen mainScreen].bounds.size.width - margin * 2)/tempImage.size.width*tempImage.size.height + 100);
    
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - margin * 2,
                                         ([UIScreen mainScreen].bounds.size.width - margin * 2)/tempImage.size.width*tempImage.size.height);
    self.view.layer.cornerRadius = 20;
    self.view.alpha = 0.9;
    self.popupController.navigationBarHidden = YES;
}

- (IBAction)closeButtonDidTap
{
    [self.popupController dismiss];
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
