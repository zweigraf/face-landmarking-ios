//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"

#include <dlib/image_processing.h>
#include <dlib/image_io.h>

@interface DlibWrapper ()

@property (assign) BOOL prepared;
+ (dlib::rectangle)convertScaleCGRect:(CGRect)rect toDlibRectacleWithImageSize:(CGSize)size;

@end
@implementation DlibWrapper {
    dlib::shape_predictor sp;
}


-(instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

-(void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRect:(CGRect)rect {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    dlib::array2d<dlib::bgr_pixel> img;
    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    img.reset();
    long position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();

        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        char r = baseBuffer[bufferLocation + 2];
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        dlib::bgr_pixel newpixel(b, g, r);
        pixel = newpixel;
        
        position++;
    }
    
    // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    dlib::rectangle convertedRectangle = [DlibWrapper convertScaleCGRect:rect toDlibRectacleWithImageSize:CGSizeMake(width, height)];
    dlib::full_object_detection shape = sp(img, convertedRectangle);
    
    for (unsigned long k = 0; k < shape.num_parts(); k++) {
        dlib::point p = shape.part(k);
        draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
    }
    
    // lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    img.reset();
    position = 0;
    while (img.move_next()) {
        dlib::bgr_pixel& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        baseBuffer[bufferLocation] = pixel.blue;
        baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+ (dlib::rectangle)convertScaleCGRect:(CGRect)rect toDlibRectacleWithImageSize:(CGSize)size {
    long left = rect.origin.x * size.width;
    long top = rect.origin.y * size.height;
    long right = (rect.origin.x + rect.size.width) * size.width;
    long bottom = (rect.origin.y + rect.size.height) * size.height;
    
    dlib::rectangle dlibRect(left, top, right, bottom);
    return dlibRect;
}

@end
