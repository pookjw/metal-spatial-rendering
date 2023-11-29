//
//  ImmersiveSceneDelegate.mm
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import "ImmersiveSceneDelegate.h"
#import "SpatialRenderingEngine.h"
#import <CompositorServices/CompositorServices.h>
#import <objc/message.h>
#import <objc/runtime.h>

@implementation ImmersiveSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(scene, NSSelectorFromString(@"setConfigurationProvider:"), self);
    
    cp_layer_renderer_t layerRenderer = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(scene, NSSelectorFromString(@"layer"));
    
    SpatialRenderer_InitAndRun(layerRenderer);
}

// CPConfigurationProvider
- (cp_layer_renderer_configuration_t)layerConfigurationWithDefaultConfiguration:(cp_layer_renderer_configuration_t)defaultConfiguration layerCapabilites:(cp_layer_renderer_capabilities_t)layerCapabilites {
    cp_layer_renderer_configuration_set_layout(defaultConfiguration, cp_layer_renderer_layout_dedicated);
    cp_layer_renderer_configuration_set_foveation_enabled(defaultConfiguration, cp_layer_renderer_capabilities_supports_foveation(layerCapabilites));
    cp_layer_renderer_configuration_set_color_format(defaultConfiguration, MTLPixelFormatRGBA16Float);
    
    return defaultConfiguration;
}

@end
