//
//  customRender.m
//  just talk
//
//  Created by 李博 on 2021/6/23.
//

#import "customRender.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@import MetalKit;

@interface customRender()<MTKViewDelegate>
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@end

@implementation customRender

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mtkView = [[MTKView alloc] initWithFrame:self.bounds device:MTLCreateSystemDefaultDevice()];
        [self insertSubview:self.mtkView atIndex:0];
        self.mtkView.delegate = self;
        
        self.commandQueue = [self.mtkView.device newCommandQueue];
        
        self.mtkView.framebufferOnly = NO;
        self.mtkView.transform = CGAffineTransformMakeRotation(M_PI);
        
        CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
    }
    return self;
}

- (BOOL)shouldInitialize {
    
    return YES;
}

- (void)shouldStart {
    
}

- (void)shouldStop {
    
}

- (void)shouldDispose {
    
}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

- (AgoraVideoPixelFormat)pixelFormat {
    return AgoraVideoPixelFormatBGRA;
}

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(AgoraVideoRotation)rotation {
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    
    if (status == kCVReturnSuccess) {
        self.mtkView.drawableSize = CGSizeMake(width, height);
        self.texture = CVMetalTextureGetTexture(tmpTexture);
        CFRelease(tmpTexture);
    }
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)drawInMTKView:(MTKView *)view {
    if (self.texture) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        id<MTLTexture> drawingTexture = view.currentDrawable.texture;
        MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:self.mtkView.device sigma:1];
        [filter encodeToCommandBuffer:commandBuffer sourceTexture:self.texture destinationTexture:drawingTexture];
        [commandBuffer presentDrawable:view.currentDrawable];
        [commandBuffer commit];
        self.texture = NULL;
    }
}

@end
