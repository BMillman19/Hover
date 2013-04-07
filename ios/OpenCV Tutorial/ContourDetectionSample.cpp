//
//  ContourDetectionSample.cpp
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include "ContourDetectionSample.h"

ContourDetectionSample::ContourDetectionSample() 
{
    collectBackground = 1;
    collectBackgroundCounter = 0;
    referenceSet = 0;
}

//! Gets a sample name
std::string ContourDetectionSample::getName() const
{
  return "Contour detection";
}

//! Returns a detailed sample description
std::string ContourDetectionSample::getDescription() const
{
  return "Image contour detection is fundamental to many image analysis applications, including image segmentation, object recognition and classiﬁcation.";
}

std::string ContourDetectionSample::getSampleIcon() const
{
  return "ContourDetectionSampleIcon.png";
}

bool ContourDetectionSample::isReferenceFrameRequired() const
{
    return true;
}

//! Sets the reference frame for latter processing
void ContourDetectionSample::setReferenceFrame(const cv::Mat& reference)
{
    model = cv::Mat(reference.rows, reference.cols, reference.type());
    referenceSet = 1;
    collectBackground = 1;
    collectBackgroundCounter = 0;
}

// Reset object keypoints and descriptors
void ContourDetectionSample::resetReferenceFrame() const
{

}

//! Processes a frame and returns output image 
bool ContourDetectionSample::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame)
{
    if (referenceSet != 1) {
        inputFrame.copyTo(outputFrame);
        return true;
    }
    if (collectBackground == 1) {
//        cv::Mat convertedFrame;
//        inputFrame.convertTo(convertedFrame, CV_16UC1);
        cv::add(inputFrame, model, model);
        collectBackgroundCounter++;
        
        if (collectBackgroundCounter >= 50) {
            cv::convertScaleAbs(model, mask, 1.0 / 50);
            getGray(mask, mask);
            collectBackground = 0;
            collectBackgroundCounter = 0;
        }
    } else {
        
        cv::subtract(inputFrame, mask, subtracted);
        
        subtracted.copyTo(outputFrame);
        return true;
        
        getGray(subtracted, gray);
        
        cv::Mat edges;
        cv::Canny(gray, edges, 50, 150);
        std::vector< std::vector<cv::Point> > c;
        
        // find contours
        cv::findContours(edges, c, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
        
        // get max contour
        std::vector<cv::Point> maxContour;
        double max_area, area = 0;
        for (std::vector<std::vector<cv::Point> >::iterator it = c.begin() ; it != c.end(); ++it) {
            area = fabs(contourArea(*it));
            if (area > max_area) {
                max_area = area;
                maxContour = *it;
            }
        }
        // find convex hull of max contour
        std::vector<std::vector<cv::Point> >hull( 1 );
        cv::convexHull( cv::Mat(maxContour), hull[0], false );
        
        // draw contours and convex hull
        inputFrame.copyTo(outputFrame);
        cv::drawContours(outputFrame, c, -1, CV_RGB(0,200,0));
        cv::drawContours(outputFrame, hull, -1, CV_RGB(200,0,0));
    }
  
  return true;
}