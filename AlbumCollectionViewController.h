//
//  AlbumCollectionViewController.h
//  Welko
//
//  Created by Umbrella on 16/8/4.
//  Copyright © 2016年 daiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumPicModel.h"
@interface AlbumCollectionViewController : UICollectionViewController
@property (nonatomic,strong) NSArray *picsArr;
@property (nonatomic,copy) NSString *navTitle;
@property (nonatomic,assign) BOOL isHasFooterTitle;
@property (nonatomic,assign) int albumType; //默认类型为0，其他类型有1
@end
