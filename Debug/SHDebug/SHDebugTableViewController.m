//
//  SHDebugTableViewController.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "SHDebugTableViewController.h"
#import <objc/runtime.h>
#import "SHDebugModuleData.h"
@interface SHDebugTableViewController ()
@property (nonatomic, strong) NSArray<SHDebugModuleProtocol>* modules;
@property (nonatomic, strong) NSMutableArray<SHDebugTableViewController *> *viewControllers;
@end

@implementation SHDebugTableViewController
- (instancetype)initWithModule:(NSMutableArray<SHDebugModuleProtocol> *)modules{
    if (self = [self init]) {
        self.modules = modules;
    }
    return self;
}
+ (instancetype) defaultManager{
    static id instan;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instan = self.new;
    });
    return instan;
}

#pragma mark +
+(UIViewController *)topViewController{
    return [SHDebugTableViewController defaultManager].viewControllers.lastObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Debug Tools (v0.0.1)";
    [[SHDebugTableViewController defaultManager].viewControllers addObject:self];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [backButton setTitle:@"＜返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backDebugTools) forControlEvents:UIControlEventTouchUpInside];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(exitDebugTools) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
}
- (void)backDebugTools {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)exitDebugTools {
    [self.navigationController popToViewController:[SHDebugTableViewController defaultManager].currentVc animated:YES];
}

#pragma mark - Get/Set
- (NSArray<SHDebugModuleProtocol> *)modules{
    return _modules ?:({_modules = [SHDebugModuleData modules];});
}

- (NSMutableArray<SHDebugTableViewController *> *)viewControllers{
    return _viewControllers ?:({_viewControllers = [NSMutableArray array];});
}
#pragma mark - tableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SHDebugCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    Class<SHDebugModuleProtocol> cls = self.modules[indexPath.row];
#warning chuan - 初级了解。需要研究
    //获取该class对象
    const char* className = [NSStringFromClass(cls) cStringUsingEncoding:NSUTF8StringEncoding];
    Class metaClass = objc_getMetaClass(className);
    if (metaClass) {
        if ([metaClass instancesRespondToSelector:@selector(moduleName)]) {
            cell.textLabel.text = [cls moduleName];
        }
        else {
            cell.textLabel.text = @"未知模块";
        }
        if ([metaClass instancesRespondToSelector:@selector(moduleDetail)]) {
            cell.detailTextLabel.text = [cls moduleDetail];
        }
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@模块无法加载", cls];
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class<SHDebugModuleProtocol> cls = self.modules[indexPath.row];
    const char* className = [NSStringFromClass(cls) cStringUsingEncoding:NSASCIIStringEncoding];
    Class metaClass = objc_getMetaClass(className);
    if (metaClass && [metaClass instancesRespondToSelector:@selector(startModule)]) {
        [cls startModule];
    }
}
@end
