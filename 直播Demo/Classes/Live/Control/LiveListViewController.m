//
//  LiveListViewController.m
//  直播Demo
//
//  Created by simple雨 on 2018/4/28.
//  Copyright © 2018年 simple雨. All rights reserved.
//

#import "LiveListViewController.h"

#import "RoomModel.h"
#import "RoomCell.h"
#import "SearchingViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SVPullToRefresh.h>
@interface LiveListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *rooms;

@property (nonatomic) int page;

@end

@implementation LiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    
    //创建CollectionView代码
    UICollectionViewFlowLayout *fl = [UICollectionViewFlowLayout new];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:fl];
    collectionView.backgroundColor = LGRGBA(240, 240, 240, 1);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    //注册Cell
    [collectionView registerClass:[RoomCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    __weak typeof (self) weakSelf = self;
    //添加下拉刷新
    [self.collectionView addPullToRefreshWithActionHandler:^{
        
        if (weakSelf.category) {//请求某个分类的数据
            [WebUtils requestRoomsWithCategory:weakSelf.category.slug andPage:1 andCallback:^(id obj) {
                
                weakSelf.rooms = obj;
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.pullToRefreshView stopAnimating];
                
                
            }];
        }else {
            //请求数据
            [WebUtils requestRoomsWithPage:1 andCallback:^(id obj) {
                weakSelf.page = 1;
                weakSelf.rooms = obj;
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.pullToRefreshView stopAnimating];
            }];
        }
        
    }];
    //上拉加载
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        
        weakSelf.page++;
        
        if (weakSelf.category) {//请求某个分类的数据
            [WebUtils requestRoomsWithCategory:weakSelf.category.slug andPage:weakSelf.page andCallback:^(id obj) {
                
                [weakSelf.rooms addObjectsFromArray:obj];
                [weakSelf.collectionView reloadData];
                
                [weakSelf.collectionView.infiniteScrollingView stopAnimating];
                
            }];
        }else {
            //请求数据
            [WebUtils requestRoomsWithPage:weakSelf.page andCallback:^(id obj) {
                
                [weakSelf.rooms addObjectsFromArray:obj];
                [weakSelf.collectionView reloadData];
                
                [weakSelf.collectionView.infiniteScrollingView stopAnimating];
                
            }];
        }
    }];
    
    [fl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"搜索_默认"] style:UIBarButtonItemStyleDone target:self action:@selector(searchAction)];
}
- (void)searchAction {
    
    SearchingViewController *vc = [SearchingViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.rooms.count == 0) {
        [self.collectionView triggerPullToRefresh];
    }
}
#pragma mark UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.rooms.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RoomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.room = self.rooms[indexPath.row];
    return cell;
    
}

//控制显示大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    float size = (LGSW-3*LGMargin)/2;
    return CGSizeMake(size, size*.8);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(LGMargin, LGMargin, 0, LGMargin);
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return LGMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return LGMargin;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //需要导入<AVFoundation>和AVKit
    RoomModel *room = self.rooms[indexPath.row];
    AVPlayerViewController *vc = [AVPlayerViewController new];
    vc.player = [AVPlayer playerWithURL:room.playURL];
    [vc.player play];
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
