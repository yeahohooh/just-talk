//
//  ViewController.h
//  just talk
//
//  Created by 李博 on 2021/6/18.
//

#import <UIKit/UIKit.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@interface ViewController : UIViewController<AgoraRtcEngineDelegate>
// 定义 agoraKit 变量
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;

@end

