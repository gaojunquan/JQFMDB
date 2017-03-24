//
//  DBCell.m
//  JQFMDB
//
//  Created by Joker on 17/3/10.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "DBCell.h"
#import <objc/runtime.h>

@implementation DBCell

static NSMutableArray *mArr;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier columnArr:(NSArray *)array
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 为了减少代码 这里用runtime和KVC, 不建议
        mArr = [NSMutableArray arrayWithArray:array];
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for (int i = 0; i < array.count; i++) {
            
            UILabel *label = UILabel.new;
            label.font = [UIFont systemFontOfSize:11];
            label.numberOfLines = 0;
            
            NSString *key = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
            [mArr replaceObjectAtIndex:[mArr indexOfObject:key] withObject:label];
            [self setValue:label forKey:key];
            [self.contentView addSubview:label];
            
        }
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float width = self.contentView.frame.size.width;
    for (int i = 0; i < mArr.count; i++) {
        [(UILabel *)mArr[i] setFrame:CGRectMake(i*width/mArr.count, 0, width/mArr.count, 40)];
    }
}

- (void)setData:(Person *)model
{
    self.name.text = model.name;
    self.phoneNum.text = model.phoneNum.stringValue;
    self.photoData.text = model.photoData ? @"data":@"NULL";
    self.luckyNum.text = [NSString stringWithFormat:@"%ld", (long)model.luckyNum];
    self.sex.text = [NSString stringWithFormat:@"%d", model.sex];
    self.age.text = [NSString stringWithFormat:@"%d", model.age];
    self.height.text = [NSString stringWithFormat:@"%.2f", model.height];
    self.weight.text = [NSString stringWithFormat:@"%.4f", model.weight];
    self.pkid.text = [NSString stringWithFormat:@"%ld", (long)model.pkid];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
