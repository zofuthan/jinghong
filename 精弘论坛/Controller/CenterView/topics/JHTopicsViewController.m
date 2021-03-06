//
//  JHTopicsViewController.m
//  精弘论坛
//
//  Created by Dikey on 9/19/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//  主题列表
//再加入一个页数显示吧



#import "JHTopicsViewController.h"
#import "JHTopicDetailsViewController.h"
#import "JHTopicsCell.h"
#import "JHRESTEngine.h"
#import "JHTopicItem.h"
#import "JHUserDefaults.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"

@interface JHTopicsViewController ()

@property (strong,nonatomic) JHTopicItem* jhTopicItem;
@property (assign,nonatomic) __block int pageNumber;

@end

@implementation JHTopicsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageNumber = 1;
    _pageNumberLabel.text = @"第1页";
    [JHUserDefaults savePage:[NSString stringWithFormat:@"%d",_pageNumber]];
    
    [self getTopics];
    [self setTableViewHeaderAndFoot];
}



//        if (!_recentTopcicList) {
//            _recentTopcicList = [NSMutableArray new];
//            for (JHTopicItem *item in data) {
//                if (![_recentTopcicList containsObject:item]) {
//                    [_recentTopcicList addObject:item];
//                }
//            }
//            [_recentTopicsTV reloadData];

-(void)getTopicsListCache
{
    NSArray *data =[[JHRESTEngine sharedJHRESTManager]getCachedArray:CacheType_TopicsList];
    
    if (!data||data.count==0) {
        [self getTopics];
    }else{
        if (!_topicsItemList) {
            _topicsItemList = [NSMutableArray new];
            for (id object in data) {
                if (![_topicsItemList containsObject:object]) {
                    [_topicsItemList addObject:object];
                }
            }
            [_topicsTableView reloadData];
         }else{
             for (id object in data) {
                 if (![_topicsItemList containsObject:object]) {
                     [_topicsItemList addObject:object];
                 }
             }
             [_topicsTableView reloadData];
             
//            _topicsItemList = data;
//             if (_topicsItemList.count!=0) {
//                 [_topicsTableView reloadData];
//             }else{
//                 [SVProgressHUD showProgress:SVProgressHUDMaskTypeBlack status:@"已经是最后一页"];
//             }
        }
    }
}

-(void)setTableViewHeaderAndFoot
{
    _topicsTableView.delegate = self;
    _topicsTableView.dataSource = self;
    
    //下拉刷新
    [_topicsTableView addHeaderWithCallback:^{
        //假如是第一页，那下拉刷新，假如不是第一页，那上拉显示上一页的数据
        if (_pageNumber==1) {
            [self getTopics];
            _pageNumberLabel.text = @"第1页";
        }else{
            _pageNumber-=2;
            _pageNumberLabel.text = [NSString stringWithFormat:@"第%d页",(_pageNumber+1)/2];
            NSLog(@"第%d页",(_pageNumber+1)/2);

            [JHUserDefaults savePage:[NSString stringWithFormat:@"%d",_pageNumber]];
            [self getTopicsListCache];
        }
        
        [_topicsTableView headerEndRefreshing];
    }];
    
    //上拉刷新
    [_topicsTableView addFooterWithCallback:^{
        _pageNumber +=2 ; //因为原本是十帖子每页，我设置成了默认获取二十个帖子，所以要获取第三页开始
        [JHUserDefaults savePage:[NSString stringWithFormat:@"%d",_pageNumber]];
        _pageNumberLabel.text = [NSString stringWithFormat:@"第%d页",(_pageNumber+1)/2];
        
        [self getTopicsListCache];
        [_topicsTableView footerEndRefreshing];
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)getTopics
{
    [SVProgressHUD showWithStatus:@"正在加载帖子列表" maskType:SVProgressHUDMaskTypeBlack];
    
    //获取数据
    [[JHRESTEngine sharedJHRESTManager]getTopicsListOnSucceeded:^(NSArray *modelObjects) {
        [SVProgressHUD dismiss];
        
        _topicsItemList = [modelObjects mutableCopy];
        [_topicsTableView reloadData];
        
    } onError:^(NSError *engineError) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        
    }];
    
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_topicsItemList!=nil&&_topicsItemList.count!=0 ) {
        return [_topicsItemList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JHTopicsCell *jHTopicsCell = [tableView dequeueReusableCellWithIdentifier:@"JHTopicsCell"];
    
    if (_topicsItemList!=nil&&_topicsItemList.count!=0) {
        
        [jHTopicsCell displayValues:(JHTopicItem *)_topicsItemList[indexPath.row]];
        
    }
    
    return jHTopicsCell;
}


#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _jhTopicItem =  (JHTopicItem* )_topicsItemList[indexPath.row];
    
    [JHUserDefaults saveBoardID:[NSString stringWithFormat:@"%d",_jhTopicItem.board_id]];
    [JHUserDefaults saveTopicID:[NSString stringWithFormat:@"%d",_jhTopicItem.topic_id]];
    [JHUserDefaults saveUid:[NSString stringWithFormat:@"%d",_jhTopicItem.user_id]];

    JHTopicDetailsViewController *topicDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"JHTopicDetailsViewController"];
    
    topicDetailVC.titleLabel.text = [_jhTopicItem.title copy];
    [self.navigationController pushViewController:topicDetailVC animated:YES];
}






/*
 "list": [
 {
 "board_id": 303,
 "board_name": "『 池塘边 』",
 "topic_id": 1627002,
 "type": "normal",
 "title": "[闲聊灌水]听说山里要禁电瓶车了、？",
 "user_id": 225561,
 "user_nick_name": "尐卩孩",
 "last_reply_date": "1411116372000",
 "vote": 0,
 "hot": 0,
 "hits": 42,
 "replies": 5,
 "essence": 0,
 "top": 0,
 "subject": "是真的么？还是不了了之了。有意入辆代步万一禁了那不草蛋了。  各位大神知道详情么",
 "pic_path": ""
 },
 */


/*
 r	forum/topiclist
 boardId	303
 appName	精弘论坛
 sdkVersion	2.0.0
 forumKey	CIuLQ1lkdPtOlhNuV4
 pageSize	10
 accessToken
 forumType	7
 page	1
 sdkType	1
 accessSecret
 forumId	1
 packageName	com.mobcent.newforum.app82036
 platType	5
 */



@end
