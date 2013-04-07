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
    
    ctxStruct = (ctx*)malloc(sizeof(ctx));
    firstTime = 1;
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
//    // display the frame
//    inputFrame.copyTo(outputFrame);
//    
//    // convert input frame to gray scale
//    getGray(inputFrame, imageNext);
//    
//    // prepare the tracking class
//    HoverClass ot;
//    ot.setMaxCorners(m_maxCorners);
//    
//    // begin tracking object
//    if ( trackObject ) {
//        ot.track(outputFrame,
//                 imagePrev,
//                 imageNext,
//                 pointsPrev,
//                 pointsNext,
//                 status,
//                 err);
//        
//        // check if the next points array isn't empty
//        if ( pointsNext.empty() )
//            trackObject = false;
//    }
//       
//    // store the reference frame as the object to track
//    if ( computeObject ) {
//        ot.init(outputFrame, imagePrev, pointsNext);
//        trackObject = true;
//        computeObject = false;
//    }
//    
//    // backup previous frame
//    imageNext.copyTo(imagePrev);
//    
//    // backup points array
//    std::swap(pointsNext, pointsPrev);
    
    
    
    //////////////////////////////////////////////////
    
    

    // convert inputFrame into IplImage
    ctxStruct->image = new IplImage(inputFrame);
    
    
    // maybe we dont have to do this every frame???
    if (firstTime == 1) {
//        ctxStruct->thr_image = cvCreateImage(cvGetSize(ctxStruct->image), 8, 1);
//        ctxStruct->temp_image1 = cvCreateImage(cvGetSize(ctxStruct->image), 8, 1);
//        ctxStruct->temp_image3 = cvCreateImage(cvGetSize(ctxStruct->image), 8, 3);
                
        ctxStruct->thr_image = cvCreateImage(cvGetSize(ctxStruct->image), 8, 1);
        ctxStruct->temp_image1 = cvCreateImage(cvGetSize(ctxStruct->image), ctxStruct->image->depth, 1);
        ctxStruct->temp_image3 = cvCreateImage(cvGetSize(ctxStruct->image), 8,ctxStruct->image->nChannels);
        
        
        ctxStruct->kernel = cvCreateStructuringElementEx(9, 9, 4, 4, CV_SHAPE_RECT, NULL);
        ctxStruct->contour_st = cvCreateMemStorage(0);
        ctxStruct->hull_st = cvCreateMemStorage(0);
        ctxStruct->temp_st = cvCreateMemStorage(0);
        ctxStruct->fingers = (CvPoint *)calloc(NUM_FINGERS + 1, sizeof(CvPoint));
        ctxStruct->defects = (CvPoint *)calloc(NUM_DEFECTS, sizeof(CvPoint));
        firstTime = 0;
    }
    
    // magic
    filter_and_threshold();
    find_contour();
    find_convex_hull();
    find_fingers();
    
    // display
    display();
    
    inputFrame.copyTo(outputFrame);

    
    //cvWriteFrame(ctx.writer, ctx.image);
    
    return true;
}

void HoverSample::filter_and_threshold() const
{
	/* Soften image */
	cvSmooth(ctxStruct->image, ctxStruct->temp_image3, CV_GAUSSIAN, 11, 11, 0, 0);
	/* Remove some impulsive noise */
	cvSmooth(ctxStruct->temp_image3, ctxStruct->temp_image3, CV_MEDIAN, 11, 11, 0, 0);
    
    
	//cvCvtColor(ctxStruct->temp_image3, ctxStruct->temp_image3, CV_BGR2HSV);
    
	/*
	 * Apply threshold on HSV values
	 * Threshold values should be customized according to environment
	 */
	cvInRangeS(ctxStruct->temp_image3,
               cvScalar(0, 0, 160, 0),
               cvScalar(255, 400, 300, 255),
               ctxStruct->thr_image);
    
	/* Apply morphological opening */
	cvMorphologyEx(ctxStruct->thr_image, ctxStruct->thr_image, NULL, ctxStruct->kernel,
                   CV_MOP_OPEN, 1);
	cvSmooth(ctxStruct->thr_image, ctxStruct->thr_image, CV_GAUSSIAN, 3, 3, 0, 0);
}

void HoverSample::find_contour() const
{
//    double area, max_area = 0.0;
//	CvSeq *contours, *tmp, *contour = NULL;
//    
//	/* cvFindContours modifies input image, so make a copy */
//	cvCopy(ctxStruct->thr_image, ctxStruct->temp_image1, NULL);
//	cvFindContours(ctxStruct->temp_image1, ctxStruct->temp_st, &contours,
//                   sizeof(CvContour), CV_RETR_EXTERNAL,
//                   CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
//    
//	/* Select contour having greatest area */
//	for (tmp = contours; tmp; tmp = tmp->h_next) {
//		area = fabs(cvContourArea(tmp, CV_WHOLE_SEQ, 0));
//		if (area > max_area) {
//			max_area = area;
//			contour = tmp;
//		}
//	}
//    
//	/* Approximate contour with poly-line */
//	if (contour) {
//		contour = cvApproxPoly(contour, sizeof(CvContour),
//                               ctxStruct->contour_st, CV_POLY_APPROX_DP, 2,
//                               1);
//		ctxStruct->contour = contour;
//	}
    
    
}

void HoverSample::find_convex_hull() const
{
    CvSeq *defects;
	CvConvexityDefect *defect_array;
	int i;
	int x = 0, y = 0;
	int dist = 0;
    
	ctxStruct->hull = NULL;
    
	if (!ctxStruct->contour)
		return;
    
	ctxStruct->hull = cvConvexHull2(ctxStruct->contour, ctxStruct->hull_st, CV_CLOCKWISE, 0);
    
	if (ctxStruct->hull) {
        
		/* Get convexity defects of contour w.r.t. the convex hull */
		defects = cvConvexityDefects(ctxStruct->contour, ctxStruct->hull,
                                     ctxStruct->defects_st);
        
		if (defects && defects->total) {
			defect_array = (CvConvexityDefect *)calloc(defects->total,
                                  sizeof(CvConvexityDefect));
			cvCvtSeqToArray(defects, defect_array, CV_WHOLE_SEQ);
            
			/* Average depth points to get hand center */
			for (i = 0; i < defects->total && i < NUM_DEFECTS; i++) {
				x += defect_array[i].depth_point->x;
				y += defect_array[i].depth_point->y;
                
				ctxStruct->defects[i] = cvPoint(defect_array[i].depth_point->x,
                                          defect_array[i].depth_point->y);
			}
            
			x /= defects->total;
			y /= defects->total;
            
			ctxStruct->num_defects = defects->total;
			ctxStruct->hand_center = cvPoint(x, y);
            
			/* Compute hand radius as mean of distances of
             defects' depth point to hand center */
			for (i = 0; i < defects->total; i++) {
				int d = (x - defect_array[i].depth_point->x) *
                (x - defect_array[i].depth_point->x) +
                (y - defect_array[i].depth_point->y) *
                (y - defect_array[i].depth_point->y);
                
				dist += sqrt(d);
			}
            
			ctxStruct->hand_radius = dist / defects->total;
			free(defect_array);
		}
	}
}

void HoverSample::find_fingers() const
{
    int n;
	int i;
	CvPoint *points;
	CvPoint max_point;
	int dist1 = 0, dist2 = 0;
	int finger_distance[NUM_FINGERS + 1];
    
	ctxStruct->num_fingers = 0;
    
	if (!ctxStruct->contour || !ctxStruct->hull)
		return;
    
	n = ctxStruct->contour->total;
	points = (CvPoint *)calloc(n, sizeof(CvPoint));
    
	cvCvtSeqToArray(ctxStruct->contour, points, CV_WHOLE_SEQ);
    
	/*
	 * Fingers are detected as points where the distance to the center
	 * is a local maximum
	 */
	for (i = 0; i < n; i++) {
		int dist;
		int cx = ctxStruct->hand_center.x;
		int cy = ctxStruct->hand_center.y;
        
		dist = (cx - points[i].x) * (cx - points[i].x) +
        (cy - points[i].y) * (cy - points[i].y);
        
		if (dist < dist1 && dist1 > dist2 && max_point.x != 0
		    && max_point.y < cvGetSize(ctxStruct->image).height - 10) {
            
			finger_distance[ctxStruct->num_fingers] = dist;
			ctxStruct->fingers[ctxStruct->num_fingers++] = max_point;
			if (ctxStruct->num_fingers >= NUM_FINGERS + 1)
				break;
		}
        
		dist2 = dist1;
		dist1 = dist;
		max_point = points[i];
	}
    
	free(points);
}

void HoverSample::display() const
{
    int i;
    
	if (ctxStruct->num_fingers == NUM_FINGERS) {
        
        
        
#if defined(SHOW_HAND_CONTOUR)
		cvDrawContours(ctx->image, ctx->contour,
                       CV_RGB(0,0,255), CV_RGB(0,255,0),
                       0, 1, CV_AA, cvPoint(0,0));
#endif
        
        
		cvCircle(ctxStruct->image, ctxStruct->hand_center, 5, CV_RGB(255, 0, 255),
                 1, CV_AA, 0);
		cvCircle(ctxStruct->image, ctxStruct->hand_center, ctxStruct->hand_radius,
                 CV_RGB(255, 0, 0), 1, CV_AA, 0);
        
		for (i = 0; i < ctxStruct->num_fingers; i++) {
            
			cvCircle(ctxStruct->image, ctxStruct->fingers[i], 10,
                     CV_RGB(0, 255, 0), 3, CV_AA, 0);
            
			cvLine(ctxStruct->image, ctxStruct->hand_center, ctxStruct->fingers[i],
			       CV_RGB(255,255,0), 1, CV_AA, 0);
		}
        
		for (i = 0; i < ctxStruct->num_defects; i++) {
			cvCircle(ctxStruct->image, ctxStruct->defects[i], 2,
                     CV_RGB(200, 200, 200), 2, CV_AA, 0);
		}
	}
    
//	cvShowImage("output", ctxStruct->image);
//	cvShowImage("thresholded", ctxStruct->thr_image);
}

