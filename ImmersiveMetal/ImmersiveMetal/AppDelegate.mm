//
//  AppDelegate.mm
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "ImmersiveSceneDelegate.h"
#import <objc/runtime.h>
#import <CompositorServices/CompositorServices.h>

CP_EXTERN const UISceneSessionRole CPSceneSessionRoleImmersiveSpaceApplication;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)option {
    __block NSUserActivity * _Nullable immersiveUserActivity = nil;
    
    [option.userActivities enumerateObjectsUsingBlock:^(NSUserActivity * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.activityType isEqualToString:@"com.metalbyexample.FullyImmersiveMetal.openWindowByID"]) {
            immersiveUserActivity = obj;
            *stop = YES;
        }
    }];
    
    if (immersiveUserActivity) {
        UISceneConfiguration *configuration = connectingSceneSession.configuration;
        configuration.delegateClass = ImmersiveSceneDelegate.class;
        configuration.sceneClass = NSClassFromString(@"CPImmersiveScene");
        return configuration;
    } else {
        UISceneConfiguration *configuration = connectingSceneSession.configuration;
        configuration.delegateClass = SceneDelegate.class;
        return configuration;
    }
}

@end
