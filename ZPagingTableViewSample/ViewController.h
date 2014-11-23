//
//  ViewController.h
//  ZPagingTableViewSample
//
//  Created by jojok on 11/23/14.
//  Copyright (c) 2014 Your company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPagingTableView.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet ZPagingTableView *tableView;


@end

