#import "TiProxy.h"
#import "MKNetworkKit.h"

@interface NetImthinkerTiExtendnwHTTPClientProxy : TiProxy

#pragma mark Properties
@property (nonatomic) MKNetworkEngine *engine;
@property (nonatomic) MKNetworkOperation *operation;

#pragma mark Methods
- (void)abort:(id)args;
- (void)open:(id)args;
- (void)setOnload:(KrollCallback *)callback;
- (void)setOnerror:(KrollCallback *)callback;
- (void)setOncancel:(KrollCallback *)callback;
- (void)setOndatastream:(KrollCallback *)callback;
- (void)setOnsendstream:(KrollCallback *)callback;
- (void)setRequestHeader:(id)args;
- (void)setTimeout:(id)args;
- (void)setCache:(id)args;
- (void)setEnableKeepAlive:(id)args;
- (void)send:(id)args;

@end
