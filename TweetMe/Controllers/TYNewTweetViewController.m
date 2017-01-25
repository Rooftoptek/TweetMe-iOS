//
// Copyright (c) 2016 - Present, RFTP Technologies Ltd.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "TYNewTweetViewController.h"
#import <MRProgress/MRProgress.h>
#import <Rooftop/Rooftop.h>
#import "TweetModel.h"

@interface TYNewTweetViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewToBottomLayoutGuide;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

@end


@implementation TYNewTweetViewController

- (void)showAlertViewWithText:(NSString *)alertText title:(NSString *)alertTitle {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertTitle
                                          message:alertText
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleKeyboardWillShow:(NSNotification *)notification {
    NSValue *keyboardRectAsObject =
    [[notification userInfo]
     objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = CGRectZero;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.textViewToBottomLayoutGuide.constant = keyboardRect.size.height;
}

- (void) handleKeyboardWillHide:(NSNotification *)notification{
    self.textViewToBottomLayoutGuide.constant = 0;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.textView resignFirstResponder];
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    RTACL *acl = [RTACL ACL];
    [acl setPermission: PublicRead];
    TweetModel *tweet = [TweetModel object];
    tweet.ACL = acl;
    tweet.text = self.textView.text;
    tweet.owner = [RTUser currentUser];
    [tweet saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            [self showAlertViewWithText:errorString title:@"Error"];
        } else {
            [tweet pinInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    }];
}

@end
