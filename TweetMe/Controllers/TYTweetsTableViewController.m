//
// Copyright (c) 2016 - Present, RFTP Technologies Ltd.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "TYTweetsTableViewController.h"
#import <Rooftop/Rooftop.h>
#import <MRProgress/MRProgress.h>
#import "TweetModel.h"

@interface TYTweetsTableViewController ()

@property (strong, nonatomic) NSArray<TweetModel*> *tweets;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *composeButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutButtonItem;
@property (assign, nonatomic) BOOL loadingFromLocal;
@property (assign, nonatomic) BOOL loadingFromServer;

@end

@implementation TYTweetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
    [self refreshTableFromServer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUIState];
    [self refreshTableFromLocalStore];
}

- (void)updateUIState {
    if ([RTUser currentUser]) {
        self.navigationItem.leftBarButtonItem = self.logoutButtonItem;
        self.navigationItem.rightBarButtonItem = self.composeButtonItem;
    }
    else {
        self.navigationItem.leftBarButtonItem = self.loginButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)refreshTableFromLocalStore {
    if (self.loadingFromLocal) {
        return;
    }
    self.loadingFromLocal = YES;
    TweetModel *tweet = [self.tweets firstObject];
    NSDate *createdAt = tweet.createdAt;
    RTQuery *query = [TweetModel query];
    [query fromLocalDatastore];
    [query includeKey:@"owner"];
    [query orderByDescending:@"createdAt"];
    if (createdAt) {
        [query whereKey:@"createdAt" greaterThan:createdAt];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *tweets, NSError *error) {
        if (!error) {
            if (!self.tweets) {
                self.tweets = tweets;
            }
            else {
                self.tweets = [tweets arrayByAddingObjectsFromArray:self.tweets];
            }
            [self.tableView reloadData];
            self.loadingFromLocal = NO;
        }
    }];
}

- (void)refreshTableFromServer {
    if (self.loadingFromServer) {
        return;
    }
    self.loadingFromServer = YES;
    RTQuery *query = [TweetModel query];
    query.limit = 10;
    [query includeKey:@"owner"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *tweets, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error) {
            [RTObject unpinAllInBackground:self.tweets block:^(BOOL succeeded, NSError * _Nullable error) {
                [RTObject pinAllInBackground:tweets block:^(BOOL succeeded, NSError * _Nullable error) {
                    self.tweets = tweets;
                    [self.tableView reloadData];
                    self.loadingFromServer = NO;
                }];
            }];
        }
    }];
}

- (void)refreshTable {
    if (!self.loadingFromServer) {
        [self refreshTableFromServer];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([self.tweets count]) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
    else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        messageLabel.text = @"There are no tweets...\n\nLogin and post the first tweet\nor pull to refresh";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TYTweetTableCellView"];
    NSInteger row = indexPath.row;
    TweetModel *tweet = [self.tweets objectAtIndex:row];
    cell.textLabel.text = tweet.text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Posted by %@ on %@", tweet.owner.username, tweet.createdAt];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    [RTCloud callFunctionInBackground:@"message" withParameters:nil block:^(id  _Nullable object, NSError * _Nullable error) {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        if (object) {
            [self showAlertViewWithText:object title:@"Rooftop"];
        } else {
            [self showAlertViewWithText:@"Could not call function" title:@"Error"];
        }
    }];
}

- (IBAction)logoutButtonPressed:(id)sender {
    [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    [RTUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        RTInstallation *currentInstallation = [RTInstallation currentInstallation];
        [currentInstallation removeObjectForKey:@"user"];
        [currentInstallation saveInBackground];
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
        [self updateUIState];
    }];
}
@end
