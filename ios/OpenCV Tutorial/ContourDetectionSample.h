//
//  ContourDetectionSample.h
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef OpenCV_Tutorial_ContourDetectionSample_h
#define OpenCV_Tutorial_ContourDetectionSample_h

#include "SampleBase.h"

class ContourDetectionSample : public SampleBase
{
public:
    ContourDetectionSample();

    //! Gets a sample name
    virtual std::string getName() const;
  
    virtual std::string getSampleIcon() const;
  
    //! Returns a detailed sample description
    virtual std::string getDescription() const;
    
    virtual bool isReferenceFrameRequired() const;
    
    //! Sets the reference frame for latter processing
    virtual void setReferenceFrame(const cv::Mat& reference);
    
    // clears reference frame parameters
    virtual void resetReferenceFrame() const;
    
    //! Processes a frame and returns output image 
    virtual bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame);

private:
    cv::Mat model, mask, subtracted, gray, edges;
    
    bool collectBackground, referenceSet;
    
    int collectBackgroundCounter;
    
};

#endif
