//
//  ImmersiveSceneDelegate.mm
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import "ImmersiveSceneDelegate.h"
#import <CompositorServices/CompositorServices.h>
#import <objc/message.h>
#import <objc/runtime.h>

@implementation ImmersiveSceneDelegate
@synthesize configuration = _configuration;

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL responds = [super respondsToSelector:aSelector];
    
    if (!responds) {
        NSLog(@"%s", sel_getName(aSelector));
    }
    
    return responds;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    id fbsScene = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(connectionOptions, sel_registerName("_fbsScene"));
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(fbsScene, sel_registerName("addObserver:"), self);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(scene, NSSelectorFromString(@"setConfigurationProvider:"), self);
    
    cp_layer_renderer_t layerRenderer = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(scene, NSSelectorFromString(@"layer"));
    
    SpatialRenderer_InitAndRun(layerRenderer, self.configuration);
}

- (SRConfiguration *)configuration {
    if (auto configuration = _configuration) return configuration;
    
    SRConfiguration *configuration = [[SRConfiguration alloc] initWithImmersionStyle:SRImmersionStyleMixed];
    
    _configuration = configuration;
    return configuration;
}

// CPConfigurationProvider
- (cp_layer_renderer_configuration_t)layerConfigurationWithDefaultConfiguration:(cp_layer_renderer_configuration_t)defaultConfiguration layerCapabilites:(cp_layer_renderer_capabilities_t)layerCapabilites {
    cp_layer_renderer_configuration_t copy = [defaultConfiguration copy];
    cp_layer_renderer_configuration_set_layout(copy, cp_layer_renderer_layout_dedicated);
    cp_layer_renderer_configuration_set_foveation_enabled(copy, cp_layer_renderer_capabilities_supports_foveation(layerCapabilites));
    cp_layer_renderer_configuration_set_color_format(copy, MTLPixelFormatRGBA16Float);
    
    return copy;
}

- (void)scene:(id)scene didUpdateSettings:(id)update {
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(update, sel_registerName("inspect:"), ^(id settings) {
        id otherSettings = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(settings, sel_registerName("otherSettings"));
        
        // allowedImmersionStyles : 3002, preferredImmersionStyle : 3001
        id value = reinterpret_cast<id (*)(id, SEL, NSUInteger)>(objc_msgSend)(otherSettings, sel_registerName("objectForSetting:"), 3001);
        
        NSLog(@"%@", value);
    });
}

@end
