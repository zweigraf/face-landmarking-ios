# Face Landmarking on iPhone

This prototype shows basic face landmark recognition on a ```CMSampleBuffer``` (see ```DlibWrapper.mm```) coming out of an ```AVCaptureSession```.

Frame rate is really bad as I am sure there are some performance improvements to be made. Currently, the buffers are copied around a lot.

## Credits

This app uses the Dlib library (<http://dlib.net>) and their default face landmarking model file downloaded from <http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2>.

## License

Code (except for ```DisplayLiveSamples/lib/*```) is released under MIT license.