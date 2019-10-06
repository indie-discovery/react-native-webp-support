#import "DBAWebpImageDecoder.h"
#import "RCTWebpAnimatedImage.h"
#include "libwebp/decode.h"
#include "libwebp/demux.h"

@implementation DBAWebpImageDecoder

RCT_EXPORT_MODULE()

- (BOOL)canDecodeImageData:(NSData *)imageData
{
    int result = WebPGetInfo([imageData bytes], [imageData length], NULL, NULL);
    if (result == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (RCTImageLoaderCancellationBlock)decodeImageData:(NSData *)imageData
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(RCTResizeMode)resizeMode
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler
{
  UIImage *image;
  WebPBitstreamFeatures features;
  WebPGetFeatures([imageData bytes], [imageData length], &features);

  if (features.has_animation) {
    image = [[RCTWebpAnimatedImage alloc] initWithData:imageData scale:scale];
  } else {
    int width = 0, height = 0;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    uint8_t *data = WebPDecodeRGBA([imageData bytes], [imageData length], &width, &height);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_data);

    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    
    CGDataProviderRelease(provider);
    CGImageRelease(imageRef);
  }
  
  if (!image) {
    completionHandler(nil, nil);
    return ^{};
  }
  
  completionHandler(nil, image);
  return ^{};
}
@end
