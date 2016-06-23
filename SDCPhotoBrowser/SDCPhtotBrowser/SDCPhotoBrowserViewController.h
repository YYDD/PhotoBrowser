//
//  SDCPhotoBrowserViewController.h
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/13.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDCPhotoItem;

typedef void (^PhotoEditBlock)(NSInteger deleteIndex);

@interface SDCPhotoBrowserViewController : UIViewController

@property(nonatomic,strong)NSArray <SDCPhotoItem *> *photoItems;
@property(nonatomic,assign)NSInteger curIndex;
@property(nonatomic,assign)BOOL canEdit;



+(instancetype)createdBrowserWithPhotoItems:(NSArray <SDCPhotoItem *>*)photoItems;

-(void)show;

@property(nonatomic,copy)PhotoEditBlock photoEditBlock;


@end
