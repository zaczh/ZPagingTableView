//
//  ViewController.m
//  ZPagingTableViewSample
//
//  Created by jojok on 11/23/14.
//  Copyright (c) 2014 Your company. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZPagingTableView *table = [[ZPagingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    table.delegate = self;
    table.cellWidth = 250;
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    
    
    //when loading from xib you need to set this parameter.
//    self.tableView.cellWidth = 250;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        /*
         Note that because we rotate the tableView counterclockwisly by M_PI_2, and
         then rotate the cell clockwisly by M_PI_2. Now the cell's coordination is
         what you see on screen, that is, its width is width you see it on screen, etc.
         */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 120, 24)];
        label.tag = 3;
        [cell.contentView addSubview:label];
    }
    
    if(indexPath.row % 3 == 0){
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:1.0];
    }else if(indexPath.row % 3 == 1){
        cell.backgroundColor = [UIColor colorWithRed:.0 green:1.0 blue:.0 alpha:1.0];
    }else{
        cell.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:1.0 alpha:1.0];
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:3];
    
    label.text = [NSString stringWithFormat:@"cell: %ld",(long)indexPath.row];
    
    return cell;
}


//add your tableView delegate method here.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select");
}
@end
