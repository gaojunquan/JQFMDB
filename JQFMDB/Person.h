//
//  ViewController.m
//  JQFMDB
//
//  Created by Joker on 17/3/9.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSNumber *phoneNum;
@property (nonatomic, strong)NSData *photoData;
@property (nonatomic, assign)NSInteger luckyNum;
@property (nonatomic, assign)BOOL sex;
@property (nonatomic, assign)int age;
@property (nonatomic, assign)float height;  //float类型存入172.12会变成172.19995,取值时%.2f等于原值172.12
@property (nonatomic, assign)double weight;

// 为了测试除以上类型外, 下面的类型不参与建表
@property (nonatomic, strong)NSDictionary *testDic;
@property (nonatomic, strong)NSArray *testArr;
@property (nonatomic, strong)NSError *testError;
@property (nonatomic, strong)Person *testP;

@end
