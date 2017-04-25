//
//  ViewController.m
//  JQFMDB
//
//  Created by Joker on 17/3/9.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "JQFMDB.h"
#import "Person.h"
#import "ProductionView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *person = [[Person alloc] init];
    person.name = @"cleanmonkey";
    person.phoneNum = @(18866668888);
    person.photoData = UIImagePNGRepresentation([UIImage imageNamed:@"bg.jpg"]);
    person.luckyNum = 7;
    person.sex = 0;
    person.age = 26;
    person.height = 172.12;
    person.weight = 120.4555;
    
    // 用来测试操作一组数据
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < 3; i++) {
        Person *person = [[Person alloc] init];
        person.name = [self randomName];
        person.phoneNum = @(18866668888);
        person.photoData = UIImagePNGRepresentation([UIImage imageNamed:@"bg.jpg"]);
        person.luckyNum = 7;
        person.sex = arc4random()%2;
        person.age = 26;
        person.height = 172.12;
        person.weight = 120.4555;
        
        [mArr addObject:person];
    }
    
    ProductionView *proViews = [[ProductionView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:proViews];
    
    JQFMDB *db = [JQFMDB shareDatabase];
    NSLog(@"last:%ld", (long)[db lastInsertPrimaryKeyId:@"user"]);
    
    // 增删改查操作集合
    [self insertMethod:proViews db:db model:person array:mArr];
    [self deleteMethod:proViews db:db model:person array:mArr];
    [self updateMethod:proViews db:db model:person array:mArr];
    [self lookupMethod:proViews db:db model:person array:mArr];
    
    // 事务操作
    [self transactionMethod:proViews db:db model:person array:mArr];

    
    NSLog(@"沙盒路径:%@", NSHomeDirectory());
}

#pragma mark - *************** 所有插入操作
- (void)insertMethod:(ProductionView *)proViews db:(JQFMDB *)db model:(Person *)person array:(NSMutableArray *)mArr
{
    [proViews insertMethod1:^{
        //插入一条数据
        [db jq_insertTable:@"user" dicOrModel:person];
        [proViews reloadData]; //刷新tableview
    }];
    
    [proViews insertMethod2:^{
        //插入一组数据, 数据多建议使用事务插入, 效率很高
        [db jq_insertTable:@"user" dicOrModelArray:mArr];
        [proViews reloadData]; //刷新tableview
    }];
    
    [proViews insertMethod3:^{
        //保证线程安全插入一条数据, jq_inDatabase的block中即可保证线程安全
        [db jq_inDatabase:^{
            [db jq_insertTable:@"user" dicOrModel:person];
            [proViews reloadData]; //刷新tableview
        }];
    }];
    
    [proViews insertMethod4:^{
        //异步(防止UI卡死)插入一条数据, 也同样可以使用线程安全的方法(在jq_inDatabase的block中插入)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [db jq_insertTable:@"user" dicOrModel:person];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [proViews reloadData]; //刷新tableview
            });
            
        });
        
    }];
}

#pragma mark - *************** 所有删除操作
- (void)deleteMethod:(ProductionView *)proViews db:(JQFMDB *)db model:(Person *)person array:(NSMutableArray *)mArr
{
    [proViews deleteMethod1:^{
        //删除最后一条数据
        [db jq_deleteTable:@"user" whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
        [proViews reloadData]; //刷新tableview
    }];
    
    [proViews deleteMethod2:^{
        //删除全部数据
        [db jq_deleteAllDataFromTable:@"user"];
        [proViews reloadData]; //刷新tableView;
    }];
    
    [proViews deleteMethod3:^{
        //保证线程安全删除最后一条数据
        [db jq_inDatabase:^{
            [db jq_deleteTable:@"user" whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
            [proViews reloadData]; //刷新tableview
        }];
    }];
    
    [proViews deleteMethod4:^{
        //异步(防止UI卡死)删除最后一条数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [db jq_inDatabase:^{
                [db jq_deleteTable:@"user" whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
            }];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [proViews reloadData]; //刷新tableview
            });
            
        });
    }];
}

#pragma mark - *************** 所有更新操作
- (void)updateMethod:(ProductionView *)proViews db:(JQFMDB *)db model:(Person *)person array:(NSMutableArray *)mArr
{
    [proViews deleteMethod1:^{
        //更新最后一条数据 name=testName , dicOrModel的参数也可以是name为testName的person
        [db jq_updateTable:@"user" dicOrModel:@{@"name":@"testName"} whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
        [proViews reloadData]; //刷新tableview
    }];
    
    [proViews deleteMethod2:^{
        //把表中所有的name改成godlike
        [db jq_updateTable:@"user" dicOrModel:@{@"name":@"godlike"} whereFormat:nil];
        [proViews reloadData]; //刷新tableView;
    }];
    
    [proViews deleteMethod3:^{
        //保证线程安全更新最后一条数据 name = safeName
        [db jq_inDatabase:^{
            [db jq_updateTable:@"user" dicOrModel:@{@"name":@"safeName"} whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
            [proViews reloadData]; //刷新tableview
        }];
    }];
    
    [proViews deleteMethod4:^{
        //异步(防止UI卡死)更新最后一条数据 name = asyncName
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [db jq_inDatabase:^{
                [db jq_updateTable:@"user" dicOrModel:@{@"name":@"asyncName"} whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
            }];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [proViews reloadData]; //刷新tableview
            });
            
        });
    }];
}

#pragma mark - *************** 所有查找操作
- (void)lookupMethod:(ProductionView *)proViews db:(JQFMDB *)db model:(Person *)person array:(NSMutableArray *)mArr
{
    [proViews lookupMethod1:^{
        ////查找name=cleanmonkey的数据
        NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:@"where name = 'cleanmonkey'"];
        NSLog(@"name=cleanmonkey:%@", personArr);
    }];
    
    // 把查询的结果存入字典示例
//    [proViews lookupMethod1:^{
//        ////查找name=cleanmonkey的数据
//        NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:@{@"name":@"TEXT",@"age":@"INTEGER",} whereFormat:@"where name = 'cleanmonkey'"];
//        NSLog(@"name=cleanmonkey:%@", personArr);
//    }];
    
    [proViews lookupMethod2:^{
        //查找表中所有数据
        NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:nil];
        NSLog(@"表中所有数据:%@", personArr);
    }];
    
    [proViews lookupMethod3:^{
        //保证线程安全查找name=cleanmonkey
       [db jq_inDatabase:^{
           NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:@"where name = 'cleanmonkey'"];
           NSLog(@"(safe)name=cleanmonkey:%@", personArr);
       }];
    }];
    
    [proViews lookupMethod4:^{
        //异步(防止UI卡死)查找name=cleanmonkey
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:@"where name = 'cleanmonkey'"];
            NSLog(@"(async)name=cleanmonkey:%@", personArr);
        });
    }];
}

#pragma mark - *************** 事务操作
- (void)transactionMethod:(ProductionView *)proViews db:(JQFMDB *)db model:(Person *)person array:(NSArray *)mArr
{
    [proViews transactionMethod1:^{
        //用事务插入1000条数据, 数据量多的话用事务插入会很快, 就像生产一件零件就送走和生产一堆零件再送走的效率问题
        [db jq_inTransaction:^(BOOL *rollback) {
            for (int i = 0; i < 1000; i++) {
                BOOL flag = [db jq_insertTable:@"user" dicOrModel:person];
                if (flag == NO) {
                    *rollback = YES; //回滚操作
                    return; //不加return会一直循环完1000
                }
            }
        }];
        [proViews reloadData];
    }];
}

// 获得随机字符名称
- (NSString *)randomName{
    
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < 7; i++) {
        int figure = (arc4random() % 26) + 97;
        char character = figure;
        NSString *tempString = [NSString stringWithFormat:@"%c", character];
        string = [string stringByAppendingString:tempString];
    }
    
    return string;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
