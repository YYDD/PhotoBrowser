//
//  SDCPhotoSignalView.h
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/14.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SDCPhotoItem;

@interface SDCPhotoSignalView : UIView

-(instancetype)initWithFrame:(CGRect)frame;

@property(nonatomic,strong)SDCPhotoItem *photoItem;


@end
