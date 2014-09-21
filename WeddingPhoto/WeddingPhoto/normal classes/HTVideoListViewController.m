//
//  HTVideoListViewController.m
//  WeddingPhoto
//
//  Created by Jason on 2014/9/12.
//  Copyright (c) 2014年 HappyMan. All rights reserved.
//

#import "HTVideoListViewController.h"
#import "HTVideoCell.h"
#import "UIImageView+AFNetworking.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface HTVideoListViewController ()

@end

@implementation HTVideoListViewController

- (id)initWithEventArr:(NSArray *)array
{
    self = [super initWithNibName:@"HTVideoListViewController" bundle:nil];
    if (self) {
        videoArr = array;
        
        videoArr = @[@"0BUphSdjPEw", @"uAfVxhUCDis", @"4oPw63oVqpA", @"-8fHZj2PjI0", @"JmKTfcRz0FY"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTVideoCell *cell = [HTVideoCell cell];
    
    NSURL *youtubeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", videoArr[indexPath.row]]];
    
    [cell.thumbnailImageView setImageWithURL:youtubeURL];

    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoArr[indexPath.row]];
    videoPlayerViewController.delegate = self;
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

#pragma mark - Button Methods

-(IBAction)backButtonClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)youTubeStarted:(NSNotification *)notification
{
    HTAppDelegate *appDelegate = (HTAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenVideoIsPlaying = YES;
}
-(void)youTubeFinished:(NSNotification *)notification
{
    HTAppDelegate *appDelegate = (HTAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.fullScreenVideoIsPlaying = NO;
}
@end
