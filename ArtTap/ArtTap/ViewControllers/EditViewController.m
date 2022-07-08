//
//  EditViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/22.
//

#import "EditViewController.h"
#import "User.h"

@interface EditViewController () <UITextFieldDelegate>

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.nameField.delegate = self;
    self.bioField.delegate = self;
    //self.profileImage.image = self.currentImage;
    // Do any additional setup after loading the view.
}
- (IBAction)didClickDone:(id)sender {
    if([self.usernameField.text isEqualToString:@""] && [self.nameField.text isEqualToString:@""] &&
       [self.bioField.text isEqualToString:@""] && self.profileImage.image == nil){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Fields Empty"
                                                  message:@"Please make edits"
                                                  preferredStyle:UIAlertControllerStyleAlert];

       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {}];

       [alert addAction:defaultAction];
       [self presentViewController:alert animated:YES completion:nil];
    } else {
        [User updateUser:self.profileImage.image withBackground: self.backgroundImage.image withName:self.nameField.text withUsername:self.usernameField.text withBio:self.bioField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(error){
                  NSLog(@"Error posting: %@", error.localizedDescription);
             }
             else{
                 NSLog(@"Successfully updated profile with name: %@", self.nameField.text);
                 [self.delegate didEdit];
                 [self.navigationController popViewControllerAnimated:YES];
             }
        }];
    }
}
- (IBAction)changePic:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.fromBg = NO;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)changeBackground:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.fromBg = YES;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    if(self.fromBg){
        CGFloat width = self.backgroundImage.bounds.size.width * 3;
        CGFloat height = self.backgroundImage.bounds.size.height * 3;
        CGSize newSize = CGSizeMake(width, height);
        UIImage *editedImage2 = [self resizeImage:editedImage withSize:newSize];

        self.backgroundImage.image = editedImage2;
        [self.backgroundImage loadInBackground];
    } else {
        CGFloat width = self.profileImage.bounds.size.width * 3;
        CGFloat height = self.profileImage.bounds.size.height * 3;
        CGSize newSize = CGSizeMake(width, height);
        UIImage *editedImage2 = [self resizeImage:editedImage withSize:newSize];

        self.profileImage.image = editedImage2;
        [self.profileImage loadInBackground];
    }

    // Do something with the images (based on your use case)
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
