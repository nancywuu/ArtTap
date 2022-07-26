//
//  LoginViewController.m
//  ArtTap
//
//  Created by Nancy Wu on 7/6/2022.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "User.h"
@import GoogleSignIn;
@import FirebaseAuth;
@import FirebaseCore;
@import FBSDKLoginKit;
@import FBSDKCoreKit;
@import FBSDKShareKit;

@interface LoginViewController ()
@property (nonatomic, strong) UIAlertController *alert;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didLogin:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        [self presentViewController:self.alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    } else {
        [self loginUser];
    }
}
- (IBAction)didSignUp:(id)sender {
    if([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        [self presentViewController:self.alert animated:YES completion:^{
        }];
    } else {
        [self registerUser];
    }
}
- (IBAction)googleLogin:(id)sender {
    GIDConfiguration *config = [[GIDConfiguration alloc] initWithClientID:[FIRApp defaultApp].options.clientID];

    __weak __auto_type weakSelf = self;
    [GIDSignIn.sharedInstance signInWithConfiguration:config presentingViewController:self callback:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
        __auto_type strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        if (error == nil) {
            GIDAuthentication *authentication = user.authentication;
            FIRAuthCredential *credential =
            [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                             accessToken:authentication.accessToken];
            
            [[FIRAuth auth] signInWithCredential:credential
                                        completion:^(FIRAuthDataResult * _Nullable authResult,
                                                     NSError * _Nullable error) {

                if (error) {
                    NSLog(@"firebase auth error: %@", error.localizedDescription);
                    return;
                }
                // User successfully signed in. Get user data from the FIRUser object
                if (authResult == nil) {
                    return;
                }

                FIRUser *user = authResult.user;
                
                User *tempUser = [User user];
                tempUser.username = user.uid;
                tempUser.name = user.displayName;
                tempUser.password = @"temporary";
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:user.photoURL]];
                NSData *imageData = UIImagePNGRepresentation(image);
                // get image data and check if that is not nil
                
                tempUser.profilePic =  [PFFileObject fileObjectWithName:@"image.png" data:imageData];
                
                [tempUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (error != nil) {
                        NSLog(@"Error: %@", error.localizedDescription);
                        [PFUser logInWithUsernameInBackground:tempUser.username password:tempUser.password block:^(PFUser * user, NSError *  error) {
                            if (error != nil) {
                                NSLog(@"User log in failed: %@", error.localizedDescription);
                                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Login"
                                                                          message:@"Please ensure your username and password are correct"
                                                                          preferredStyle:UIAlertControllerStyleAlert];

                                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];

                                [alert addAction:defaultAction];
                                [self presentViewController:alert animated:YES completion:nil];
                            } else {
                                NSLog(@"User logged in successfully");
                                [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
                                // display view controller that needs to shown after successful login
                            }
                        }];
                    } else {
                        NSLog(@"User registered successfully");
                        [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
                        // manually segue to logged in view
                    }
                }];
 
            }];
        }
    }];
}

- (void)registerUser {
    // initialize a user object
    User *newUser = [User user];
    
    newUser.username = self.usernameField.text;
    newUser.name = self.usernameField.text;
    newUser.password = self.passwordField.text;

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Username Already Exists"
                                                      message:@"Please login or signup with another username"
                                                      preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
            // manually segue to logged in view
        }
    }];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Login"
                                                      message:@"Please ensure your username and password are correct"
                                                      preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {}];

            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
            // display view controller that needs to shown after successful login
        }
    }];
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
