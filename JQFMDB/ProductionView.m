//
//  ProductionView.m
//  JQFMDB
//
//  Created by Joker on 17/3/10.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "ProductionView.h"
#import "DBCell.h"
#import "Person.h"
#import "JQFMDB.h"
#import <objc/runtime.h>

@interface ProductionView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UISegmentedControl *segment;
@property (nonatomic, strong)UIScrollView *sView;
@property (nonatomic, strong)UILabel *alertLabel;
@property (nonatomic, strong)NSArray *dataArr;
@property (nonatomic, strong)NSMutableArray *columnNameArr;
@property (nonatomic, strong)NSMutableArray *blockArr;

@end

@implementation ProductionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.blockArr = [NSMutableArray arrayWithCapacity:0];
        [self configViews];
    }
    
    return self;
}

- (void)configViews
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    // 这里执行创建数据库,以后的shareDatabase系列都属于获取当前的数据库引用
    JQFMDB *db = [JQFMDB shareDatabase:@"qq.sqlite" path:path];
    
    [self creatSegmentAndSView];
    
    if (![db jq_isExistTable:@"user"]) {
        [self showAlertLabel];
    } else {
        self.columnNameArr = [NSMutableArray arrayWithArray:[db jq_columnNameArray:@"user"]];
        [self creatTableView];
        self.sView.hidden = NO;
        [self reloadData];
    }
    
    
    [self insertSubviews];
    [self deleteSubviews];
    [self updateSubviews];
    [self lookupSubviews];
    [self inTransaction];
}

- (void)inTransaction
{
    NSArray *arr = @[@"用事务插入1000条数据"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20+WIDTH*4, 20*(i+1)+i*30, WIDTH-40, 30);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = 500+i;
        [btn addTarget:self action:@selector(transactionBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sView addSubview:btn];
    }
}

- (void)lookupSubviews{
    
    NSArray *arr = @[@"查找name=cleanmonkey的数据",@"查找表中所有数据",@"保证线程安全查找name=cleanmonkey",@"异步(防止UI卡死)查找name=cleanmonkey"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20+WIDTH*3, 20*(i+1)+i*30, WIDTH-40, 30);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = 400+i;
        [btn addTarget:self action:@selector(lookupBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sView addSubview:btn];
    }
}

- (void)updateSubviews{
    
    NSArray *arr = @[@"更新最后一条数据的name=testName",@"把表中的name全部改成godlike",@"保证线程安全更新最后一条数据",@"异步(防止UI卡死)更新最后一条数据"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20+WIDTH*2, 20*(i+1)+i*30, WIDTH-40, 30);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = 300+i;
        [btn addTarget:self action:@selector(updateBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sView addSubview:btn];
    }
}

- (void)deleteSubviews{
    
    NSArray *arr = @[@"删除最后一条数据",@"删除全部数据",@"保证线程安全删除最后一条数据",@"异步(防止UI卡死)删除最后一条数据"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20+WIDTH, 20*(i+1)+i*30, WIDTH-40, 30);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = 200+i;
        [btn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sView addSubview:btn];
    }
}

- (void)insertSubviews{
    
    NSArray *arr = @[@"插入一条数据",@"插入一组数据",@"保证线程安全插入一条数据",@"异步(防止UI卡死)插入一条数据"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 20*(i+1)+i*30, WIDTH-40, 30);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(insertBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sView addSubview:btn];
    }
}

- (void)creatSegmentAndSView
{
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"插入", @"删除", @"更改", @"查找", @"事务操作"]];
    _segment.frame = CGRectMake(0, 20, WIDTH, 25);
    _segment.tintColor = [UIColor colorWithWhite:0.8 alpha:1];
    _segment.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _segment.selectedSegmentIndex = 0;
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_segment];
    
    self.sView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _segment.frame.origin.y+_segment.frame.size.height, WIDTH, HEIGHT/2)];
    _sView.contentSize = CGSizeMake(WIDTH*6, HEIGHT/2);
    _sView.hidden = YES;
    
    [self addSubview:_sView];
}

- (void)showAlertLabel
{
    self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, HEIGHT/8, WIDTH-100, HEIGHT/4)];
    _alertLabel.font = [UIFont systemFontOfSize:17];
    _alertLabel.numberOfLines = 0;
    _alertLabel.backgroundColor = [UIColor grayColor];
    _alertLabel.textColor = [UIColor whiteColor];
    _alertLabel.layer.cornerRadius = 5;
    _alertLabel.layer.masksToBounds = YES;
    _alertLabel.text = @"已默认创建数据库, 但无表, 点击任意位置创建表, 表字段由Person类根据runtime自动生成";
    
    [self addSubview:_alertLabel];
}

- (void)creatTableView
{
    [self addSubview:[self tableHeadView:_columnNameArr]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEIGHT/2+30, WIDTH, HEIGHT/2-30)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 40;
    
    [self addSubview:_tableView];
    
}

- (UIView *)tableHeadView:(NSArray *)columnArr
{
    
    float width = WIDTH;
    float height = 30;
    UIView *headView = UIView.new;
    headView.frame = CGRectMake(0, HEIGHT/2, WIDTH, height);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 15)];
    titleLabel.text = @"模拟显示数据库";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [headView addSubview:titleLabel];
    
    for (int i = 0; i < columnArr.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*(width/columnArr.count), 15, width/columnArr.count, height-15)];
        label.text = columnArr[i];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        
        [headView addSubview:label];
    }
    
    return headView;
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    [self.sView setContentOffset:CGPointMake(WIDTH*seg.selectedSegmentIndex, 0) animated:YES];
}

#pragma mark - *************** buttons action
- (void)insertBtn:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        if (i == btn.tag-100) {
            BLOCK block = _blockArr[i];
            block();
        }
    }
}

- (void)deleteBtn:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        if (i == btn.tag-200) {
            BLOCK block = _blockArr[i+4];
            block();
        }
    }
}

- (void)updateBtn:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        if (i == btn.tag-300) {
            BLOCK block = _blockArr[i+8];
            block();
        }
    }
}

- (void)lookupBtn:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        if (i == btn.tag-400) {
            BLOCK block = _blockArr[i+12];
            block();
        }
    }
}

- (void)transactionBtn:(UIButton *)btn
{
    for (int i = 0; i < 4; i++) {
        if (i == btn.tag-500) {
            BLOCK block = _blockArr[i+16];
            block();
        }
    }
}

- (void)insertMethod1:(BLOCK)block{[self.blockArr addObject:block];}
- (void)insertMethod2:(BLOCK)block{[self.blockArr addObject:block];}
- (void)insertMethod3:(BLOCK)block{[self.blockArr addObject:block];}
- (void)insertMethod4:(BLOCK)block{[self.blockArr addObject:block];}

- (void)deleteMethod1:(BLOCK)block{[self.blockArr addObject:block];}
- (void)deleteMethod2:(BLOCK)block{[self.blockArr addObject:block];}
- (void)deleteMethod3:(BLOCK)block{[self.blockArr addObject:block];}
- (void)deleteMethod4:(BLOCK)block{[self.blockArr addObject:block];}

- (void)updateMethod1:(BLOCK)block{[self.blockArr addObject:block];}
- (void)updateMethod2:(BLOCK)block{[self.blockArr addObject:block];}
- (void)updateMethod3:(BLOCK)block{[self.blockArr addObject:block];}
- (void)updateMethod4:(BLOCK)block{[self.blockArr addObject:block];}

- (void)lookupMethod1:(BLOCK)block{[self.blockArr addObject:block];}
- (void)lookupMethod2:(BLOCK)block{[self.blockArr addObject:block];}
- (void)lookupMethod3:(BLOCK)block{[self.blockArr addObject:block];}
- (void)lookupMethod4:(BLOCK)block{[self.blockArr addObject:block];}

- (void)transactionMethod1:(BLOCK)block{[self.blockArr addObject:block];}

- (void)reloadData
{
    JQFMDB *db = [JQFMDB shareDatabase];
    
    NSArray *resultArr = [db jq_lookupTable:@"user" dicOrModel:[Person class] whereFormat:nil];
    
    self.dataArr = resultArr;
    [self.tableView reloadData];
}

#pragma mark - *************** tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuse = @"reuse";
    DBCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (!cell) {
        cell = [[DBCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse columnArr:self.columnNameArr];
    }
    
    [cell setData:self.dataArr[indexPath.row]];
    
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        JQFMDB *db = [JQFMDB shareDatabase];
        
        if (![db jq_isExistTable:@"user"]) {
            [_alertLabel removeFromSuperview];
            [db jq_createTable:@"user" dicOrModel:[Person class]];
            self.columnNameArr = [NSMutableArray arrayWithArray:[db jq_columnNameArray:@"user"]];
            [self creatTableView];
            self.sView.hidden = NO;
        }
        
        
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
