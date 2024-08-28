//
//  SceneDelegate.mm
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import "SceneDelegate.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:static_cast<UIWindowScene *>(scene)];
    
    UIViewController *rootViewController = [UIViewController new];
    
    //
    
    UIButtonConfiguration *openButtonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    openButtonConfiguration.title = @"Open";
    
    UIAction *openButtonAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.metalbyexample.FullyImmersiveMetal.openWindowByID"];
        userActivity.requiredUserInfoKeys = [NSSet setWithObject:@"com.apple.SwiftUI.sceneID"];
        userActivity.userInfo = @{@"com.apple.SwiftUI.sceneID": @"ImmersiveSpace"};
        
        id options = [NSClassFromString(@"MRUISceneRequestOptions") new];
        id specification = [NSClassFromString(@"CPImmersiveSceneSpecification_SwiftUI") new];
        reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setDisableDefocusBehavior:"), YES);
        reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setPreferredImmersionStyle:"), 8);
        reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setAllowedImmersionStyles:"), 8);
        reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setSceneRequestIntent:"), 1002);
        reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, NSSelectorFromString(@"setSpecification:"), specification);
        reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setRequestExclusivePresentation:"), NO);
        
        //
        
        id initialClientSettings = [objc_lookUpClass("MRUIMutableImmersiveSceneClientSettings") new];
        reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setPreferredImmersionStyle:"), 8);
        reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setAllowedImmersionStyles:"), 8);
        
        reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, sel_registerName("setInitialClientSettings:"), initialClientSettings);
        
        //
        
        reinterpret_cast<void (*)(id, SEL, id, id, id)>(objc_msgSend)(UIApplication.sharedApplication,
                                                                      NSSelectorFromString(@"mrui_requestSceneWithUserActivity:requestOptions:completionHandler:"),
                                                                      userActivity,
                                                                      options,
                                                                      ^(NSError * _Nullable error) {
            
        });
    }];
    
    UIButton *openButton = [UIButton buttonWithConfiguration:openButtonConfiguration primaryAction:openButtonAction];
    openButton.layer.zPosition = 100.f;
    reinterpret_cast<void (*)(id, SEL, NSUInteger, id)>(objc_msgSend)(openButton, NSSelectorFromString(@"_requestSeparatedState:withReason:"), 1, @"SwiftUI.Transform3D");
    reinterpret_cast<void (*)(id, SEL, long)>(objc_msgSend)(openButton, NSSelectorFromString(@"sws_enablePlatter:"), 8);
    
    //
    
    UIButtonConfiguration *dismissButtonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    dismissButtonConfiguration.title = @"Dismiss";
    
    UIAction *dismissButtonAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
        [UIApplication.sharedApplication.connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"CPImmersiveScene")]) {
                [UIApplication.sharedApplication requestSceneSessionDestruction:obj.session options:nil errorHandler:^(NSError * _Nonnull error) {
                    
                }];
            }
        }];
    }];
    
    UIButton *dismissButton = [UIButton buttonWithConfiguration:dismissButtonConfiguration primaryAction:dismissButtonAction];
    dismissButton.layer.zPosition = 200.f;
    reinterpret_cast<void (*)(id, SEL, NSUInteger, id)>(objc_msgSend)(dismissButton, NSSelectorFromString(@"_requestSeparatedState:withReason:"), 1, @"SwiftUI.Transform3D");
    reinterpret_cast<void (*)(id, SEL, long)>(objc_msgSend)(dismissButton, NSSelectorFromString(@"sws_enablePlatter:"), 8);
    
    //
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[openButton, dismissButton]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.frame = rootViewController.view.bounds;
    stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [rootViewController.view addSubview:stackView];
    
    //
    
    window.rootViewController = rootViewController;
    [window makeKeyAndVisible];
    self.window = window;
}

@end
