//
//  ViewController.m
//  SHLabelsView
//
//  Created by 李正兵 on 2017/2/12.
//  Copyright © 2017年 李正兵. All rights reserved.
//

#import "ViewController.h"
#import "SHLabelsView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SHLabelsView *labelsView;

@end

@interface TesxtModel : NSObject<SHLabelsViewProtocol>
@property (copy, nonatomic)NSString *text;
@end

@implementation TesxtModel

- (NSString *)labelText{
    return self.text;
}
- (UIColor *)textColor{
    return [UIColor blackColor];
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *text = @[@"hhah",@"",@"王亚云",@"李正兵",@"逆差带我电话卡我的",@"hhah,王亚云",@"李正兵",@"逆差带我电话卡我的",@"hhah,王亚云",@"李正兵",@"逆差带我电话卡我的"];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i =0; i < text.count; i++) {
        TesxtModel *model = [TesxtModel new];
        model.text = text[i];
        [arr addObject:model];
    }
    self.labelsView.arrayContent = arr;
    [self.labelsView refreshLabelView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
