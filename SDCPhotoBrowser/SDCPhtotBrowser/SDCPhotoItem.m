//
//  SDCPhotoItem.m
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/14.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import "SDCPhotoItem.h"

@implementation SDCPhotoItem

+(instancetype)createdPhotoItem:(NSString *)urlStr WithThumb:(NSString *)thumbUrlStr
{
    SDCPhotoItem *item = [[SDCPhotoItem alloc]init];
    item.urlStr = urlStr;
    item.thumbUrlStr = thumbUrlStr;
    
    return item;
}



@end
