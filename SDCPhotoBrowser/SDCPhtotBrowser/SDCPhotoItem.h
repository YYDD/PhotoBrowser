//
//  SDCPhotoItem.h
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/14.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SDCPhotoItem : NSObject


+(instancetype)createdPhotoItem:(NSString *)urlStr WithThumb:(NSString *)thumbUrlStr;

@property(nonatomic,strong)NSString *urlStr;
@property(nonatomic,strong)NSString *thumbUrlStr;
@property(nonatomic,strong)NSString *titleStr;

@property(nonatomic,strong)UIImage *thumbImage;
@property(nonatomic,strong)UIImage *originalImage;

@property(nonatomic,assign)BOOL deleteAble;

@end
