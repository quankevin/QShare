//
//  UIImage+QShare.h
//  ShareProxy
//
//  Created by 维农 on 16/7/18.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QShare)
- (UIImage *)QShare_resizedImage:(CGSize)newSize
            interpolationQuality:(CGInterpolationQuality)quality;
@end
