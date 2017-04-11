# JQFMDB

[![Build Status](https://img.shields.io/travis/facebook/react/master.svg?style=flat)](https://github.com/gaojunquan/JQFMDB) &nbsp; [![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php) &nbsp; [![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/gaojunquan/JQFMDB) &nbsp; 
[![CocoaPods](http://img.shields.io/cocoapods/v/JQFMDB.svg?style=flat)](http://cocoapods.org/?q=JQFMDB)

>**为了大家和项目的考虑, 如果使用过程中出现问题或者需要新功能接口提供, 请提一个issue, 需求合理会马上更新, 我每天都会关注 !**

## JQFMDB的特性

* 针对于FMDB的二次封装
* 线程安全
* 支持事务操作(目前others都仅支持线程安全)
* 操作简单, Model和Dictionary直接存储
* 拓展性强
* 不侵入你的任何Model
* 不需要实现某些奇怪的协议

#### 截图
![模拟器截图](http://upload-images.jianshu.io/upload_images/1982600-1d9412ee0d109a21.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/340)

## 安装JQFMDB
**Cocoapods**
```
1. 在 Podfile 中添加 `pod 'JQFMDB'`
2. 执行 `pod install` 或 `pod update`
3. 导入 <JQFMDB/JQFMDB.h>
```
**手动安装**
```
1. 下载 JQFMDB 文件夹内的所有内容。
2. 将 JQFMDB.h和JQFMDB.m 以及FMDB添加(拖放)到你的工程。
3. 导入 "JQFMDB.h"。
```
## 使用方法

#### 创建数据库

##### 单例方法
* \+ (instancetype)shareDatabase;
* \+ (instancetype)shareDatabase:(NSString *)dbName;
* \+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath;

单例方法创建数据库, 如果使用shareDatabase创建,则默认在NSDocumentDirectory下创建JQFMDB.sqlite, 但只要使用这三个方法任意一个创建成功, 之后即可使用三个中任意一个方法获得同一个实例,参数可随意或nil
`dbName` 数据库的名称 如: @"Users.sqlite", 如果dbName = nil,则默认dbName=@"JQFMDB.sqlite
`dbPath` 数据库的路径, 如果dbPath = nil, 则路径默认NSDocumentDirectory

```
// 创建数据库
JQFMDB *db = [JQFMDB shareDatabase];
或
JQFMDB *db = [JQFMDB shareDatabase:@"test.sqlite"];
或
JQFMDB *db = [JQFMDB shareDatabase:@"test.sqlite" path:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
```

##### init方法
* \- (instancetype)initWithDBName:(NSString *)dbName;
* \- (instancetype)initWithDBName:(NSString *)dbName path:(NSString *)dbPath;

如果操作几个数据库可以init方法获得不同实例, 参数说明同上.

#### 创建表(默认创建主键pkid)

###### 方式一(用Model创建表)
```
//Person类构成
@interface Person : NSObject

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSNumber *phoneNum;
@property (nonatomic, strong)NSData *photoData;
@property (nonatomic, assign)NSInteger luckyNum;
@property (nonatomic, assign)BOOL sex;
@property (nonatomic, assign)int age;
@property (nonatomic, assign)float height;  //float类型存入172.12会变成172.19995, 取值时%.2f等于原值172.12
@property (nonatomic, assign)double weight;

// 为了测试除以上类型外, 下面的类型不参与建表
@property (nonatomic, strong)NSDictionary *testDic;
@property (nonatomic, strong)NSArray *testArr;
@property (nonatomic, strong)NSError *testError;
@property (nonatomic, strong)Person *testP;
@end

// 创建表 @"user"=表的名称 表的字段为Person的有效属性
[db jq_createTable:@"user" dicOrModel:[Person class]];
```
###### 方式二(用字典创建表)
```
// 创建表 @"user"=表的名称 表的字段为字典的key,类型为字典的value
[db jq_createTable:@"user" dicOrModel:@{@"name":@"TEXT", @"age":@"INTEGER"}];
```
###### 主键用法
```
主键是默认自动创建的,名为pkid,如果你需要在你的Model中使用主键, 需要添加主键属性, 属性名必须为pkid
@property (nonatomic, assign)NSInteger pkid;
主键不会参加插入和修改操作
```

### 增删改查之插入
----
无论你想插入的是一个model还是dictionary都没问题,都会智能接收并存储;插入一组数据, 也支持model和dictionary混合的数组
* \- (BOOL)jq_insertTable:(NSString *)tableName dicOrModel:(id)parameters;
* \- (NSArray *)jq_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray;

##### 插入一条数据
```
Person *person = [[Person alloc] init];
    person.name = @"cleanmonkey";
    person.phoneNum = @(18866668888);
    person.photoData = UIImagePNGRepresentation([UIImage imageNamed:@"bg.jpg"]);
    person.luckyNum = 7;
    person.sex = 0;
    person.age = 26;
    person.height = 172.12;
    person.weight = 120.4555;
// 向user表中插入一条数据
[db jq_insertTable:@"user" dicOrModel:person];
或者你也可以用字典插入部分数据
[db jq_insertTable:@"user" dicOrModel:@{@"name":@"cleanmonkey",@"phoneNum":@(18866668888)}];
```
##### 插入一组数据
```
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
// 向user表中插入一组数据
[db jq_insertTable:@"user" dicOrModelArray:mArr];
// 或者也可以是model和dic混合形式的数组
[db jq_insertTable:@"user" dicOrModelArray:@[person, @{@"name":@"cleanmonkey"}, person]]
```
##### 异步(不阻塞主线程)插入数据, 想来想去还是觉得把异步封装在JQFMDB里不太好
```
//异步(防止UI卡死)插入一条数据, 也同样可以使用线程安全的方法(在jq_inDatabase的block中插入)
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [db jq_insertTable:@"user" dicOrModel:person];
        });
```
### 增删改查之删除
---
根据条件语句删除想要删除的数据;删除表中全部数据
* \- (BOOL)jq_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ...;
* \- (BOOL)jq_deleteAllDataFromTable:(NSString *)tableName;

##### 删除指定数据
```
//删除最后一条数据
[db jq_deleteTable:@"user" whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
```
##### 删除表中全部数据
```
//删除全部数据
[db jq_deleteAllDataFromTable:@"user"];
```
### 增删改查之更新
---
parameters为要更新的数据,可以是model或dictionary, format为条件语句
* \- (BOOL)jq_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

##### 更新指定数据
```
//更新最后一条数据 name=testName , dicOrModel的参数也可以是name为testName的person
[db jq_updateTable:@"user" dicOrModel:@{@"name":@"testName"} whereFormat:@"WHERE rowid = (SELECT max(rowid) FROM user)"];
```
##### 更新所有数据
```
//把表中所有的name改成godlike
[db jq_updateTable:@"user" dicOrModel:@{@"name":@"godlike"} whereFormat:nil];
```
### 增删改查之查找
---
parameters为查找到数据后每条数据要存入的模型,可以为model或dictionary
* \- (NSArray *)jq_lookupTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

##### 查找指定数据
```
////查找name=cleanmonkey的数据
NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:@"where name = 'cleanmonkey'"];
NSLog(@"name=cleanmonkey:%@", personArr);
```
##### 查找所有表中数据
```
//查找表中所有数据
NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:nil];
NSLog(@"表中所有数据:%@", personArr);
```
### 多线程操作之线程安全
---
以上操作是非线程安全的, 要想保证线程安全,还是采用FMDB的原型,所有操作都放在下面block中执行, 而block块内代码会被提交到一个队列中,从而保证线程安全, 但要注意的是block不能嵌套使用
```
/**
 将操作语句放入block中即可保证线程安全, 如:
 Person *p = [[Person alloc] init];
 p.name = @"小李";
 [jqdb jq_inDatabase:^{
 [jqdb jq_insertTable:@"users" dicOrModel:p];
 }];
 */
- (void)jq_inDatabase:(void (^)(void))block;
```
##### 例:将一系列操作都放在block中会保证线程安全
```
[db jq_inDatabase:^{
         [db jq_insertTable:@"user" dicOrModel:@{@"name":@"cleanmonkey"}];
         [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:@"where name = 'cleanmonkey'"];
    }];
```
##### 事务
用A给B转账100元的问题来简单阐述下事务, 首先查询下A的余额,如果>=100元,那么A账户先减去100元, 接着查询B账户的余额, B账户加上100元, 如果说在这之间有任何一个环节出了问题(余额不够, A查询或减去100元操作失败, B查询或加上100元操作失败),则进行回滚操作,相当于回到操作之前的状态,简单说,这就是一个事务操作
##### 事务操作也非常简单, 放在下面block中即可
```
/**
 Person *p = [[Person alloc] init];
 p.name = @"小李";
 for (int i=0,i < 1000,i++) {
 [jq jq_inTransaction:^(BOOL *rollback) {
 BOOL flag = [jq jq_insertTable:@"users" dicOrModel:p];
 if (!flag) {
 *rollback = YES; //只要有一次不成功,则进行回滚操作
 return;
 }
 }];
 }
 */
// 操作事务的方法
- (void)jq_inTransaction:(void(^)(BOOL *rollback))block;
```
`
#### Thanks
---
**Demo(用法注释很详细)和JQFMDB都已经放在了[我的GitHub](https://github.com/gaojunquan/JQFMDB)上,更多功能会陆续更新 如果觉得有用,帮忙点个star,十分感谢!**


