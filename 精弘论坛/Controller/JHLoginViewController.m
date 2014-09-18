//
//  JHLoginViewController.m
//  精弘论坛
//
//  Created by Dikey on 8/27/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//

#import "JHLoginViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface JHLoginViewController ()
@end

@implementation JHLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _userName.delegate =self;
    _userPassword.delegate =self;
}

-(void)viewWillAppear:(BOOL)animated
{
    _userName.text = @"iosapp";
    _userPassword.text = @"appletest";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//开始登录
-(void)startLoginProgress
{
    
    [SVProgressHUD showWithStatus:@"登录中"];
    NSString *urlString = @"http://bbs.zjut.edu.cn/mobcent/login/login.php";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    NSDictionary *parameters = @{@"forumType": @"7",
                                 @"forumKey": @"CIuLQ1lkdPtOlhNuV4",
                                 @"sdkType": @"1",
                                 @"packageName": @"com.mobcent.newforum.app82036",
                                 @"platType": @"5",
                                 @"appName": @"精弘论坛",
                                 @"email": _userName.text,
                                 @"sdkVersion": @"2.0.0",
                                 @"password": _userPassword.text
                                 };
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = responseObject;
        
        if ([[dic objectForKey:@"rs"] boolValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            //保存设置
            //            [Toolkit saveUserName:_nameTextField.text];
            //            [Toolkit saveID:[dic objectForKey:@"id"]];
            //            [Toolkit saveName:[dic objectForKey:@"name"]];
            //            [Toolkit saveToken:[dic objectForKey:@"token"]];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];

}

//登录按钮
- (IBAction)startLogin:(id)sender
{
    [self startLoginProgress];
}

//键盘切换
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userName) {
        [_userPassword becomeFirstResponder];
    }
    if (textField == _userPassword) {
        [_userPassword resignFirstResponder];
    }
    [self startLoginProgress];    
    
    //直接登录
    return YES;
}

//点击背景
- (IBAction)backGroundTapped:(id)sender
{
    [_userPassword resignFirstResponder];
    [_userName resignFirstResponder];
}

@end
