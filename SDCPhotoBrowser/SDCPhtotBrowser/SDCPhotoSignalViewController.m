//
//  SDCPhotoSignalViewController.m
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/13.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import "SDCPhotoSignalViewController.h"
#import "SDCPhotoSignalView.h"

@interface SDCPhotoSignalViewController()<UIScrollViewDelegate>

@property(nonatomic,weak)SDCPhotoSignalView *photoView;

@end

@implementation SDCPhotoSignalViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.backgroundColor = [UIColor clearColor];
    imgV.frame = CGRectMake(0, 0, 10, 10);
    [self.view addSubview:imgV];
    
}




-(void)setPhotoItem:(SDCPhotoItem *)photoItem
{
    if (!_photoView) {
        SDCPhotoSignalView *view = [[SDCPhotoSignalView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:view];
        _photoView = view;
    }

    _photoItem = photoItem;
    _photoView.photoItem = photoItem;
}




@end
