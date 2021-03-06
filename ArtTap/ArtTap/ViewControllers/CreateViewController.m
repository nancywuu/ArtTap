//
//  ComposeViewController.m
//  Instagram
//
//  Created by Nancy Wu on 6/27/22.
//

#import "CreateViewController.h"
#import "Post.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface CreateViewController () <UITextViewDelegate>
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *chosenImage;

@end

@implementation CreateViewController
- (IBAction)didShare:(id)sender {
    if(self.displayImage != nil){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if([self.captionField.text isEqualToString: @"Add a caption..."]) {
            self.caption = @"";
        } else {
            self.caption = self.captionField.text;
        }
        [Post postUserImage:self.chosenImage withCaption:self.caption withBool:self.critSwitch.isOn withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 [self.delegate didPost];
                 NSLog(@"Successfully posted with caption: %@", self.caption);
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self dismissViewControllerAnimated:true completion:nil];
             }
        } ];
    }
    
}
- (IBAction)didClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)didTapCamera:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera ???? available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}
- (IBAction)didTapAlbum:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = NO;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionField.text = @"Add a caption...";
    self.captionField.textColor = [UIColor lightGrayColor];
    self.captionField.delegate = self;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if([textView.text isEqualToString: @"Add a caption..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    if(editedImage != nil){
        CGFloat width = 500;
        CGFloat height = 500 * originalImage.size.height/originalImage.size.width;
        CGSize newSize = CGSizeMake(width, height);
        UIImage *editedImage2 = [self resizeImage:editedImage withSize:newSize];
    
        self.chosenImage = editedImage2;
        [self.displayImage setImage:editedImage2];
    } else {
        
        CGFloat width = 500;
        CGFloat height = 500 * originalImage.size.height/originalImage.size.width;
        CGSize newSize = CGSizeMake(width, height);
        UIImage *originalImage2 = [self resizeImage:originalImage withSize:newSize];
        
        self.chosenImage = originalImage2;
        [self.displayImage setImage:originalImage2];
    }

    // Do something with the images (based on your use case)
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
