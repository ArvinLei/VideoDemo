//
//  LiveListViewController.h
//  直播Demo
//
//  Created by simple雨 on 2018/4/28.
//  Copyright © 2018年 simple雨. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CategoryModel.h"

@interface LiveListViewController : UIViewController

@property (nonatomic,strong) CategoryModel *category;
@property (nonatomic,copy) NSString *slug;

@end
