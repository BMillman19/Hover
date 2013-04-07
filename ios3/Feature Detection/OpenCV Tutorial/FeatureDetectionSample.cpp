//
//  FeatureDetection.cpp
//  OpenCV Tutorial
//
//  Created by Anton Belodedenko on 25/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include "FeatureDetectionSample.h"

#define kDetectorORB  "ORB"
#define kDetectorSURF "SURF"
#define kDetectorFAST "FAST"

bool fist = 0;

FeatureDetectionSample::FeatureDetectionSample()
: m_maxFeatures(100)
, m_fastThreshold(10)
{
    // feature extraction options
    m_alorithms.push_back( kDetectorORB );
    m_alorithms.push_back( kDetectorFAST );
    m_alorithms.push_back( kDetectorSURF );
    
    registerOption("Detection algorithm", "", &m_detectorName, m_alorithms);
    registerOption("Max features",        "", &m_maxFeatures, 1, 100);
    
    
    registerOption("Threshold", "FAST", &m_fastThreshold, 1, 100);
}

//! Gets a sample name
std::string FeatureDetectionSample::getName() const
{
    return "Feature detection";
}

std::string FeatureDetectionSample::getSampleIcon() const
{
    return "FeatureDetectionSampleIcon.png";
}

//! Returns a detailed sample description
std::string FeatureDetectionSample::getDescription() const
{
    return "Feature detection sample.";
}

static bool keypoint_score_greater(const cv::KeyPoint& kp1, const cv::KeyPoint& kp2)
{
    return kp1.response > kp2.response;
}

//! Processes a frame and returns output image
bool FeatureDetectionSample::processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame)
{
    // convert input frame to gray scale
    getGray(inputFrame, grayImage);
    
    
    if (m_detectorName == kDetectorORB)
    {
        cv::OrbFeatureDetector detector(m_maxFeatures);
        detector.detect(grayImage, objectKeypoints);
    }
    else if (m_detectorName == kDetectorFAST)
    {
        cv::FastFeatureDetector detector(m_fastThreshold);
        detector.detect(grayImage, objectKeypoints);
        
    }
    else if (m_detectorName == kDetectorSURF)
    {
        cv::SurfFeatureDetector detector;
        detector.detect(grayImage, objectKeypoints);
    }
//    std::cout << objectKeypoints.size() << "\n";
    if (objectKeypoints.size() > 90) {
        //        std::cout << "HAND!\n";
        std::vector<int>::size_type sz = objectKeypoints.size();
        double x_coord_sum = 0;
        double y_coord_sum = 0;
        for (int i = 0; i <sz; i++) {
            cv::KeyPoint k = objectKeypoints[i];
            double x_coord = k.pt.x;
            double y_coord = k.pt.y;
            x_coord_sum += x_coord;
            y_coord_sum += y_coord;
            //            std::cout << "X: " << x_coord << "\n";
            //            std::cout << "Y: " << y_coord << "\n";
        }
        double x_coord_average = x_coord_sum/sz;
        double y_coord_average = y_coord_sum/sz;
        //        std::cout << "X Average: " << x_coord_average << "\n";
        //        std::cout << "Y Average: " << y_coord_average << "\n";
        int outOfBoundingBox = 0;
        for (int i = 0; i <sz; i++) {
            cv::KeyPoint k = objectKeypoints[i];
            double x_coord = k.pt.x;
            double y_coord = k.pt.y;
            if (x_coord > x_coord_average - 105 && x_coord < x_coord_average + 105) {
                // X within bounding box
                if (y_coord > y_coord_average - 55 && y_coord < y_coord_average + 55) {
                    // Y within bounding box
                    // Do nothing
                } else {
                    outOfBoundingBox += 1;
                }
            } else {
                outOfBoundingBox += 1;
            }
        }
        if (outOfBoundingBox > 25) {
            if (fist) {
                std::cout << "Hand!\n";
                fist = 0;
            }
        } else {
            if (!fist) {
                std::cout << "Fist\n";
                fist = 1;
            }
        }
    }
    
    
    if (objectKeypoints.size() > m_maxFeatures)
    {
        std::sort(objectKeypoints.begin(), objectKeypoints.end(), keypoint_score_greater);
        objectKeypoints.resize(m_maxFeatures);
    }
    
    cv::Mat t;
    cv::cvtColor(inputFrame, t, CV_BGRA2BGR);
    cv::drawKeypoints(t, objectKeypoints, t, cv::Scalar::all(-1), cv::DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    
    cv::cvtColor(t, outputFrame, CV_BGR2BGRA);
    return true;
}