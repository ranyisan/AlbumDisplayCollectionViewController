//
//  AlbumCollectionViewController.m
//  Welko
//
//  Created by Umbrella on 16/8/4.
//  Copyright © 2016年 daiya. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AlbumCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "UAProgressView.h"
#import "MBProgressHUD.h"
#import "AlbumTypeTwoCollectionViewCell.h"
@interface AlbumCollectionViewController ()<UIActionSheetDelegate>
@property (weak,nonatomic)UILabel *pageLabel;
@property (weak,nonatomic)UILabel *titleLabel;
@property (assign,nonatomic)int pageIndex;
@property (assign,nonatomic)CGFloat selfCellW;
@property (strong,nonatomic)UIImage *img;
@end

@implementation AlbumCollectionViewController

static NSString * const reuseIdentifier = @"AlbumCollectionViewCell";
static NSString * const twoReuseIdentifier = @"AlbumTypeTwoCollectionViewCell";

- (instancetype)init
{
    self.selfCellW = screenWith;
    
    // 创建一个流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 设置cell的尺寸
    if (self.albumType == 0) {
        
        layout.itemSize = CGSizeMake(self.selfCellW, screenHeight - 64);
    
    }else if (self.albumType == 1){
        
        layout.itemSize = CGSizeMake(self.selfCellW, screenHeight);
    }
    
    // 设置滚动的方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 行间距
    layout.minimumLineSpacing = 0;
    
    // 设置cell之间的间距
    layout.minimumInteritemSpacing = 0;
    
    // 组间距
    // layout.sectionInset = UIEdgeInsetsMake(100, 20, 0, 30);
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = self.navTitle;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_normal_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];
    
    // 初始化
    [self setUp];
    
    // 注册cell
    if (self.albumType == 0) {
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];

        
    }else if(self.albumType == 1){
    
        self.collectionView.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.7);
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"AlbumTypeTwoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:twoReuseIdentifier];
    }
    
    //添加张数显示Label子控件
    UILabel *pageLabel = [[UILabel alloc]init];
    if (self.albumType == 0) {
        
        pageLabel.frame = CGRectMake(0, screenHeight - 64 - 20 - 25, screenWith, 20);
    
    }else if (self.albumType == 1){

        pageLabel.frame = CGRectMake(0, 79, screenWith, 30);
    }
    
    [self.collectionView addSubview:pageLabel];
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.font = [UIFont systemFontOfSize:17];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)_picsArr.count];
    self.pageLabel = pageLabel;
    
    //添加底部标题显示label子控件
    if (self.isHasFooterTitle) {
        
        self.pageLabel.frame = CGRectMake(0, screenHeight - 64 - 20 - 20, screenWith, 20);

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight - 64 - 20 - 48, screenWith, 20)];
        [self.collectionView addSubview:titleLabel];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        if (self.picsArr.count) {
            titleLabel.text = [self.picsArr[0] title];
        }
        self.titleLabel = titleLabel;
    }
}

- (void)setUp
{
    self.collectionView.bounces = YES;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    self.collectionView.pagingEnabled = YES;
    
    self.collectionView.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _picsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.albumType == 0) {
        
        AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        __block UAProgressView *pv;
        __weak UIImageView *weakImageView = cell.imgView;
        
        AlbumPicModel *model = _picsArr[indexPath.row];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.icon]
                        placeholderImage:[UIImage imageNamed:@"img_failure_ic"]
                                 options:SDWebImageCacheMemoryOnly
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    if (!pv) {
                                        //创建进度条
                                        CGFloat pvW = 50;
                                        pv = [[UAProgressView alloc]initWithFrame:CGRectMake((self.selfCellW - pvW)* 0.5,(screenHeight - 64 - pvW) * 0.5,pvW, pvW)];
                                        pv.tintColor = kMainColorOfApp;
                                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pvW, 20.0)];
                                        label.font = [UIFont systemFontOfSize:14];
                                        [label setTextAlignment:NSTextAlignmentCenter];
                                        label.userInteractionEnabled = NO;
                                        pv.centralView = label;
                                        [weakImageView addSubview:pv];
                                    }
                                    
                                    // 这里一定要回到主队列刷新UI,用户自定义的进度条
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        
                                        [pv setProgress:(float)receivedSize/expectedSize animated:YES];
                                        
                                        pv.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
                                            [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
                                            
                                            if(progress >= 0.99){
                                                [pv removeFromSuperview];
                                                pv = nil;
                                            }
                                        };
                                    });
                                }
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                                   if (pv) {
                                       [pv removeFromSuperview];
                                       pv = nil;
                                   }
                               }];
         return cell;
    
    }else{
     
        AlbumTypeTwoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:twoReuseIdentifier forIndexPath:indexPath];
        
        __block UAProgressView *pv;
        __weak UIImageView *weakImageView = cell.imgView;
        
        AlbumPicModel *model = _picsArr[indexPath.row];
        
        __weak __typeof__(self) weakSelf = self;
        
        [cell returnToDoBlock:^{
           
            [weakSelf.collectionView removeFromSuperview];
        }];
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.icon]
                        placeholderImage:[UIImage imageNamed:@"img_failure_ic"]
                                 options:SDWebImageCacheMemoryOnly
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    if (!pv) {
                                        //创建进度条
                                        CGFloat pvW = 50;
                                        pv = [[UAProgressView alloc]initWithFrame:CGRectMake((self.selfCellW - pvW)* 0.5,(screenHeight - 64 - pvW) * 0.5,pvW, pvW)];
                                        pv.tintColor = kMainColorOfApp;
                                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pvW, 20.0)];
                                        label.font = [UIFont systemFontOfSize:14];
                                        [label setTextAlignment:NSTextAlignmentCenter];
                                        label.userInteractionEnabled = NO;
                                        pv.centralView = label;
                                        [weakImageView addSubview:pv];
                                    }
                                    
                                    // 这里一定要回到主队列刷新UI,用户自定义的进度条
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        
                                        [pv setProgress:(float)receivedSize/expectedSize animated:YES];
                                        
                                        pv.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
                                            [(UILabel *)progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
                                            
                                            if(progress >= 0.99){
                                                [pv removeFromSuperview];
                                                pv = nil;
                                            }
                                        };
                                    });
                                }
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                                   if (pv) {
                                       [pv removeFromSuperview];
                                       pv = nil;
                                   }
                               }];
        return cell;

    }
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.albumType == 0) {
        
        return CGSizeMake(self.selfCellW, screenHeight - 64);
        
    }else{
        
        return CGSizeMake(self.selfCellW, screenHeight);
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    self.pageIndex = (int)self.collectionView.contentOffset.x / self.selfCellW;
    
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",self.pageIndex + 1,(unsigned long)_picsArr.count];
    
    if (self.isHasFooterTitle && self.picsArr.count > self.pageIndex) {
        
        AlbumPicModel *model = self.picsArr[self.pageIndex];
        self.titleLabel.text = model.title;
    }
    
    self.pageLabel.x = self.collectionView.contentOffset.x;
    self.titleLabel.x = self.collectionView.contentOffset.x;
}

- (void)longPressToSavePrice:(UIImage *)img{
    
    // 弹出保存图片弹框
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"保存图片",nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.collectionView];
    self.img = img;
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != actionSheet.cancelButtonIndex ){
        
        self.img = [UIImage imageNamed:@"click"];
        if (self.img) {
            
            UIImageWriteToSavedPhotosAlbum(self.img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

#pragma mark - UIImageWriteToSavePhonesAlbum CallBack
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *saveResultMsg = @"已保存";
    
    if(error){
        saveResultMsg = @"保存失败";
    }
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.collectionView];
    [self.collectionView addSubview:HUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.label.text = saveResultMsg;
    [HUD showAnimated:NO];
    [HUD hideAnimated:NO afterDelay:2];
}

- (void) leftBarButtonClick {
    if (self.navigationController.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if([self.navigationController.viewControllers count] > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
