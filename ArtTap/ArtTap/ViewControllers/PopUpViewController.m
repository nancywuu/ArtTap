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
@end

@implementation PopUpViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.username.text = [@"@" stringByAppendingString:self.chosenUsername];
    self.image.file = self.chosenImage;
    [self.image loadInBackground];

    CGFloat margin = 10;
    PFFileObject *temp = self.chosenImage;
    NSData *data = [temp getData];
    UIImage *tempImage = [UIImage imageWithData:data];

    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - margin * 2,
                                         ([UIScreen mainScreen].bounds.size.width - margin * 2)/tempImage.size.width*tempImage.size.height + 150);
    self.view.layer.cornerRadius = 20;
    self.view.alpha = 0.85;
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
