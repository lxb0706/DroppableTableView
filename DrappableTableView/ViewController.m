//
//  ViewController.m
//  DrappableTableView
//
//  Created by Chris on 2017/11/29.
//  Copyright © 2017年 Chris. All rights reserved.
//

#import "ViewController.h"
#import "NSTimer+DT.h"

#import <Masonry/Masonry.h>

@interface ViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSMutableArray<UITableView *> *tableViews;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSString *> *> *dataArrays;
@property (nonatomic, strong) NSMutableArray *touchPoints;

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, weak) UITableView *sourceTableView;
@property (nonatomic, weak) NSIndexPath *sourceIndexPath;
@property (nonatomic, weak) UIView *snapshot;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGPoint snapOriginPt;
@property (nonatomic, assign) CGPoint snapNewPt;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.scrollView addGestureRecognizer:longPress];
}


//MARK: - handle long press
- (UIView *)createSnapshoFromView:(UIView *)inputView {
    // 用cell的图层生成UIImage，方便一会显示
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 自定义这个快照的样子（下面的一些参数可以自己随意设置）
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}


/**
 处理长按拖动开始
 
 @param tableView 目标 tableView
 @param indexPath 目标 indexPath
 @param location 位置
 */

- (void)handleLongPressStateBeganWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath location:(CGPoint)location{
    
    self.sourceTableView = tableView;
    self.sourceIndexPath = indexPath;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 为拖动的cell添加一个快照
    UIView *snapshot = [self createSnapshoFromView:cell];
    // 添加快照至tableView中
    __block CGPoint center = cell.center;
    center = [tableView convertPoint:center toView:self.scrollView];
    snapshot.center = center;
    snapshot.alpha = 0.0;
    [self.scrollView addSubview:snapshot];
    // 按下的瞬间执行动画
    [UIView animateWithDuration:0.3 animations:^{
        center.y = location.y;
        snapshot.center = center;
        snapshot.transform = CGAffineTransformMakeScale(0.95, 0.95);
        snapshot.alpha = 0.98;
        cell.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        cell.hidden = YES;
    }];
    self.snapOriginPt = center;
    self.snapshot = snapshot;
}


/**
 处理长按拖动过程
 
 @param tableView 目标 tableView
 @param indexPath 目标 indexPath
 @param location 位置
 */
- (void)handleLongPressStateChangedWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath location:(CGPoint)location{
    // 这里保持数组里面只有最新的两次触摸点的坐标
    [self.touchPoints addObject:[NSValue valueWithCGPoint:location]];
    if (self.touchPoints.count > 2) {
        [self.touchPoints removeObjectAtIndex:0];
    }
    CGPoint center = self.snapshot.center;
    // 快照随触摸点y值移动（当然也可以根据触摸点的y轴移动量来移动）
    center.y = location.y;
    // 快照随触摸点x值改变量移动
    CGPoint Ppoint = [[self.touchPoints firstObject] CGPointValue];
    CGPoint Npoint = [[self.touchPoints lastObject] CGPointValue];
    CGFloat moveX = Npoint.x - Ppoint.x;
    center.x += moveX;
    self.snapshot.center = center;
    self.snapNewPt = center;
    // 是否移动了
    if (indexPath && ![indexPath isEqual:self.sourceIndexPath] && [tableView isEqual:self.sourceTableView]) {
        
        NSInteger idx = tableView.tag;
        // 更新数组中的内容
        [self.dataArrays[idx] exchangeObjectAtIndex:indexPath.row withObjectAtIndex:self.sourceIndexPath.row];
        // 把cell移动至指定行
        [tableView moveRowAtIndexPath:self.sourceIndexPath toIndexPath:indexPath];
        // 存储改变后indexPath的值，以便下次比较
        self.sourceIndexPath = indexPath;
        
    } else if (indexPath && ![tableView isEqual:self.sourceTableView]) {
        
        for (UITableView *view in self.tableViews) {
            if ([view isEqual:self.sourceTableView]) {
                NSString *str = self.dataArrays[view.tag][self.sourceIndexPath.row];
                [self.dataArrays[view.tag] removeObjectAtIndex:self.sourceIndexPath.row];
                [view deleteRowsAtIndexPaths:@[self.sourceIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.dataArrays[tableView.tag] insertObject:str atIndex:indexPath.row];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.hidden = YES;
                self.sourceIndexPath = indexPath;
                self.sourceTableView = tableView;
            }
        }
    }
}


/**
 清楚操作
 */
- (void)handleLongPressOther{
    // 清空数组，非常重要，不然会发生坐标突变！
    [self.touchPoints removeAllObjects];
    UITableViewCell *cell = [self.sourceTableView cellForRowAtIndexPath:self.sourceIndexPath];
    cell.hidden = NO;
    cell.alpha = 0.0;
    // 将快照恢复到初始状态
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshot.center = [self.sourceTableView convertPoint:cell.center toView:self.scrollView];;
        self.snapshot.transform = CGAffineTransformIdentity;
        self.snapshot.alpha = 0.0;
        cell.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.sourceIndexPath = nil;
        [self.snapshot removeFromSuperview];
        self.snapshot = nil;
    }];
}

//MARK: - event reponse
- (void)longPressGestureRecognized:(UIGestureRecognizer *)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:self.scrollView];
    
    NSIndexPath *indexPath = nil;
    UITableView *tableView = nil;
    for (UITableView *view in self.tableViews) {
        if (CGRectContainsPoint(view.frame, location)) {
            tableView = view;
            CGPoint pt = [self.scrollView convertPoint:location toView:view];
            indexPath = [tableView indexPathForRowAtPoint:pt];
            break;
        }
    }
    if (!tableView || !indexPath) {
        return ;
    }

    switch (state) {
        case UIGestureRecognizerStateBegan: {// 已经开始按下
            [self startTimer];
            [self handleLongPressStateBeganWithTableView:tableView indexPath:indexPath location:location];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {// 移动过程中
            [self handleLongPressStateChangedWithTableView:tableView indexPath:indexPath location:location];
            break;
        }
        default: {// 长按手势取消状态
            [self stopTimer];
            [self hanleEndDraggingScrollView:self.scrollView];
            self.snapNewPt = CGPointZero;
            self.snapOriginPt = CGPointZero;
            [self handleLongPressOther];
            break;
        }
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
            make.width.mas_equalTo(self.viewWidth);
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
- (void)hanleEndDraggingScrollView:(UIScrollView *)scrollView{
    CGFloat offsetX = 0;
    CGFloat width = self.viewWidth;

    if (scrollView.contentOffset.x <= width/2 + 30) {
        offsetX = 0;
    }else if (scrollView.contentOffset.x <= width*3/2 + 50){
        offsetX = width - 10 + 30;
    }else{
        offsetX = 2*width - 10 + 30 + 20;
    }
    
    scrollView.contentOffset = CGPointMake(offsetX, 0);
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
    return array;
}

- (void)handleTimeUp{

    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGPoint pt = [self.view convertPoint:self.snapNewPt fromView:self.scrollView];
    if (pt.x >= width/3 && pt.x <= 2*width/3) {
        NSLog(@"o.x = %lf,new.x = %lf",self.snapOriginPt.x,pt.x);
        return ;
    }
    CGFloat offset = 0;
    if (pt.x> self.snapOriginPt.x) {
//        offset = pt.x- self.snapOriginPt.x - width/6;
        offset = 1;
    }else{
        offset = -1;
//        offset = pt.x - self.snapOriginPt.x + width/6;
    }
    
//    offset = offset/10;
    CGPoint offsetPt = self.scrollView.contentOffset;
    offsetPt.x += offset;
    if (offsetPt.x >= 0 && offsetPt.x <= 2*width - 50) {
        self.scrollView.contentOffset = offsetPt;
    }
}

- (void)startTimer{

    if(self.timer){
        self.timer = nil;
    }

    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer dt_scheduledTimerWithTimeInterval:0.015 action:^{
        [weakSelf handleTimeUp];
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer{
    
    [self.timer invalidate];
    self.timer = nil;
}


//MARK: - setter & getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
//        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
//        _scrollView.alwaysBounceHorizontal = YES;
//        _scrollView.bounces = YES;
//        [_scrollView setScrollEnabled:YES];
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
- (NSMutableArray *)touchPoints {
    if (!_touchPoints) {
        _touchPoints = [NSMutableArray array];
    }
    return _touchPoints;
}

- (CGFloat)viewWidth{
    if (_viewWidth == 0) {
        _viewWidth = CGRectGetWidth(self.view.frame) - 60;
    }
    return _viewWidth;
}

@end
