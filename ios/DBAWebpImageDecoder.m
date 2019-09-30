#import "DBAWebpImageDecoder.h"
#import "RCTWebpAnimatedImage.h"
#include "WebP/decode.h"
#include "WebP/demux.h"

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
                                        resizeMode:(UIViewContentMode)resizeMode
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler
{
  RCTWebpAnimatedImage *image = [[RCTWebpAnimatedImage alloc] initWithData:imageData scale:scale];
  
  if (!image) {
    completionHandler(nil, nil);
    return ^{};
  }
  
  completionHandler(nil, image);
  return ^{};
}
@end
