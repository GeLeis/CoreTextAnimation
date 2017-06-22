//
//  UIView+Common.m
//  TextAnimation
//
//  Created by pz on 2017/6/22.
//  Copyright © 2017年 anve. All rights reserved.
//

#import "UIView+Common.h"
#import <CoreText/CoreText.h>

#define kRightMargin 10
#define kTickWidth 35

@implementation UIView (Common)
-(void)addText:(NSString *)text frame:(CGRect)frame{
    CGMutablePathRef letters = CGPathCreateMutable();   //创建path
    CTFontRef font = CTFontCreateWithName(CFSTR("Heiti SC"), 20.0f, NULL);
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName, nil];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);   //创建line
    CFArrayRef runArray = CTLineGetGlyphRuns(line);     //根据line获得一个数组
    
    // 获得每一个 run
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // 获得 run 的字体
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // 获得 run 的每一个形象字
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // 获得形象字
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            //获得形象字信息
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // 获得形象字外线的path
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    //根据构造出的 path 构造 bezier 对象
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    //根据 bezier 创建 shapeLayer对象
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.frame = CGRectMake(frame.origin.x, frame.origin.y, pathLayer.bounds.size.width, pathLayer.bounds.size.height);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor blackColor] CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [self.layer addSublayer:pathLayer];
    
    [pathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = text.length * 0.5;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(text.length * 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) self = weakself;
        UIBezierPath *tickPath = [UIBezierPath bezierPath];
        tickPath.lineCapStyle = kCGLineCapRound;
        tickPath.lineJoinStyle = kCGLineJoinRound;
        CGFloat x = self.frame.size.width - (kRightMargin + kTickWidth);
        CGFloat y =  frame.origin.y + 10;
        //勾的起点
        [tickPath moveToPoint:CGPointMake(x, y)];
        //勾的最底端
        CGPoint p1 = CGPointMake(x+8, y+ 8);
        [tickPath addLineToPoint:p1];
        //勾的最上端
        CGPoint p2 = CGPointMake(x+24,y-8);
        [tickPath addLineToPoint:p2];
        //新建图层——绘制上面的圆圈和勾
        CAShapeLayer *tickLayer = [[CAShapeLayer alloc] init];
        tickLayer.fillColor = [UIColor clearColor].CGColor;
        tickLayer.strokeColor = [UIColor greenColor].CGColor;
        tickLayer.lineWidth = 2;
        tickLayer.path = tickPath.CGPath;
        
        CABasicAnimation *tickAnimation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
        tickAnimation.fromValue = @0;
        tickAnimation.toValue = @1;
        tickAnimation.duration = 1;
        [tickLayer addAnimation:tickAnimation forKey:NSStringFromSelector(@selector(strokeEnd))];
        [self.layer addSublayer:tickLayer];
    });
    
}

@end
