//
//  SDCPhotoSignalView.m
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/14.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import "SDCPhotoSignalView.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

#import "SDCPhotoItem.h"

#import "DACircularProgressView.h"


typedef enum
{
    kPhotoShowStageLoading = 1, /**< 下载中 */
    kPhotoShowStageSuccess = 2, /**< 下载成功 */
    kPhotoShowStageFailed = 3,  /**< 下载失败 */

}PhotoShowStage;


@interface SDCPhotoSignalView()<UIScrollViewDelegate,UIActionSheetDelegate>

@property(nonatomic,weak)UIScrollView *scrollView;
@property(nonatomic,weak)UIImageView *imgV;

@property(nonatomic,assign)CGFloat defaultZoomScale;

@property(nonatomic,assign)PhotoShowStage photoStage;

@property(nonatomic,weak)DACircularProgressView *progressView;


@end

@implementation SDCPhotoSignalView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.frame = frame;

        [self initUI];
        [self initProgressUI];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        
        UITapGestureRecognizer *signalTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signalTapAction:)];
        [_scrollView addGestureRecognizer:signalTap];
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [_scrollView addGestureRecognizer:longPress];
        
        [signalTap requireGestureRecognizerToFail:doubleTap];

    }

    return self;
}

#pragma mark - ui
-(void)initProgressUI
{
    DACircularProgressView *progressView = [[DACircularProgressView alloc] init];
    progressView.frame = CGRectMake(0, 0, 50, 50);
    progressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    progressView.roundedCorners = YES;
    progressView.thicknessRatio = 0.2;
    
    progressView.hidden = YES;

    [self addSubview:progressView];
    self.progressView = progressView;
}


-(void)initUI
{

    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.userInteractionEnabled = YES;
    scrollView.delegate = self;
    scrollView.decelerationRate = 0.1f;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.backgroundColor = [UIColor clearColor];
    imgV.contentMode = UIViewContentModeCenter;
    [scrollView addSubview:imgV];
    [imgV setUserInteractionEnabled:NO];
    
    _scrollView = scrollView;
    _imgV = imgV;
    
}


-(void)setPhotoItem:(SDCPhotoItem *)photoItem
{
    _photoItem = photoItem;

    //原图
    UIImage *originalImage = [self originalImage];
    if (originalImage) {
        _imgV.image = originalImage;
        self.photoStage = kPhotoShowStageSuccess;
        [self layoutSubviewsDefault];
        return;
    }
    
    //缩略图
    UIImage *thumbImage = [self thumbImage];
    
    //原图url
    NSString *urlStr = photoItem.urlStr;
    self.photoStage = kPhotoShowStageLoading;
    
    [_imgV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:thumbImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
       
        CGFloat progess = (CGFloat)receivedSize/expectedSize;
        [self.progressView setHidden:NO];
        [self.progressView setProgress:progess animated:YES];
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        
        [self.progressView removeFromSuperview];
        self.progressView = nil;
        
        if (error) {
            self.photoStage = kPhotoShowStageFailed;
            [self downloadImageFailed];
        }else
        {
            self.photoStage = kPhotoShowStageSuccess;
            [self layoutSubviewsDefault];
        }
        
    }];
    
    
    [self layoutSubviewsDefault];

}

-(UIImage *)originalImage
{
    //获取原图
    if (_photoItem.originalImage) {
        return _photoItem.originalImage;
    }
    
    NSString *cacheUrlStr = _photoItem.urlStr;
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:cacheUrlStr]];
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:key];

    return image;
}

-(UIImage *)thumbImage
{
    //获取默认图
    UIImage *thumbImage = nil;
    if (_photoItem.thumbImage) {
        thumbImage = _photoItem.thumbImage;
    }else
    {
        NSString *thumbUrlStr = _photoItem.thumbUrlStr;
        NSString *thumbKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:thumbUrlStr]];
        thumbImage = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:thumbKey];
        _photoItem.thumbImage = thumbImage;
    }
    
    if (!thumbImage) {
        thumbImage = [UIImage imageNamed:@"thumbPic"];
    }
    
    
    return thumbImage;
}

-(void)downloadImageFailed
{
    if (!_photoItem.thumbImage) {
        //说明只有默认的图片 需要更换失败的图片
        _imgV.image = [UIImage imageNamed:@"brokenPic"];
        [self layoutSubviewsJustOrigin];
    }
}



#pragma mark - layoutSubviews

-(void)layoutSubviewsDefault
{
    
    if (self.photoStage != kPhotoShowStageSuccess) {
        
        [self layoutSubviewsJustOrigin];
        return;
    }
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGSize imageSize = _imgV.image.size;
    CGSize newSize = CGSizeZero;
    
    CGFloat imageRate = imageSize.width/imageSize.height;
    CGFloat screenRate = screenWidth/screenHeight;
    
    
    if (imageSize.width < screenWidth && imageSize.height < screenHeight) {
        //说明图片 长和宽 都小于屏幕 需要放大
        
        if (imageRate < screenRate) {
            //过长
            CGFloat newHeight = screenHeight;
            CGFloat newWidth = imageRate * newHeight;
            
            newSize = CGSizeMake(newWidth, newHeight);
            
        }else
        {
            CGFloat newWidth = screenWidth;
            CGFloat newHeight = 1/imageRate * newWidth;
            
            newSize = CGSizeMake(newWidth, newHeight);

        }
        
        self.defaultZoomScale = screenHeight/imageSize.height;
        
    }else if (imageSize.width > screenWidth)
    {
        //只要 图片宽度大于 屏幕宽大了 都需要缩放至屏幕宽度
        
        CGFloat newWidth = screenWidth;
        CGFloat newHeight = 1/imageRate * newWidth;
        
        newSize = CGSizeMake(newWidth, newHeight);
        
        self.defaultZoomScale = screenHeight/imageSize.height;
        
    }else
    {
        newSize = imageSize;
        
        self.defaultZoomScale = screenWidth/imageSize.width;
    }

    [_imgV sizeToFit];
    
    [self layoutSubviewsJustOrigin];
    
    CGFloat maxZoom = (imageSize.width/newSize.width)/2;
    
    _scrollView.minimumZoomScale = newSize.width/imageSize.width;
    _scrollView.maximumZoomScale = MAX(maxZoom, self.defaultZoomScale);
    _scrollView.maximumZoomScale = MAX(_scrollView.maximumZoomScale, _scrollView.minimumZoomScale);
    if (_scrollView.maximumZoomScale == _scrollView.minimumZoomScale) {
        _scrollView.maximumZoomScale = _scrollView.maximumZoomScale * 1.2;
    }

    
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
    
    self.defaultZoomScale = MAX(self.defaultZoomScale, _scrollView.minimumZoomScale);
    if (_scrollView.maximumZoomScale <= self.defaultZoomScale * 2) {
        //如果在2倍以内 则直接可以放大到最大
        self.defaultZoomScale = _scrollView.maximumZoomScale;
    }
    
}


-(void)layoutSubviewsJustOrigin
{
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect frameToCenter = _imgV.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_imgV.frame, frameToCenter))
        _imgV.frame = frameToCenter;
    
}



#pragma mark - scrollView Delegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self layoutSubviewsJustOrigin];
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgV;
}


#pragma mark - tapGesture

-(void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    CGPoint locationPoint = [gesture locationInView:_scrollView];
    [self handleDoubleTap:locationPoint];
}


-(void)handleDoubleTap:(CGPoint)point
{
    if (self.photoStage == kPhotoShowStageLoading) {
        return;
    }
    
    if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
        //放大
        [self handleBigZoom:point];
    }else
    {
        //回到正常大小
        [self handleNormalZoom];
    }

}

-(void)handleNormalZoom
{
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
}


-(void)handleBigZoom:(CGPoint)tapPoint
{
    CGFloat bigZoom = self.defaultZoomScale;
    [_scrollView setZoomScale:bigZoom animated:YES];

}


-(void)signalTapAction:(UITapGestureRecognizer *)gesture
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"removePhotoBrowser" object:nil];
}



#pragma mark - 保存图片
-(void)longPressAction:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存到相册" otherButtonTitles:nil, nil];
        
        [actionSheet showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImageWriteToSavedPhotosAlbum(_imgV.image, nil, nil, nil);
            
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"没有用户权限,保存失败"];
        }
    }
}




@end
