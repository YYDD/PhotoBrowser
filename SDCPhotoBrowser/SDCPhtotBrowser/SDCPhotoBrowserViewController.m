//
//  SDCPhotoBrowserViewController.m
//  SDCPhotoBrowser
//
//  Created by YYDD on 16/6/13.
//  Copyright © 2016年 com.campus.cn. All rights reserved.
//

#import "SDCPhotoBrowserViewController.h"
#import "SDCPhotoSignalViewController.h"
#import "SDCPhotoItem.h"

@interface SDCPhotoBrowserViewController()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property(nonatomic,strong)NSMutableArray *photoArray;

@property(nonatomic,weak)UILabel *desLabel;
@property(nonatomic,weak)UIButton *deleteBtn;

@property(nonatomic,weak)UIPageViewController *pageViewController;
@end

@implementation SDCPhotoBrowserViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismiss) name:@"removePhotoBrowser" object:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self initPageController];
    [self initDescribeUI];
    [self initDeleteUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}


-(void)dealloc
{
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



-(void)setPhotoItems:(NSArray<SDCPhotoItem *> *)photoItems
{
    _photoItems = photoItems;
}

#pragma mark - 初始化数据
-(void)initData
{
    self.photoArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < _photoItems.count; i ++) {
        NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];

        SDCPhotoItem *item = _photoItems[i];
        if (_photoItems.count != 1) {
            item.titleStr = [NSString stringWithFormat:@"%d/%lu",(i+1),(unsigned long)_photoItems.count];
        }
        
        [mutDict setObject:item forKey:@"photoItem"];
        [self.photoArray addObject:mutDict];
    }

    [_pageViewController setViewControllers:@[[self createPhotoVCWithIndex:self.curIndex]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     [self changeDescribeWithCurIndex:self.curIndex];
                                 }];

    
}


#pragma mark - ui
-(void)initDescribeUI
{
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(10, self.view.frame.size.height - 10 - 30, self.view.frame.size.width - 10 * 2, 30);
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    [label.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    [label.layer setShadowOpacity:0.7];
    [label.layer setShadowColor:[UIColor blackColor].CGColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
    [label setHidden:YES];
    _desLabel = label;
}


-(void)initDeleteUI
{
    if (_canEdit) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"delete_btn"] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        [btn sizeToFit];
        [btn setContentEdgeInsets:UIEdgeInsetsMake(10, 20, 15, 10)];
        CGRect frame = btn.frame;
        frame.origin.x = self.view.frame.size.width - 10 - frame.size.width - btn.contentEdgeInsets.left - btn.contentEdgeInsets.right;
        frame.origin.y = 10 - btn.contentEdgeInsets.top;
        frame.size.width += (btn.contentEdgeInsets.left + btn.contentEdgeInsets.right);
        frame.size.height += (btn.contentEdgeInsets.top + btn.contentEdgeInsets.bottom);
        btn.frame= frame;
        [btn addTarget:self action:@selector(deleteCurPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        _deleteBtn = btn;
    }
}

-(void)initPageController
{
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                             options:nil];
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    
    pageViewController.view.frame = self.view.bounds;
    [self addChildViewController:pageViewController];
    
    [[self view] addSubview:[pageViewController view]];

    _pageViewController = pageViewController;
}


#pragma mark - pageController Delegate & dataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSInteger index = [self curIndexWithVC:viewController];
    index -- ;
    if (index < 0) {
        return nil;
    }

    return [self createPhotoVCWithIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self curIndexWithVC:viewController];
    index++;
    
    if (index >= self.photoArray.count) {
        return nil;
    }
    return [self createPhotoVCWithIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.photoArray.count;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        UIViewController *vc = (UIViewController *)_pageViewController.viewControllers[0];
        NSInteger index = [self curIndexWithVC:vc];
        [self changeDescribeWithCurIndex:index];
    }
}



#pragma mark - 创建相应的vc
-(SDCPhotoSignalViewController *)createPhotoVCWithIndex:(NSInteger)index
{
    NSDictionary *dict = self.photoArray[index];
    if (dict[@"vc"]) {
        return dict[@"vc"];
    }
    
    SDCPhotoItem *item = dict[@"photoItem"];
    SDCPhotoSignalViewController *vc = [[SDCPhotoSignalViewController alloc]init];
    vc.view.frame = _pageViewController.view.bounds;
    vc.photoItem = item;
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
    [mutDict setObject:vc forKey:@"vc"];
    [self.photoArray replaceObjectAtIndex:index withObject:mutDict];

    
    return vc;
    
}

#pragma mark - 根据 vc 来获取index
-(NSInteger)curIndexWithVC:(UIViewController *)vc
{
    NSInteger index = -100;
    for (NSDictionary *dict in self.photoArray) {
        if (dict[@"vc"]) {
            if (dict[@"vc"] == vc) {
                
                index = (NSInteger)[self.photoArray indexOfObject:dict];
                break;
            }
        }
    }

    return index;
}






-(void)changeDescribeWithCurIndex:(NSInteger)curIndex
{
    if (self.photoArray.count > 1) {
        [_desLabel setText:[NSString stringWithFormat:@"%d/%lu",(int)curIndex + 1,(unsigned long)self.photoArray.count]];
        [_desLabel setHidden:NO];
    }else
    {
        [_desLabel setHidden:YES];
    }


}


-(void)deleteCurPhoto
{
 
    if (self.photoArray.count == 1) {
        [self.photoArray removeAllObjects];
        if (_photoEditBlock) {
            _photoEditBlock(0);
        }
        [self dismiss];
    }else
    {
        UIViewController *vc = (UIViewController *)_pageViewController.viewControllers[0];
        NSInteger index = [self curIndexWithVC:vc];
        
        NSInteger nextIndex = index + 1;
        UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
        if (index == self.photoArray.count -1 ) {
            direction = UIPageViewControllerNavigationDirectionReverse;
            nextIndex = index - 1;
        }
        SDCPhotoSignalViewController *nextVC = [self createPhotoVCWithIndex:nextIndex];
        [_pageViewController setViewControllers:@[nextVC]
                                      direction:direction
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         NSInteger index = [self curIndexWithVC:nextVC];
                                         [self changeDescribeWithCurIndex:index];
                                         if (_photoEditBlock) {
                                             _photoEditBlock(index);
                                         }
                                     }];
        
        [self.photoArray removeObjectAtIndex:index];
    }
    
}



#pragma mark - 创建、显示、消失
+(instancetype)createdBrowserWithPhotoItems:(NSArray<SDCPhotoItem *> *)photoItems
{
    SDCPhotoBrowserViewController *vc = [[SDCPhotoBrowserViewController alloc]init];
    vc.photoItems = photoItems;
    return vc;
}


-(void)show
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;    // 设置动画效果
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

-(void)dismiss
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}




@end
