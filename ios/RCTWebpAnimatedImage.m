#import "RCTWebpAnimatedImage.h"
#include "libwebp/decode.h"
#include "libwebp/demux.h"

static void free_data(void *info, const void *data, size_t size)
{
    free((void *) data);
}

@implementation RCTWebpAnimatedImage {
    CGFloat _scale;
    NSUInteger _loopCount;
    NSUInteger _frameCount;
    NSMutableArray<NSNumber *> *_delays;
    NSMutableArray<id /* CGIMageRef */> *_images;
}

- (instancetype)initWithData:(NSData *)imageData scale:(CGFloat)scale
{
  if (self = [super init]) {

    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    _scale = scale;
    
    WebPBitstreamFeatures features;
    WebPGetFeatures([imageData bytes], [imageData length], &features);
    if (features.has_animation) {
        int width = features.width;
        int height = features.height;
        
        WebPData webp_data;
        const uint8_t* data = [imageData bytes];
        size_t size = [imageData length];
        webp_data.bytes = data;
        webp_data.size = size;
        
        WebPAnimDecoderOptions dec_options;
        WebPAnimDecoderOptionsInit(&dec_options);
        dec_options.color_mode = MODE_RGBA;
        
        WebPAnimDecoder* dec = WebPAnimDecoderNew(&webp_data, &dec_options);
        WebPAnimInfo anim_info;
        WebPAnimDecoderGetInfo(dec, &anim_info);
        int timestamp = 0;
        _frameCount = anim_info.frame_count;
        _loopCount = anim_info.loop_count == 0 ? HUGE_VALF : anim_info.loop_count;
        _delays = [NSMutableArray arrayWithCapacity:_frameCount];
        _images = [NSMutableArray arrayWithCapacity:_frameCount];
        int frameIndex = 0;
        
        while (WebPAnimDecoderHasMoreFrames(dec)) {
            uint8_t* frame_rgba;
            uint8_t* curr_rgba = malloc(width * 4 * height);
            memset(curr_rgba, 0, width * 4 * height);
            int prevTimestamp = timestamp;
            WebPAnimDecoderGetNext(dec, &frame_rgba, &timestamp);
            
            memcpy(curr_rgba, frame_rgba, width * 4 * height);
            int delay = timestamp - prevTimestamp;
            _delays[frameIndex] = [NSNumber numberWithInt:delay];
            
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, curr_rgba, width*height*4, free_data);
            CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
            _images[frameIndex] = (__bridge_transfer id)imageRef;
            
            frameIndex++;
            CGDataProviderRelease(provider);
        }
        WebPAnimDecoderDelete(dec);
    } else {
        int width = 0, height = 0;
        uint8_t *data = WebPDecodeRGBA([imageData bytes], [imageData length], &width, &height);
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_data);
        
        _loopCount = HUGE_VALF;
        _frameCount = 1;
        _delays = [NSMutableArray arrayWithCapacity:_frameCount];
        _images = [NSMutableArray arrayWithCapacity:_frameCount]; 
        CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
        _images[0] = (__bridge_transfer id)imageRef;
        _delays[0] = [NSNumber numberWithFloat:HUGE_VALF];
        
        CGDataProviderRelease(provider);
        CGImageRelease(imageRef);
    }
    CGColorSpaceRelease(colorSpaceRef);
  }

  return self;
}

- (NSUInteger)animatedImageLoopCount
{
  return _loopCount;
}

- (NSUInteger)animatedImageFrameCount
{
  return _frameCount;
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index
{
  if (index >= _frameCount) {
    return 0;
  }
  return _delays[index].doubleValue/1000.0;
}

- (UIImage *)animatedImageFrameAtIndex:(NSUInteger)index
{
  if (index >= _frameCount) {
    return NULL;
  }
    return [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(_images[index]) scale:_scale orientation:UIImageOrientationUp];
}

@end
