//
//  ZPagingTableView.m
//  ZPagingTableViewSample
//
//  Created by jojok on 11/23/14.
//  Copyright (c) 2014 Your company. All rights reserved.
//

#import "ZPagingTableView.h"
#import <objc/runtime.h>

@interface ZPagingTableView()

//for delegate forwarding
@property (nonatomic, weak) id<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate> tableDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> tableDataSource;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) CGFloat headerFooterWidth;
@property (nonatomic, assign) NSInteger numberOfRows;

//these properties are for scrolling control
@property (assign, nonatomic) BOOL shouldBounce;
@property (assign, nonatomic) CGFloat decelerateBeginOffset;
@property (assign, nonatomic) CGFloat decelerateEndOffset;
@property (assign, nonatomic) CGFloat restoreOffset;
@property (assign, nonatomic) CGFloat offsetBeforeDragging;

@end

@implementation ZPagingTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    CGRect transformedFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    if(self = [super initWithFrame:transformedFrame style:style]){
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.headerFooterWidth = (frame.size.height - self.cellWidth)/2.0;
        self.dataSource = self;
    }
    return self;
}

//this is the default initializer when using xib
- (instancetype) initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
        self.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.headerFooterWidth = (self.frame.size.height - self.cellWidth)/2.0;
        self.dataSource = self;
    }
    return self;
}

- (void)setDelegate:(id<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>)delegate{
    if(delegate == self){
        return;
    }
    
    self.tableDelegate = delegate;
    
    //to clear "method cache", see http://stackoverflow.com/questions/11478740/shared-uitableviewdelegate
    [super setDelegate:self];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource{
    if(dataSource == self){
        return;
    }
    
    self.tableDataSource = dataSource;
    [super setDataSource:self];
}

- (void)setCellWidth:(CGFloat)cellWidth{
    _cellWidth = cellWidth;
    self.headerFooterWidth = (self.frame.size.width - self.cellWidth)/2.0;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    if([super respondsToSelector:aSelector]){
        return YES;
    }
    return [self.tableDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    return self.tableDelegate;
}

#pragma mark - tableview delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.headerFooterWidth)];
    view.backgroundColor = [UIColor grayColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.headerFooterWidth)];
    view.backgroundColor = [UIColor grayColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.headerFooterWidth;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return self.headerFooterWidth;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = [self.tableDelegate tableView:tableView numberOfRowsInSection:section];
    self.numberOfRows = result;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSAssert(cell != nil, @"-tableView:cellForRowAtIndexPath: must return a valid UITableViewCell");
    
    if(!CGAffineTransformEqualToTransform(cell.transform, CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2))){
        cell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellWidth;
}

#pragma mark - scrollView delegate
- (void)updatePageControl{
    CGFloat currentOffset = self.contentOffset.y;
    self.currentPage = currentOffset/self.cellWidth;
}

/*
    To do job after scrollView stops, you need to place your code in
    two places. The reason is that the scrollView halts immediately when you
    scroll very slowly, in which condition the scrollView will not decelerate.
    Otherwise, if you scroll fast enough, -scrollViewDidEndDecelerating: will
    called after the scrollView stops.
 */

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(!self.shouldBounce){
        [self updatePageControl];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self updatePageControl];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if(self.shouldBounce){
        
        //this will keep the scrollView from scrolling to its "target position"
        //in -(void)scrollViewWillEndDragging:withVelocity:targetContentOffset: call
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        
        [UIView animateWithDuration:.2 animations:^{
            
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.origin.y"];
            animation.values = @[@(self.decelerateBeginOffset),@(self.decelerateEndOffset), @(self.restoreOffset)];
            animation.duration = .4;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [scrollView.layer addAnimation:animation forKey:nil];
            
        } completion:^(BOOL finished){
            scrollView.contentOffset = CGPointMake(0, self.restoreOffset);
            [self updatePageControl];
            self.shouldBounce = NO;
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.offsetBeforeDragging = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat targetOffset = self.offsetBeforeDragging;
    
    if(velocity.y>0){
        
        //we are scrolling at the right edge, just return
        if(currentOffset > (self.numberOfRows - 1) * self.cellWidth){
            self.shouldBounce = NO;
            return;
        }
        
        for(int i=0; i<self.numberOfRows; ++i){
            if(self.cellWidth * i >= currentOffset){
                targetOffset = self.cellWidth * i;
                break;
            }
        }
        self.decelerateBeginOffset = currentOffset;
        self.decelerateEndOffset = targetOffset + velocity.y * 5;
        self.restoreOffset = targetOffset;
        self.shouldBounce = YES;
        
    }else if (velocity.y<0){
        
        if(currentOffset < 0){
            //scroll at left edge
            self.shouldBounce = NO;
            return;
        }
        
        for(NSInteger i=self.numberOfRows - 1; i>=0; --i){
            if(self.cellWidth * i <= currentOffset){
                targetOffset = self.cellWidth * i;
                break;
            }
        }
        self.decelerateBeginOffset = currentOffset;
        self.decelerateEndOffset = targetOffset + velocity.y * 5;
        self.restoreOffset = targetOffset;
        self.shouldBounce = YES;
        
    }else{
        if(currentOffset - self.offsetBeforeDragging >= self.cellWidth/2.0){
            targetOffset = self.offsetBeforeDragging + self.cellWidth;
        }else if (currentOffset - self.offsetBeforeDragging < -self.cellWidth/2.0){
            targetOffset = self.offsetBeforeDragging - self.cellWidth;
        }else{
            targetOffset = self.offsetBeforeDragging;
        }
        self.shouldBounce = NO;
    }
    
    targetContentOffset->y = targetOffset;
}
@end
