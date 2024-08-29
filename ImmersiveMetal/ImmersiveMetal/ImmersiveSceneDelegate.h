//
//  ImmersiveSceneDelegate.h
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import <UIKit/UIKit.h>
#import "SpatialRenderingEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImmersiveSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic, readonly) SRConfiguration *configuration;
@end

NS_ASSUME_NONNULL_END
