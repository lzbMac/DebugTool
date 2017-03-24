//
//  SHLabelsView.m
//  SHLabelsView
//
//  Created by 李正兵 on 2017/2/12.
//  Copyright © 2017年 李正兵. All rights reserved.
//

#import "SHLabelsView.h"
static const CGFloat kLabelSpace = 5.0;             //两个标签之间的间距
static const CGFloat kDefaultLabelHeight = 15.0;           //标签默认高度
static const CGFloat kDefaultTextFont = 9.0;        //标签文本字体大小

static const CGFloat kLabelExtendWidth  = 6.0;  //标签扩展宽度
static const CGFloat kLabelExtentHeight = 4.0;  //标签扩展高度

@implementation SHLabelsView
- (void)refreshLabelView{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [self.arrayContent enumerateObjectsUsingBlock:^(id<SHLabelsViewProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.textColor = [obj textColor]?[obj textColor]:[UIColor grayColor];
        label.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:244.0/255.0 blue:247.0/255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        [array addObject:label];
        
    }];
    //add labels
    CGRect lastTagViewRect=CGRectZero;
    for (int i=0; i<array.count; i++) {
        id<SHLabelsViewProtocol> obj = self.arrayContent[i];
        NSString *text = [obj labelText]?[obj labelText]:@"";
        UILabel *label=array[i];
        label.text = text;
        label.font = [UIFont systemFontOfSize:kDefaultTextFont];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName, nil];
        CGRect frame = [text boundingRectWithSize:CGSizeMake(1000, 1000)
                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributesDictionary context:nil];
        CGSize textSize =  CGSizeMake(round(frame.size.width+0.5) + kLabelExtendWidth, round(frame.size.height+0.5) + kLabelExtentHeight);
        
        CGRect rect=CGRectMake(0, 0, textSize.width, textSize.height);
        NSInteger lastNumber=i-1;
        if (lastNumber>=0) {
            UILabel *lastView=array[lastNumber];
            rect.origin.x=lastView.frame.origin.x+lastView.frame.size.width+kLabelSpace;
        }
        
        //指定最大宽度，如果超过最大宽度，则不添加
        if (self.fMaxWidth !=0  &&
            rect.origin.x>self.fMaxWidth){
            break;
        }
        
        label.frame=rect;
        label.layer.cornerRadius = rect.size.height*0.5;
        label.clipsToBounds = YES;
        [self addSubview:label];
        
        lastTagViewRect=rect;
    }
    //frame
    self.frame=CGRectMake(CGRectGetMinX(self.frame),
                          CGRectGetMinY(self.frame),
                          lastTagViewRect.origin.x+lastTagViewRect.size.width,
                          lastTagViewRect.size.height);
    
}

@end
