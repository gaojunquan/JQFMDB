//
//  ProductionView.h
//  JQFMDB
//
//  Created by Joker on 17/3/10.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

typedef void(^BLOCK)(void);

@interface ProductionView : UIView

- (void)reloadData;

- (void)insertMethod1:(BLOCK)block;
- (void)insertMethod2:(BLOCK)block;
- (void)insertMethod3:(BLOCK)block;
- (void)insertMethod4:(BLOCK)block;

- (void)deleteMethod1:(BLOCK)block;
- (void)deleteMethod2:(BLOCK)block;
- (void)deleteMethod3:(BLOCK)block;
- (void)deleteMethod4:(BLOCK)block;

- (void)updateMethod1:(BLOCK)block;
- (void)updateMethod2:(BLOCK)block;
- (void)updateMethod3:(BLOCK)block;
- (void)updateMethod4:(BLOCK)block;

- (void)lookupMethod1:(BLOCK)block;
- (void)lookupMethod2:(BLOCK)block;
- (void)lookupMethod3:(BLOCK)block;
- (void)lookupMethod4:(BLOCK)block;

- (void)transactionMethod1:(BLOCK)block;

@end
