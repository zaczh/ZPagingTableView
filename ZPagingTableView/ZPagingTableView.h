//
//  ZPagingTableView.h
//  ZPagingTableViewSample
//
//  Created by jojok on 11/23/14.
//  Copyright (c) 2014 Your company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPagingTableView : UITableView<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, readonly) NSInteger currentPage;
@end
