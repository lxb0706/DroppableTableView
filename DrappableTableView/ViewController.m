//
//  ViewController.m
//  DrappableTableView
//
//  Created by Chris on 2017/11/29.
//  Copyright © 2017年 Chris. All rights reserved.
//

#import "ViewController.h"

#import <Masonry/Masonry.h>

@interface ViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray<UITableView *> *tableViews;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSString *> *> *dataArrays;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
}

//MARK: - private methods
- (void)setupView{
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*)) {
            make.top.trailing.leading.equalTo(self.scrollView);
            make.bottom.equalTo(self.scrollView.mas_safeAreaLayoutGuideBottom);
        }else{
            make.edges.equalTo(self.scrollView);
        }
    }];
    
    UIView *preView = nil;
    for (UITableView *tableView in self.tableViews) {
        
        CGFloat viewHeight = self.dataArrays[tableView.tag].count * tableView.rowHeight;
        [self.containerView addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).mas_offset(20);
            make.width.mas_equalTo(CGRectGetWidth(self.view.frame) - 60);
            make.height.mas_equalTo(viewHeight);
            make.bottom.lessThanOrEqualTo(self.containerView).mas_offset(-30);
            if (preView) {
                make.leading.equalTo(preView.mas_trailing).mas_offset(20);
            }else{
                make.leading.equalTo(self.containerView).mas_offset(30);
            }
        }];
        preView = tableView;
    }
    if (preView) {
        [preView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.containerView).mas_offset(-30);
        }];
    }
}

//MARK: - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    NSLog(@"size:%@,scrollView.x = %lf",NSStringFromCGSize(scrollView.contentSize),scrollView.contentOffset.x);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.scrollView]) {
        [scrollView setContentOffset:scrollView.contentOffset animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    if ([scrollView isEqual:self.scrollView]) {
        [self hanleEndDraggingScrollView:scrollView];
    }
}


//MARK: - UITableView Delegate

//MARK: - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    for (UITableView *view in self.tableViews) {
        if (view.tag == tableView.tag) {
            count = self.dataArrays[tableView.tag].count;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"cellIdentifeir";
    for (UITableView *view in self.tableViews) {
        if (view.tag == tableView.tag) {
            cellIdentifier = [NSString stringWithFormat:@"cellIdentifier%ld",view.tag];
            break;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.dataArrays[tableView.tag][indexPath.row];
    return cell;
}

//MARK: - private methods
- (void)hanleEndDraggingScrollView:(UIScrollView *)scrollView{
    CGFloat offsetX = 0;
    CGFloat width = CGRectGetWidth(self.view.frame) - 60;

    if (scrollView.contentOffset.x <= width/2 + 30) {
        offsetX = 0;
    }else if (scrollView.contentOffset.x <= width*3/2 + 50){
        offsetX = width - 10 + 30;
    }else{
        offsetX = 2*width - 10 + 30 + 20;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        scrollView.contentOffset = CGPointMake(offsetX, 0);
    } completion:nil];
}

- (UITableView *)createTableViewWithTag:(NSInteger) tag{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    tableView.rowHeight = 44;
    tableView.tag = tag;
    tableView.layer.cornerRadius = 3;
    tableView.layer.masksToBounds = YES;
    return tableView;
}

- (NSMutableArray<NSString *> *)createTextArrayWithTag:(NSInteger)tag{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *text = [NSString stringWithFormat:@"No%ld.",tag];
    NSInteger count = arc4random()%15 + 5;
    for (NSInteger i = 0; i < count; i ++) {
        [array addObject:[NSString stringWithFormat:@"%@ Text%@",text,@(i)]];
    }
    return [array copy];
}


//MARK: - setter & getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
//        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:60.0/255.0 alpha:1];
    }
    return _scrollView;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [UIView new];
        
    }
    return _containerView;
}

- (NSMutableArray<UITableView *> *)tableViews{
    if (!_tableViews) {
 
        _tableViews = [[NSMutableArray alloc] init];
        [_tableViews addObject:[self createTableViewWithTag:0]];
        [_tableViews addObject:[self createTableViewWithTag:1]];
        [_tableViews addObject:[self createTableViewWithTag:2]];
    }
    return _tableViews;
}

- (NSMutableArray<NSMutableArray<NSString *> *> *)dataArrays{
    if (!_dataArrays) {
        
        _dataArrays = [[NSMutableArray alloc] init];
        [_dataArrays addObject:[self createTextArrayWithTag:0]];
        [_dataArrays addObject:[self createTextArrayWithTag:1]];
        [_dataArrays addObject:[self createTextArrayWithTag:2]];
    }
    return _dataArrays;
}


@end
