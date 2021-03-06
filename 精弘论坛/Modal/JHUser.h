//
//  JHUser.h
//  精弘论坛
//
//  Created by Dikey on 9/17/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHDataModel.h"

@interface JHUser : JHDataModel

+(instancetype)sharedInstance;

@property(nonatomic, copy) NSString *userID; //ID
@property(nonatomic, copy) NSString *name;

//@property(nonatomic, copy) NSString *token;
//@property(nonatomic, copy) NSString *secretToken;

@property(nonatomic, copy) NSURL * avatar;
//@property(nonatomic, assign) BOOL loginState;

@end
