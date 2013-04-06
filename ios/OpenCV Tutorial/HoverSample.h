//
//  HoverSample.h
//  OpenCV Tutorial
//

#ifndef OpenCV_Tutorial_HoverSample_h
#define OpenCV_Tutorial_HoverSample_h

#include "SampleBase.h"

struct ctx {
	CvCapture	*capture;	/* Capture handle */
	CvVideoWriter	*writer;	/* File recording handle */
    
	IplImage	*image;		/* Input image */
	IplImage	*thr_image;	/* After filtering and thresholding */
	IplImage	*temp_image1;	/* Temporary image (1 channel) */
	IplImage	*temp_image3;	/* Temporary image (3 channels) */
    
	CvSeq		*contour;	/* Hand contour */
	CvSeq		*hull;		/* Hand convex hull */
    
	CvPoint		hand_center;
	CvPoint		*fingers;	/* Detected fingers positions */
	CvPoint		*defects;	/* Convexity defects depth points */
    
	CvMemStorage	*hull_st;
	CvMemStorage	*contour_st;
	CvMemStorage	*temp_st;
	CvMemStorage	*defects_st;
    
	IplConvKernel	*kernel;	/* Kernel for morph operations */
    
	int		num_fingers;
	int		hand_radius;
	int		num_defects;
};

class HoverSample : public SampleBase
{
public:
    HoverSample();
    
    //! Gets a sample name
    virtual std::string getName() const;
    
    virtual std::string getSampleIcon() const;
    
    //! Returns a detailed sample description
    virtual std::string getDescription() const;
    
    //! Returns true if this sample requires setting a reference image for latter use
    virtual bool isReferenceFrameRequired() const;
    
    //! Sets the reference frame for latter processing
    virtual void setReferenceFrame(const cv::Mat& reference);
    
    // clears reference frame parameters
    virtual void resetReferenceFrame() const;
    
    //! Processes a frame and returns output image 
    virtual bool processFrame(const cv::Mat& inputFrame, cv::Mat& outputFrame);
    
private:
    cv::Mat imageNext, imagePrev;
    
    std::vector<uchar> status;
    
    std::vector<float> err;
    
    std::string m_algorithmName;
    
    cv::vector<cv::Point2f> pointsPrev, pointsNext;
    
    // optical flow options
    int m_maxCorners;
    
    ctx ctxStruct;
    
    void filter_and_threshold();
    void find_contour();
    void find_convex_hull();
    void find_fingers();
};

#endif
