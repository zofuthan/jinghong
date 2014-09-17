//
//  JHLoginViewController.m
//  精弘论坛
//
//  Created by Dikey on 8/27/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//

#import "JHLoginViewController.h"
#import "MBProgressHUD.h"

#import "AFNetworking.h"


@interface JHLoginViewController ()
@property (strong,nonatomic) MBProgressHUD *loginHud;
@end

@implementation JHLoginViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _userName.delegate =self;
    _userPassword.delegate =self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//开始登录
-(void)startLoginProgress
{
    NSString *urlString = @"http://bbs.zjut.edu.cn/mobcent/login/login.php";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
////    http://bbs.zjut.edu.cn/mobcent/login/login.phpforumType=7&forumKey=CIuLQ1lkdPtOlhNuV4&sdkType=1&packageName=com.mobcent.newforum.app82036&platType=5&appName=精弘论坛
//    &email=Dikey&sdkVersion=2.0.0&password=123
    
    NSDictionary *parameters = @{@"forumType": @"7",
                                 @"forumKey": @"CIuLQ1lkdPtOlhNuV4",
                                 @"sdkType": @"1",
                                 @"packageName": @"com.mobcent.newforum.app82036",
                                 @"platType": @"5",
                                 @"appName": @"精弘论坛",
                                 @"email": @"iosapp",
                                 @"sdkVersion": @"2.0.0",
                                 @"password": @"appletest"
                                 };
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *dic = responseObject;
        
        if ([[dic objectForKey:@"rs"] boolValue] == 1) {
            
            //保存设置
//            [Toolkit saveUserName:_nameTextField.text];
//            [Toolkit saveID:[dic objectForKey:@"id"]];
//            [Toolkit saveName:[dic objectForKey:@"name"]];
//            [Toolkit saveToken:[dic objectForKey:@"token"]];

            _loginHud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
            [self.view addSubview:_loginHud];
            _loginHud.delegate = (id)self;
            _loginHud.labelText = @"登录成功";
            [_loginHud showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
            
        }
        else{
            _loginHud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
            [self.view addSubview:_loginHud];
            _loginHud.delegate = (id)self;
            _loginHud.labelText = @"输入有误";
            [_loginHud showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
        
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

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	//sleep(0.5);
    
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
