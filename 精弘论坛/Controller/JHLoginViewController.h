//
//  JHLoginViewController.h
//  精弘论坛
//
//  Created by Dikey on 8/27/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;

@end
