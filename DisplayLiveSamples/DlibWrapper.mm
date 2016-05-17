//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"

#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/image_io.h>

@interface DlibWrapper ()

@property (assign) BOOL prepared;

- (void)prepare;

@end
@implementation DlibWrapper {
    dlib::frontal_face_detector detector;
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
    
    // We need a face detector.  We will use this to get bounding boxes for
    // each face in an image.
    detector = dlib::get_frontal_face_detector();
    // And we also need a shape_predictor.  This is the tool that will predict face
    // landmark positions given an image and face bounding box.  Here we are just
    // loading the model from the shape_predictor_68_face_landmarks.dat file you gave
    // as a command line argument.
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

-(void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (!self.prepared) {
        [self prepare];
    }

    NSString *imageName = @"left";
    NSString *imageExtension = @"jpg";
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:imageExtension];
    
    NSString *newFileName = [NSString stringWithFormat:@"%@-mod.%@", imageName, imageExtension];
    NSString *newImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:newFileName];
    
    std::string filename = [imagePath UTF8String];
    std::string newfilename = [newImagePath UTF8String];
    
    dlib::array2d<dlib::rgb_pixel> img;
    load_image(img, filename);

    std::vector<dlib::rectangle> dets = detector(img);
    
    std::vector<dlib::full_object_detection> shapes;
    for (unsigned long j = 0; j < dets.size(); ++j)
    {
        dlib::full_object_detection shape = sp(img, dets[j]);
        
        shapes.push_back(shape);
        
        for (unsigned long k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            draw_solid_circle(img, p, 1.5, dlib::rgb_pixel(0, 0, 255));
        }
    }
    
    save_jpeg(img, newfilename);
    
    NSLog(@"completed work");
}

@end
