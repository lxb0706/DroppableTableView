//
//  ViewController.m
//  DrappableTableView
//
//  Created by Chris on 2017/11/29.
//  Copyright © 2017年 Chris. All rights reserved.
//

#import "ViewController.h"

#import <Masonry/Masonry.h>

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *greenView;
@property (nonatomic, strong) UIView *blueView;

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
    
    
    [self.containerView addSubview:self.redView];
    [self.redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).mas_offset(30);
        make.top.equalTo(self.containerView).mas_offset(20);
        make.bottom.lessThanOrEqualTo(self.containerView).mas_offset(-20);
        make.width.mas_equalTo(CGRectGetWidth(self.view.frame) - 60);
        make.height.mas_equalTo(500);
    }];
    
    [self.containerView addSubview:self.greenView];
    [self.greenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.redView.mas_trailing).mas_offset(20);
        make.top.equalTo(self.redView);
        make.size.equalTo(self.redView);
    }];
    
    [self.containerView addSubview:self.blueView];
    [self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.greenView.mas_trailing).mas_offset(20);
        make.top.equalTo(self.redView);
        make.size.equalTo(self.redView);
        make.trailing.equalTo(self.containerView).mas_offset(-30);
    }];
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

- (void)hanleEndDraggingScrollView:(UIScrollView *)scrollView{
    CGFloat offsetX = 0;
    CGFloat width = CGRectGetWidth(self.redView.frame);

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

- (UIView *)redView{

    if (!_redView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor redColor];
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        _redView = view;
    }
    return _redView;
}

- (UIView *)greenView{
    if (!_greenView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor greenColor];
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        _greenView = view;
    }
    return _greenView;
}

- (UIView *)blueView{
    if (!_blueView) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor blueColor];
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        _blueView = view;
    }
    return _blueView;
}


@end
