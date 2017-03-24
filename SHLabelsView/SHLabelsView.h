//
//  SHLabelsView.h
//  SHLabelsView
//
//  Created by 李正兵 on 2017/2/12.
//  Copyright © 2017年 李正兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHLabelsViewProtocol.h"

@interface SHLabelsView : UIView
@property(nonatomic,assign)float fMaxWidth;                     //view最大宽度，可不指定，如果指定该参数，则当标签的view大于该宽度时，会舍弃后面的标签。默认不指定。
@property(nonatomic,strong)UIColor *labelBgColor;
@property(nonatomic,strong)NSMutableArray<id<SHLabelsViewProtocol>> *arrayContent;        //array内必须遵守 SHLabelsViewProtocol 协议

//先给以上属性赋值，然后调用该方法计算view
- (void)refreshLabelView;

@end
