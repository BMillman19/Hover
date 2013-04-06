//
//  HoverSample.cpp
//  OpenCV Tutorial
//

#include <iostream>
#include "HoverClass.h"
#include "HoverSample.h"
#include "Globals.h"

#define NUM_FINGERS	5
#define NUM_DEFECTS	8

HoverSample::HoverSample() : m_maxCorners(200)
{
//    std::vector<std::string> algos;
//    algos.push_back("LKT");
//    registerOption("Algorithm",       "", &m_algorithmName, algos);
    
    // object tracking options
    registerOption("m_maxCorners", "Tracking", &m_maxCorners, 0, 1000);
    
    
}

//! Gets a sample name
std::string HoverSample::getName() const
{
    return "Hover";
}

std::string HoverSample::getSampleIcon() const
{
    return "HoverSampleIcon.png";
}

//! Returns a detailed sample description
std::string HoverSample::getDescription() const
{
    return "Yee";
}

//! Returns true if this sample requires setting a reference image for latter use
bool HoverSample::isReferenceFrameRequired() const
{
    return true;
}

//! Sets the reference frame for latter processing
void HoverSample::setReferenceFrame(const cv::Mat& reference)
{
    getGray(reference, imagePrev);
    computeObject = true;
}

// Reset object keypoints and descriptors
void HoverSample::resetReferenceFrame() const
{
    trackObject = false;
    computeObject = false;
}

//! Processes a frame and returns output image 
bool HoverSample::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame)
{
    // display the frame
    inputFrame.copyTo(outputFrame);
    
    // convert input frame to gray scale
    getGray(inputFrame, imageNext);
    
    // prepare the tracking class
    HoverClass ot;
    ot.setMaxCorners(m_maxCorners);
    
    // begin tracking object
    if ( trackObject ) {
        ot.track(outputFrame,
                 imagePrev,
                 imageNext,
                 pointsPrev,
                 pointsNext,
                 status,
                 err);
        
        // check if the next points array isn't empty
        if ( pointsNext.empty() )
            trackObject = false;
    }
       
    // store the reference frame as the object to track
    if ( computeObject ) {
        ot.init(outputFrame, imagePrev, pointsNext);
        trackObject = true;
        computeObject = false;
    }
    
    // backup previous frame
    imageNext.copyTo(imagePrev);
    
    // backup points array
    std::swap(pointsNext, pointsPrev);
    
    
    
    //////////////////////////////////////////////////
    
    
    
    // convert inputFrame into IplImage
    ctxStruct.image = new IplImage(inputFrame);
    
    
    // maybe we dont have to do this every frame???
    
    ctxStruct.thr_image = cvCreateImage(cvGetSize(ctxStruct.image), 8, 1);
	ctxStruct.temp_image1 = cvCreateImage(cvGetSize(ctxStruct.image), 8, 1);
	ctxStruct.temp_image3 = cvCreateImage(cvGetSize(ctxStruct.image), 8, 3);
	ctxStruct.kernel = cvCreateStructuringElementEx(9, 9, 4, 4, CV_SHAPE_RECT, NULL);
	ctxStruct.contour_st = cvCreateMemStorage(0);
	ctxStruct.hull_st = cvCreateMemStorage(0);
	ctxStruct.temp_st = cvCreateMemStorage(0);
	ctxStruct.fingers = calloc(NUM_FINGERS + 1, sizeof(CvPoint));
	ctxStruct.defects = calloc(NUM_DEFECTS, sizeof(CvPoint));
    
    // magic
    filter_and_threshold();
    find_contour();
    find_convex_hull();
    find_fingers();
    
    // display
    display(&ctx);
    cvWriteFrame(ctx.writer, ctx.image);
    
    return true;
}
