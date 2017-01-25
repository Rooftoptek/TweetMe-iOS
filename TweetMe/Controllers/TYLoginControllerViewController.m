//
// Copyright (c) 2016 - Present, RFTP Technologies Ltd.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "TYLoginControllerViewController.h"
#import <MRProgress/MRProgress.h>
#import <Rooftop/Rooftop.h>
#import <RooftopFacebookUtils/RooftopFacebookUtils.h>

@interface TYLoginControllerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (assign, nonatomic) BOOL wantSignup;
@property (weak, nonatomic) IBOutlet UIButton *wantSignupButton;

@end

@implementation TYLoginControllerViewController

- (void)updateUIState {
    if (self.wantSignup) {
        self.wantSignup = NO;
        self.loginButton.hidden = YES;
        self.signupButton.hidden = NO;
        [self.wantSignupButton
         setTitle:@"I already have an account"
         forState:UIControlStateNormal];
    }
    else {
        self.wantSignup = YES;
        self.loginButton.hidden = NO;
        self.signupButton.hidden = YES;
        [self.wantSignupButton
         setTitle:@"I don't have an account"
         forState:UIControlStateNormal];
    }
}

- (void)showAlertViewWithText:(NSString *)alertText title:(NSString *)alertTitle {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertTitle
                                          message:alertText
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)signUpOrLoginCompleted:(RTUser *)user {
    RTInstallation *currentInstallation = [RTInstallation currentInstallation];
    [currentInstallation setObject:user forKey:@"user"];
    [currentInstallation saveInBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wantSignup = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUIState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapGestureRecogniser:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)wantSignupButtonPressed:(id)sender {
    [self updateUIState];
}

- (IBAction)loginWithFacebookPressed:(id)sender {
    NSArray *permissions = @[@"public_profile"];
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    [RTFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(RTUser *user, NSError *error) {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            [self showAlertViewWithText:errorString title:@"Error"];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    [RTUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(RTUser *user, NSError *error) {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            [self showAlertViewWithText:errorString title:@"Error"];
        }
        else {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
}

- (IBAction)signupButtonPressed:(id)sender {
    RTUser *user = [RTUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            [self showAlertViewWithText:errorString title:@"Error"];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }];
}

@end
