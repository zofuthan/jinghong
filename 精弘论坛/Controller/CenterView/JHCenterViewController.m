//
//  JHCenterViewController.m
//  精弘论坛
//
//  Created by Dikey on 9/14/14.
//  Copyright (c) 2014 dikey. All rights reserved.

// 开始，先从缓存中获取
// 获取成功->检查是否过期->网络操作->更新缓存->更新UI
//          不是->更新UI

//下拉刷新->网络操作->更新UI
//上拉刷新->(修改页面参数)->加载下一页

#import "JHCenterViewController.h"
#import "AFNetworking.h"

//#import "JHForumAPI.h"

#import "JHForumListCell.h"
#import "JHTopicsViewController.h"
#import "JHTopicDetailsViewController.h"
#import "SVProgressHUD.h"
#import "JHRESTEngine.h"
#import "JHBoardItem.h"
#import "JHFourmItem.h"
#import "JHRecentTopicsCell.h"
#import "JHTopicItem.h"
#import "JHUserDefaults.h"
#import "MJRefresh.h"

@interface JHCenterViewController ()

@property (copy, nonatomic) NSArray *forumItemList;
@property (copy, nonatomic) NSArray *boardList;
@property (copy, nonatomic) NSMutableArray *boardID;
@property (copy, nonatomic) NSArray *recentTopcicList;

@property (strong, nonatomic) JHFourmItem *jHForumItem;
@property (strong, nonatomic) JHBoardItem *jHBoardItem;
@property (strong, nonatomic) JHTopicItem *jHRecentTopicItem;

@end

@implementation JHCenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setTableViewHeaderAndFoot];

    [self loadBoardListAndRecentTopicsCache];
}

-(void)loadBoardListAndRecentTopicsCache
{
    NSArray *data = [[JHRESTEngine sharedJHRESTManager]getCachedArray:CacheType_RecentTopics];
        
    if (data.count!=0) {

//        NSArray *cachedItems = [NSKeyedUnarchiver unarchiveObjectWithData: data];

        if (!_recentTopcicList) {
            _recentTopcicList = [[NSArray alloc]initWithArray:data];
                    NSLog(@"%@",_recentTopcicList);
            if (_recentTopcicList!=nil && _recentTopcicList.count!=0) {
                [_recentTopicsTV reloadData];
            }
        }
        
    }else{
        [self getRecentTopTenTopics];
    }
//
//    
//    data = (NSData*)[[JHRESTEngine sharedJHRESTManager]getCachedArray:CacheType_BoardList];
//    if (data) {
//        NSArray *cachedBoardItems = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        
//        if (!_forumItemList) {
//            _forumItemList = [[NSArray alloc]initWithArray:cachedBoardItems];
//            //        NSLog(@"%@",_forumItemList);
//            
//            if (_forumItemList!=nil && _forumItemList.count!=0) {
//                [_tableView reloadData];
//            }
//        }
//    }else{
//        [self getRecentTopTenTopics];
//    }

}

-(void)setTableViewHeaderAndFoot
{
    _tableView.hidden= YES;
    _tableView.delegate =self;
    _tableView.dataSource = self;
    _recentTopicsTV.delegate = self;
    _recentTopicsTV.dataSource =self;
    
    [_tableView addHeaderWithCallback:^{
        _tableView.HeaderReleaseToRefreshText = @"你没事情刷新这个干什么...";
        [self getBoardList];
        [_tableView headerEndRefreshing];
    }];
    
    [_recentTopicsTV addHeaderWithCallback:^{
        [self getRecentTopTenTopics];
        _tableView.HeaderReleaseToRefreshText = @"刷新它...";
        [_recentTopicsTV headerEndRefreshing];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    
}

-(void)getRecentTopTenTopics
{
    [SVProgressHUD showProgress:SVProgressHUDMaskTypeNone status:@"载入中"];
    
    [[JHRESTEngine sharedJHRESTManager]getRecentTopicsOnSucceeded:^(NSArray *modelObjects) {
        [SVProgressHUD dismiss];
        
        if (!_recentTopcicList) {
            _recentTopcicList = [NSArray new];
        }
        if (modelObjects!=nil) {
            _recentTopcicList = [modelObjects copy];
            [_recentTopicsTV reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:@"没有返回列表"];
        }
    } onError:^(NSError *engineError) {
        [SVProgressHUD showErrorWithStatus:@"请求超时"];
    }];

}

-(void)getBoardList
{
    [SVProgressHUD showProgress:SVProgressHUDMaskTypeNone status:@"载入中"];

    [[JHRESTEngine sharedJHRESTManager]getBoardListOnSucceeded:^(NSArray *modelObjects) {
        [SVProgressHUD dismiss];
        
        if (!_forumItemList) {
            _forumItemList = [[NSArray alloc]init];
        }
        if (modelObjects!=nil) {
        _forumItemList = [modelObjects copy];
        [_tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:@"没有返回列表"];
        }
    } onError:^(NSError *engineError) {
        [SVProgressHUD showErrorWithStatus:@"请求超时"];

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma UITableViewDataSoucce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        if (_forumItemList != nil && _forumItemList.count!=0) {
            return [_forumItemList count];
        }
    }
    if (tableView == _recentTopicsTV) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (_forumItemList!=nil) {
            _jHForumItem = _forumItemList[section];
            return [_jHForumItem.board_list count];
        }
    }
    
    if (tableView == _recentTopicsTV) {
        if (_recentTopcicList!=nil) {
            return [_recentTopcicList count];
        }
    }

    return 0;
}

#warning 这里还需要加入判定，可能板块中还有板块(会闪退)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHForumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JHForumListCell"];
    JHRecentTopicsCell *recentTopicsCell = [tableView dequeueReusableCellWithIdentifier:@"JHRecentTopicsCell"];

    if (tableView == _tableView) {
        if (_forumItemList!=nil) {
            _jHForumItem = _forumItemList[indexPath.section];
            _jHBoardItem = _jHForumItem.board_list[indexPath.row];
            [cell displayValues:_jHBoardItem];
            
            return cell;
        }
    }
    
    if (tableView == _recentTopicsTV) {
        if (_recentTopcicList!= nil) {
            _jHRecentTopicItem = _recentTopcicList[indexPath.row];
            [recentTopicsCell displayValues:_jHRecentTopicItem];
        }
        return recentTopicsCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    JHTopicsViewController *jHTopicsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JHTopicsViewController"];
    JHTopicDetailsViewController *jHTopicsDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JHTopicDetailsViewController"];

    
    if (tableView == _tableView) {
        if (_forumItemList!=nil&&_forumItemList.count!=0) {
            _jHForumItem = _forumItemList[indexPath.section];
            _jHBoardItem = _jHForumItem.board_list[indexPath.row];
            
            
            [JHUserDefaults saveBoardID:[NSString stringWithFormat:@"%@",_jHBoardItem.board_id]];
            
            [self.navigationController pushViewController:jHTopicsVC animated:YES];
        }
    }
    if (tableView == _recentTopicsTV) {
        //jHRecentTopicItem
        if (_recentTopcicList!=nil&&_recentTopcicList.count!=0) {
            _jHRecentTopicItem = _recentTopcicList[indexPath.row];
            
            [JHUserDefaults saveBoardID:[NSString stringWithFormat:@"%d",_jHRecentTopicItem.board_id]];
            [JHUserDefaults saveTopicID:[NSString stringWithFormat:@"%d",_jHRecentTopicItem.topic_id]];
            
            [self.navigationController pushViewController:jHTopicsDetailsVC animated:YES];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        return 81;
    }
    if (tableView == _recentTopicsTV) {
        return 88;
    }
    return 44;
    
}

- (IBAction)selectedSegment:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"最新帖子");
            //[self getRecentTopTenTopics];
            //切换标题，重新赋予数据源，最新帖子
            //[_tableView reloadData];
            
            _tableView.hidden = YES;
            _recentTopicsTV.hidden = NO;
            
            break;
        case 1:
            NSLog(@"论坛列表");
            //[_tableView reloadData];
            //[self getBoardList];
            
            _tableView.hidden =NO;
            _recentTopicsTV.hidden = YES;
            
            break;
        default:
            break;
    }
}

@end
