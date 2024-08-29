//
//  ContentViewController.m
//  ImmersiveMetal
//
//  Created by Jinwoo Kim on 8/29/24.
//

#import "ContentViewController.h"
#import "ImmersiveSceneDelegate.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <CompositorServices/CompositorServices.h>

CP_EXTERN const UISceneSessionRole CPSceneSessionRoleImmersiveSpaceApplication;

@interface ContentViewController ()
@property (retain, readonly, nonatomic) UIStackView *stackView;
@property (retain, readonly, nonatomic) UIButton *toggleImmersiveSceneVisibilityButton;
@property (retain, readonly, nonatomic) UIButton *toggleImmsersiveSceneStyleButton;
@property (retain, readonly, nonatomic) UISlider *portalCutoffAngleSlider;
@property (readonly, nonatomic, nullable) __kindof UIWindowScene *connectedImmsersiveScene;
@property (readonly, nonatomic, nullable) ImmersiveSceneDelegate *immersiveSceneDelegate;
@property (assign, nonatomic) NSUInteger immersionStyle;
@end

@implementation ContentViewController
@synthesize stackView = _stackView;
@synthesize toggleImmersiveSceneVisibilityButton = _toggleImmersiveSceneVisibilityButton;
@synthesize toggleImmsersiveSceneStyleButton = _toggleImmsersiveSceneStyleButton;
@synthesize portalCutoffAngleSlider = _portalCutoffAngleSlider;

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    [_stackView release];
    [_toggleImmersiveSceneVisibilityButton release];
    [_toggleImmsersiveSceneStyleButton release];
    [_portalCutoffAngleSlider release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.stackView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveSceneWillConnectNotification:) name:UISceneWillConnectNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveSceneDidDisconnectNotification:) name:UISceneDidDisconnectNotification object:nil];
    
    [self updateToggleImmersiveSceneVisibilityButton];
}

- (UIStackView *)stackView {
    if (auto stackView = _stackView) return stackView;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.toggleImmersiveSceneVisibilityButton,
        self.toggleImmsersiveSceneStyleButton,
        self.portalCutoffAngleSlider
    ]];
    
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillProportionally;
    stackView.alignment = UIStackViewAlignmentFill;
    
    _stackView = [stackView retain];
    return [stackView autorelease];
}

- (UIButton *)toggleImmersiveSceneVisibilityButton {
    if (auto toggleImmersiveSceneVisibilityButton = _toggleImmersiveSceneVisibilityButton) return toggleImmersiveSceneVisibilityButton;
    
    UIButton *toggleImmersiveSceneVisibilityButton = [UIButton new];
    
    [toggleImmersiveSceneVisibilityButton addTarget:self action:@selector(didTriggerToggleImmersiveSceneVisibilityButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    _toggleImmersiveSceneVisibilityButton = [toggleImmersiveSceneVisibilityButton retain];
    return [toggleImmersiveSceneVisibilityButton autorelease];
}

- (UIButton *)toggleImmsersiveSceneStyleButton {
    if (auto toggleImmsersiveSceneStyleButton = _toggleImmsersiveSceneStyleButton) return toggleImmsersiveSceneStyleButton;
    
    UIButton *toggleImmsersiveSceneStyleButton = [UIButton new];
    
    [toggleImmsersiveSceneStyleButton addTarget:self action:@selector(didTriggerToggleImmsersiveSceneStyleButton:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    _toggleImmsersiveSceneStyleButton = [toggleImmsersiveSceneStyleButton retain];
    return [toggleImmsersiveSceneStyleButton autorelease];
}

- (UISlider *)portalCutoffAngleSlider {
    if (auto portalCutoffAngleSlider = _portalCutoffAngleSlider) return portalCutoffAngleSlider;
    
    UISlider *portalCutoffAngleSlider = [UISlider new];
    portalCutoffAngleSlider.minimumValue = 0.f;
    portalCutoffAngleSlider.maximumValue = 180.f;
    portalCutoffAngleSlider.value = self.immersiveSceneDelegate.configuration.portalCutoffAngle;
    
    [portalCutoffAngleSlider addTarget:self action:@selector(didTriggerPortalCutoffAngleSlider:) forControlEvents:UIControlEventValueChanged];
    
    _portalCutoffAngleSlider = [portalCutoffAngleSlider retain];
    return [portalCutoffAngleSlider autorelease];
}

- (void)didTriggerToggleImmersiveSceneVisibilityButton:(UIButton *)sender {
    if (auto connectedImmsersiveScene = self.connectedImmsersiveScene) {
        [UIApplication.sharedApplication requestSceneSessionDestruction:connectedImmsersiveScene.session options:nil errorHandler:^(NSError * _Nonnull error) {
            
        }];
    } else {
        [self requestSceneWithPreferredImmersionStyle:2];
    }
}

- (void)didTriggerToggleImmsersiveSceneStyleButton:(UIButton *)sender {
    if (self.immersionStyle == 2) {
        [self updateSceneWithPreferredImmersionStyle:8];
    } else {
        [self updateSceneWithPreferredImmersionStyle:2];
    }
}

- (void)didTriggerPortalCutoffAngleSlider:(UISlider *)sender {
    self.immersiveSceneDelegate.configuration.portalCutoffAngle = sender.value;
}

- (void)didReceiveSceneWillConnectNotification:(NSNotification *)notification {
    [self updateToggleImmersiveSceneVisibilityButton];
    self.portalCutoffAngleSlider.value = self.immersiveSceneDelegate.configuration.portalCutoffAngle;
}

- (void)didReceiveSceneDidDisconnectNotification:(NSNotification *)notification {
    [self updateToggleImmersiveSceneVisibilityButton];
}

- (void)updateToggleImmersiveSceneVisibilityButton {
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    
    configuration.title = (self.connectedImmsersiveScene == nil) ? @"Show" : @"Hide";
    
    self.toggleImmersiveSceneVisibilityButton.configuration = configuration;
}

- (void)requestSceneWithPreferredImmersionStyle:(NSUInteger)preferredImmersionStyle {
    id options = [objc_lookUpClass("MRUISceneRequestOptions") new];
    
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setInternalFrameworksScene:"), NO);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setDisableDefocusBehavior:"), NO);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setPreferredImmersionStyle:"), preferredImmersionStyle);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setAllowedImmersionStyles:"), 10);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setSceneRequestIntent:"), 1002);
    
    id specification = [objc_lookUpClass("CPImmersiveSceneSpecification_SwiftUI") new];
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, NSSelectorFromString(@"setSpecification:"), specification);
    [specification release];
    
    //
    
    id initialClientSettings = [objc_lookUpClass("MRUIMutableImmersiveSceneClientSettings") new];
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setPreferredImmersionStyle:"), preferredImmersionStyle);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setAllowedImmersionStyles:"), 10);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, sel_registerName("setInitialClientSettings:"), initialClientSettings);
    [initialClientSettings release];
    
    //
    
    NSUserActivity * userActivity = [[NSUserActivity alloc] initWithActivityType:@"com.metalbyexample.FullyImmersiveMetal.openWindowByID"];
    userActivity.requiredUserInfoKeys = [NSSet setWithObject:@"com.apple.SwiftUI.sceneID"];
    userActivity.userInfo = @{@"com.apple.SwiftUI.sceneID": @"ImmersiveSpace"};
    
    reinterpret_cast<void (*)(id, SEL, id, id, id)>(objc_msgSend)(UIApplication.sharedApplication,
                                                                  NSSelectorFromString(@"mrui_requestSceneWithUserActivity:requestOptions:completionHandler:"),
                                                                  userActivity,
                                                                  options,
                                                                  ^(NSError * _Nullable error) {
        
    });
    
    [userActivity release];
    [options release];
    
    self.immersionStyle = preferredImmersionStyle;
    
    if (preferredImmersionStyle == 2) {
        self.immersiveSceneDelegate.configuration.immersionStyle = SRImmersionStyleMixed;
    } else {
        self.immersiveSceneDelegate.configuration.immersionStyle = SRImmersionStyleFull;
    }
}

- (void)updateSceneWithPreferredImmersionStyle:(NSUInteger)preferredImmersionStyle {
    auto connectedImmsersiveScene = self.connectedImmsersiveScene;
    if (connectedImmsersiveScene == nil) return;
    
    id fbsScene = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(connectedImmsersiveScene, sel_registerName("_scene"));
    NSString *identifier = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(fbsScene, sel_registerName("identifier"));
    
    id options = [objc_lookUpClass("MRUISceneRequestOptions") new];
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, sel_registerName("setSubstitutingSceneSessionIdentifier:"), identifier);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setInternalFrameworksScene:"), NO);
    reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(options, NSSelectorFromString(@"setDisableDefocusBehavior:"), NO);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setPreferredImmersionStyle:"), preferredImmersionStyle);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setAllowedImmersionStyles:"), 10);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(options, NSSelectorFromString(@"setSceneRequestIntent:"), 1001);
    
    id specification = [objc_lookUpClass("CPImmersiveSceneSpecification_SwiftUI") new];
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, NSSelectorFromString(@"setSpecification:"), specification);
    [specification release];
    
    //
    
    id initialClientSettings = [objc_lookUpClass("MRUIMutableImmersiveSceneClientSettings") new];
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setPreferredImmersionStyle:"), preferredImmersionStyle);
    reinterpret_cast<void (*)(id, SEL, NSUInteger)>(objc_msgSend)(initialClientSettings, NSSelectorFromString(@"setAllowedImmersionStyles:"), 10);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(options, sel_registerName("setInitialClientSettings:"), initialClientSettings);
    [initialClientSettings release];
    
    //
    
    reinterpret_cast<void (*)(id, SEL, id, id, id)>(objc_msgSend)(UIApplication.sharedApplication,
                                                                  NSSelectorFromString(@"mrui_requestSceneWithUserActivity:requestOptions:completionHandler:"),
                                                                  nil,
                                                                  options,
                                                                  ^(NSError * _Nullable error) {
        
    });
    
    [options release];
    
    self.immersionStyle = preferredImmersionStyle;
    
    if (preferredImmersionStyle == 2) {
        self.immersiveSceneDelegate.configuration.immersionStyle = SRImmersionStyleMixed;
    } else {
        self.immersiveSceneDelegate.configuration.immersionStyle = SRImmersionStyleFull;
    }
}

- (__kindof UIWindowScene *)connectedImmsersiveScene {
    for (__kindof UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:objc_lookUpClass("CPImmersiveScene")]) continue;
        if (![scene.session.role isEqualToString:CPSceneSessionRoleImmersiveSpaceApplication]) continue;
        
        return scene;
    }
    
    return nil;
}

- (ImmersiveSceneDelegate *)immersiveSceneDelegate {
    return (ImmersiveSceneDelegate *)self.connectedImmsersiveScene.delegate;
}

- (void)setImmersionStyle:(NSUInteger)immersionStyle {
    _immersionStyle = immersionStyle;
    
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    
    NSString *string;
    
    void *handle = dlopen("/System/Library/PrivateFrameworks/MRUIKit.framework/MRUIKit", RTLD_NOW);
    void *symbol = dlsym(handle, "_NSStringFromMRUIImmersionStyle");
    if (immersionStyle == 2) {
        string = reinterpret_cast<id (*)(NSUInteger)>(symbol)(8);
    } else {
        string = reinterpret_cast<id (*)(NSUInteger)>(symbol)(2);
    }
    
    configuration.title = [NSString stringWithFormat:@"Switch to %@", string];
    
    self.toggleImmsersiveSceneStyleButton.configuration = configuration;
}

@end
