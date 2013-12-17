#import "NSString+URIEncode_Decode.h"

@implementation NSString (URIEncode_Decode)
    
+ (NSString *)encodeURIComponent:(NSString *)baseString
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)baseString,
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8);
}

@end
