//
//  ComposeViewController.m
//  Instagram
//
//  Created by Nancy Wu on 6/27/22.
//

#import "CreateViewController.h"
#import "Post.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <AVFoundation/AVFoundation.h>

@interface CreateViewController () <UITextViewDelegate>
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *chosenImage;
@property (nonatomic, strong) NSData *chosenFromURL;
@property (weak, nonatomic) IBOutlet UILabel *critText;

@property BOOL didUploadImage;

@end

@implementation CreateViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionField.text = @"Add a caption...";
    self.captionField.textColor = [UIColor lightGrayColor];
    self.captionField.delegate = self;
    self.didUploadImage = NO;
}

- (void) viewWillAppear:(BOOL)animated {
    if(User.currentUser.darkmode){
        self.view.backgroundColor = UIColor.blackColor;
        self.critText.textColor = UIColor.whiteColor;
    } else {
        self.view.backgroundColor = UIColor.whiteColor;
        self.critText.textColor = UIColor.blackColor;
    }
}

#pragma mark - Actions

- (IBAction)didShare:(id)sender {
    if(self.didUploadImage){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if([self.captionField.text isEqualToString: @"Add a caption..."]) {
            self.caption = @"";
        } else {
            self.caption = self.captionField.text;
        }
        [Post postUserImage:self.chosenImage withVideo:self.chosenFromURL withCaption:self.caption withBool:self.critSwitch.isOn withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Image Needed"
                                                  message:@"Please upload an image with your post"
                                                  preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)didClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapVideo:(id)sender {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self; // ensure you set the delegate so when a video is chosen the right method can be called

    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    // This code ensures only videos are shown to the end user
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];

    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:videoPicker animated:YES completion:nil];
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
        NSLog(@"Camera 🚫 available so we will use photo library instead");
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

#pragma mark - Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if([textView.text isEqualToString: @"Add a caption..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType,
                                    kUTTypeMovie) != 0;
    
    if(isMovie){
        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        NSURL *ourURL = info[UIImagePickerControllerMediaURL];

        self.chosenFromURL = [NSData dataWithContentsOfURL:ourURL];
        AVAsset *asset = [AVAsset assetWithURL:ourURL];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        CMTime time = CMTimeMake(1, 1);
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        [self.displayVideo setImage:[UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight]];
        CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    } else {
        // Get the image captured by the UIImagePickerController
        self.didUploadImage = YES;
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        CGFloat width = 500;
        CGFloat height = 500 * originalImage.size.height/originalImage.size.width;
        CGSize newSize = CGSizeMake(width, height);
        UIImage *originalImage2 = [self resizeImage:originalImage withSize:newSize];
        
        self.chosenImage = originalImage2;
        [self.displayImage setImage:originalImage2];
    }
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
