//
//  HoverClass.h
//  OpenCV Tutorial
//

#ifndef OpenCV_Tutorial_HoverClass_h
#define OpenCV_Tutorial_HoverClass_h

class HoverClass
{
private:
    int maxCorners;
    double qualityLevel;
    double minDistance;
    int blockSize;
    bool useHarrisDetector;
    double k;
    cv::Size subPixWinSize, winSize;
    cv::TermCriteria termcrit;
    int maxLevel;
    int flags;
    double minEigThreshold;
    
public:
    HoverClass()
    : maxCorners(200)
    , qualityLevel(0.01)
    , minDistance(10)
    , blockSize(3)
    , useHarrisDetector(false)
    , subPixWinSize(10,10)
    , winSize(31,31)
    , termcrit(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03)
    , maxLevel(3)
    , flags(0)
    , minEigThreshold(0.001)
    
    {
        //  nothing to do for now
    }
    
    // set maxcorners
    void setMaxCorners(int maxCorners);
    
    // initialise tracker
    void init(cv::Mat& image, // output image
              cv::Mat& image1, // source image
              std::vector<cv::Point2f>& points1); // points array
    
    // track optical flow
    void track(cv::Mat& image, // output image
               cv::Mat& image1, // input image 1
               cv::Mat& image2, // input image 2
               std::vector<cv::Point2f>& points1, // points array 1
               std::vector<cv::Point2f>& points2, // points array 2
               cv::vector<uchar>& status, // status array
               cv::vector<float>& err); // error array
};

#endif
