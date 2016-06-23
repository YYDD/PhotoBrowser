//
//  ViewController.m
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/13.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import "ViewController.h"
#import "SDCPhotoBrowserViewController.h"
#import "SDCPhotoItem.h"

#import "UIImageView+WebCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    [self initUI];
    
}

-(void)initUI
{
    UIView *boxView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [self.view addSubview:boxView];

    NSString *urlStr1 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF0839.JPG?imageView2/2/w/200/q/50";
    NSString *urlStr2 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1511.JPG?imageView2/2/w/200/q/50";
    NSString *urlStr3 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1524.JPG?imageView2/2/w/200/q/50";
    NSString *urlStr4 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogtestPic.jpg?imageView2/2/w/200/q/50";

    NSArray *imgUrlArr = @[urlStr1,urlStr2,urlStr3,urlStr4];
    for (int i = 0; i < imgUrlArr.count; i ++) {
        static CGFloat itemW = 100;
        static CGFloat itemH = 80;
        
        UIImageView *imgV = [[UIImageView alloc]init];
        imgV.backgroundColor  =[UIColor clearColor];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        [imgV.layer setMasksToBounds:YES];
        [boxView addSubview:imgV];
        
        CGFloat hPadding = (boxView.frame.size.width - 2*itemW)/3;
        CGFloat vPadding = 30;
        int row = (int)i/2;
        int column = i - row * 2;
        
        imgV.frame = CGRectMake(hPadding + column * (hPadding + itemW) , vPadding + (vPadding + itemH)*row, itemW, itemH);
        [imgV sd_setImageWithURL:[NSURL URLWithString:imgUrlArr[i]]];
        imgV.tag = i;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTap:)];
        [imgV addGestureRecognizer:tapGesture];
        [imgV setUserInteractionEnabled:YES];
    }
}


-(void)imgTap:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    NSInteger index = view.tag;
    
    NSString *thumbUrlStr1 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF0839.JPG?imageView2/2/w/200/q/50";
    NSString *thumbUrlStr2 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1511.JPG?imageView2/2/w/200/q/50";
    NSString *thumbUrlStr3 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1524.JPG?imageView2/2/w/200/q/50";
    NSString *thumbUrlStr4 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogtestPic.jpg?imageView2/2/w/200/q/50";

    
    NSString *urlStr1 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF0839.JPG";
    NSString *urlStr2 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1511.JPG";
    NSString *urlStr3 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogDSCF1524.JPG";
    NSString *urlStr4 = @"http://7xrcp9.com1.z0.glb.clouddn.com/blogtestPic.jpg";

    SDCPhotoItem *item1 = [SDCPhotoItem createdPhotoItem:urlStr1 WithThumb:thumbUrlStr1];
    SDCPhotoItem *item2 = [SDCPhotoItem createdPhotoItem:urlStr2 WithThumb:thumbUrlStr2];
    SDCPhotoItem *item3 = [SDCPhotoItem createdPhotoItem:urlStr3 WithThumb:thumbUrlStr3];
    SDCPhotoItem *item4 = [SDCPhotoItem createdPhotoItem:urlStr4 WithThumb:thumbUrlStr4];
    

    SDCPhotoBrowserViewController *vc = [[SDCPhotoBrowserViewController alloc]init];
    vc.photoItems = @[item1,item2,item3,item4];
    vc.curIndex = index;
    [vc show];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
