//
//  ViewController.m
//  just talk
//
//  Created by 李博 on 2021/6/18.
//

#import "ViewController.h"
#import "customRender.h"

@interface ViewController ()
// 定义 localView 变量
@property (nonatomic, strong) UIView *localView;
// 定义 remoteView 变量
@property (nonatomic, strong) UIView *remoteView;
@property (nonatomic, strong) customRender *customView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 调用初始化视频窗口函数
    [self initViews];
    // 后续步骤调用 Agora API 使用的函数
    [self initializeAgoraEngine];
    [self setChannelProfile];
    [self setClientRole];
    [self setupLocalVideo];
    [self joinChannel];
}

- (void)initViews {
    // 初始化远端视频窗口。只有当远端用户为主播时，才会显示视频画面
    self.remoteView = [[UIView alloc] initWithFrame:CGRectMake(0, 500, 200, 200)];
    [self.view addSubview:self.remoteView];
    // 初始化本地视频窗口。只有当本地用户为主播时，才会显示视频画面
    self.localView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:self.localView];
    
    self.customView = [[customRender alloc] initWithFrame:CGRectMake(500, 0, 200, 200)];
    [self.view addSubview:self.customView];
}

- (void)initializeAgoraEngine {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"your id" delegate:self];
}

- (void)setChannelProfile {
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
}

- (void)setClientRole {
    // 设置用户角色为主播
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster];
    [self.agoraKit startPreview];
    // 设置用户角色为观众
//    [self.agoraKit setClientRole:AgoraClientRoleAudience];
}

- (void)setupLocalVideo {
    // 启用视频模块
    [self.agoraKit enableVideo];
//    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
//    videoCanvas.uid = 0;
//    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
//    videoCanvas.view = self.localView;
//    // 设置本地视图
//    [self.agoraKit setupLocalVideo:videoCanvas];
    
    // 自定义渲染视图
    [self.agoraKit setLocalVideoRenderer:self.customView];
}

- (void)joinChannel {
    // 频道内每个用户的 uid 必须是唯一的
    [self.agoraKit joinChannelByToken:@"your token" channelId:@"test" info:nil uid:0 joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
    }];
}

// 监听 didJoinedOfUid 回调
// 远端主播加入频道时，会触发该回调
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.view = self.remoteView;
    // 设置远端视图
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (void)leaveChannel {
    [self.agoraKit leaveChannel:nil];
    [AgoraRtcEngineKit destroy];
}



@end
