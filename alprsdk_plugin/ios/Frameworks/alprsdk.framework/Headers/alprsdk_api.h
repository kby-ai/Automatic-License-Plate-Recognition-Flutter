//#include <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#if TARGET_OS_IOS
NS_ASSUME_NONNULL_BEGIN

enum SDK_ERROR
{
    SDK_SUCCESS = 0,
    SDK_LICENSE_KEY_ERROR = -1,
    SDK_LICENSE_APPID_ERROR = -2,
    SDK_LICENSE_EXPIRED = -3,
    SDK_NO_ACTIVATED = -4,
    SDK_INIT_ERROR = -5,
};

@interface ALPRBox : NSObject

@property (nonatomic) int x1;
@property (nonatomic) int y1;
@property (nonatomic) int x2;
@property (nonatomic) int y2;
@property (nonatomic, strong) NSString *number;
@property (nonatomic) float score;
@end

@interface ALPRSDK : NSObject

+(int) setActivation: (NSString*) license;
+(int) initSDK;
+(NSMutableArray*) processImage: (UIImage*) image;

@end

NS_ASSUME_NONNULL_END

//#endif
