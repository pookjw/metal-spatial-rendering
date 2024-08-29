//
//  SceneDelegate.mm
//  FullyImmersiveMetal
//
//  Created by Jinwoo Kim on 11/29/23.
//

#import "SceneDelegate.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "ContentViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    reinterpret_cast<void (*)(id, SEL, CGSize, id, id)>(objc_msgSend)(scene, sel_registerName("mrui_requestResizeToSize:options:completion:"), CGSizeMake(400., 400.), nil, ^(CGSize size, NSError * _Nullable error) {
        
    });
    
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:static_cast<UIWindowScene *>(scene)];
    ContentViewController *contentViewController = [ContentViewController new];
    window.rootViewController = contentViewController;
    self.window = window;
    [window makeKeyAndVisible];
}

@end
