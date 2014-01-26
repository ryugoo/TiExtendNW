#import "NetImthinkerTiExtendnwHTTPClientProxy.h"
#import "TiBlob.h"
#import "TiUtils.h"
#import "TiDOMDocumentProxy.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "NSData+MKBase64.h"
#import "NSDictionary+RequestEncoding.h"

#pragma mark Anonymous class extension
@interface NetImthinkerTiExtendnwHTTPClientProxy ()

#pragma mark Private properties
@property (nonatomic, copy) NSString *verb;
@property (nonatomic, copy) NSString *url;
@property (nonatomic) BOOL forceReload;
@property (nonatomic) NSMutableDictionary *requestHeaderDict;
@property (nonatomic, copy) NSDictionary *openOptions;
@property (nonatomic) NSTimeInterval timeoutVal;
@property (nonatomic) KrollCallback *onloadCallback;
@property (nonatomic) KrollCallback *onerrorCallback;
@property (nonatomic) KrollCallback *oncancelCallback;
@property (nonatomic) KrollCallback *ondatastreamCallback;
@property (nonatomic) KrollCallback *onsendstreamCallback;

#pragma mark Private methods
- (TiProxy *)_responseXML:(NSString *)baseResponseText;
- (void)_createNetworkOperation;
- (void)_createNetworkOperation:(NSString *)uri;

@end

#pragma mark Implementation
@implementation NetImthinkerTiExtendnwHTTPClientProxy

- (void)abort:(id)args
{
    [self.operation cancel];
    if ([self.operation isCancelled] && self.onerrorCallback != nil) {
        NSDictionary *cancelObject = @{@"error": @"cancel",
                                       @"cencel": @YES,
                                       @"success": @NO};
        [self _fireEventToListener:@"oncancel"
                        withObject:cancelObject
                          listener:self.oncancelCallback
                        thisObject:nil];
    }
}

- (void)open:(id)args
{
    DLog(@"Call open method");
    
    ENSURE_ARG_OR_NIL_AT_INDEX(self.verb, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(self.url, args, 1, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(self.openOptions, args, 2, NSDictionary);
    self.engine = [self sharedEngine];
    self.requestHeaderDict = [NSMutableDictionary new];
}

- (void)setOnload:(KrollCallback *)callback
{
    DLog(@"Call onload method");
    
    self.onloadCallback = callback;
}

- (void)setOnerror:(KrollCallback *)callback
{
    DLog(@"Call onerror method");
    
    self.onerrorCallback = callback;
}

- (void)setOncancel:(KrollCallback *)callback
{
    DLog(@"Call oncancel method");
    
    self.oncancelCallback = callback;
}

- (void)setOndatastream:(KrollCallback *)callback
{
    DLog(@"Call ondatastream method");
    
    self.ondatastreamCallback = callback;
}

- (void)setOnsendstream:(KrollCallback *)callback
{
    DLog(@"Call onsendstream method");
    
    self.onsendstreamCallback = callback;
}

- (void)setRequestHeader:(id)args
{
    DLog(@"Call requestheader method");
    
    NSString *key;
    NSString *value;
    ENSURE_ARG_OR_NIL_AT_INDEX(key, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(value, args, 1, NSString);
    [self.requestHeaderDict setObject:value forKey:key];
}

- (void)setTimeout:(id)args
{
    DLog(@"Call timeout method");
    
    NSNumber *timeout = [args copy];
    if (timeout) {
        self.timeoutVal = [timeout doubleValue] / 1000;
        DLog(@"Timeout val is user defined : %@ [s]", @(self.timeoutVal));
    } else {
        DLog(@"Timeout val is default : 60 [s]");
        self.timeoutVal = 60.0;
    }
}

- (void)setCache:(id)args
{
    DLog(@"Call cache method");
    
    BOOL useCache = [TiUtils boolValue:args def:NO];
    if (useCache) {
        DLog(@"Enable MKNetworkEngine cache");
        [self.engine useCache];
    }
}

- (void)setEnableKeepAlive:(id)args
{
    DLog(@"Call enableKeepAlive method");
    
    BOOL enableKeepAlive = [TiUtils boolValue:args def:NO];
    if (enableKeepAlive) {
        DLog(@"Enable MKNetworkEngine KeepAlive");
        [self.requestHeaderDict setObject:@"Keep-Alive" forKey:@"Connection"];
    }
}

- (void)send:(id)args
{
    DLog(@"Call send method");
    
    // Weak reference self object for blocks
    __block NetImthinkerTiExtendnwHTTPClientProxy *weakself = self;
    
    // Prepare send parameter
    if ([[self.verb uppercaseString] isEqualToString:@"GET"]) {
        ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
        if (args != nil) {
            NSMutableArray *queryParameters = [NSMutableArray new];
            for (id key in args) {
                NSString *encodedString = [[TiUtils stringValue:args[key]] mk_urlEncodedString];
                [queryParameters addObject:[NSString stringWithFormat:@"%@=%@", key, encodedString]];
            }
            if ([queryParameters count] != 0) {
                NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
                NSString *newRequestURI = [self.url stringByAppendingFormat:@"?%@", queryString];
                [self _createNetworkOperation:newRequestURI];
            } else {
                [self _createNetworkOperation];
            }
        } else {
            [self _createNetworkOperation];
        }
    } else {
        [self _createNetworkOperation];
        
        if (args != nil) {
            for (id arg in args) {
                if ([arg isKindOfClass:[NSString class]]) {
                    // NSString
                    [self.operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                        return arg;
                    } forType:@"application/x-www-form-urlencoded"];
                } else if ([arg isKindOfClass:[NSDictionary class]]) {
                    // Params mutable array
                    NSMutableDictionary *postParameters = [[NSMutableDictionary alloc] init];

                    // Construct parameters
                    for (NSString *key in arg) {
                        id value = arg[key];

                        // TiBlob or TiFile
                        if ([value isKindOfClass:[TiBlob class]] || [value isKindOfClass:[TiFile class]]) {
                            TiBlob *blob = [value isKindOfClass:[TiBlob class]] ? (TiBlob *)value : [(TiFile *)value blob];
                            [self.operation addData:[blob data] forKey:key];
                        } else {
                            [postParameters setObject:value forKey:key];
                        }
                    }
                    
                    // Set message body
                    [self.operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                        return [postParameters urlEncodedKeyValueString];
                    } forType:@"application/x-www-form-urlencoded"];
                } else if ([arg isKindOfClass:[TiBlob class]] || [arg isKindOfClass:[TiFile class]]) {
                    // TiBlob or TiFile
                    TiBlob *blob = [arg isKindOfClass:[TiBlob class]] ? (TiBlob *)arg : [(TiFile *)arg blob];
                    NSString *base64EncodedDataString = [blob.data base64EncodedString];
                    [self.operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                        return base64EncodedDataString;
                    } forType:@"application/octet-stream"];
                }
            }
        }
    }
    
    // Options
    if (self.openOptions) {
        // Freezable
        if (self.openOptions[@"freezable"] && [self.openOptions[@"freezable"] isKindOfClass:[NSNumber class]]) {
            [self.operation setFreezable:[TiUtils boolValue:self.openOptions[@"freezable"] def:NO]];
        } else {
            [self.operation setFreezable:NO];
        }
        
        // Force reload
        if (self.openOptions[@"forceReload"] && [self.openOptions[@"forceReload"] isKindOfClass:[NSNumber class]]) {
            self.forceReload = [TiUtils boolValue:self.openOptions[@"forceReload"] def:NO];
        } else {
            self.forceReload = NO;
        }
    }
    
    // Set request header
    if ([self.requestHeaderDict count] != 0) {
        for (NSString *key in [self.requestHeaderDict keyEnumerator]) {
            NSString *value = [self.requestHeaderDict valueForKey:key];
            [self.operation addHeader:key withValue:value];
        }
    }
    
    // Set timeout
    if (self.timeoutVal) {
        DLog(@"Exist user defined timeout value");
        [self.operation setTimeoutInterval:self.timeoutVal];
        DLog(@"This operation's timeout value is %@ [s]", @(self.operation.timeoutInterval));
    }
    
    // Set ondatastream / onsendstream hander
    if (self.ondatastreamCallback != nil) {
        [self.operation onDownloadProgressChanged:^(double progress) {
            [weakself _fireEventToListener:@"ondatastream"
                                withObject:@{@"progress": NUMDOUBLE(progress)}
                                  listener:weakself.ondatastreamCallback
                                thisObject:nil];
        }];
    }
    if (self.onsendstreamCallback != nil) {
        [self.operation onUploadProgressChanged:^(double progress) {
            [weakself _fireEventToListener:@"onsendstream"
                                withObject:@{@"progress": NUMDOUBLE(progress)}
                                  listener:weakself.onsendstreamCallback
                                thisObject:nil];
        }];
    }
    
    // Set onload / onerror hander
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        // Success
        if (weakself.onloadCallback != nil) {
            NSDictionary *successResponse = @{@"error": @"",
                                              @"code": @(completedOperation.HTTPStatusCode),
                                              @"success": @YES};
            
            // Set response code
            [weakself setValue:@(completedOperation.HTTPStatusCode) forUndefinedKey:@"status"];
            [weakself setValue:[@(completedOperation.HTTPStatusCode) stringValue] forUndefinedKey:@"statusText"];
            
            // Set response headers
            NSDictionary *headers = completedOperation.readonlyResponse.allHeaderFields;
            [weakself setValue:headers forUndefinedKey:@"allResponseHeaders"];
            
            // Set response objects
            if (completedOperation.responseData != nil) {
                // Content-Type
                NSString *contentType;
                if (headers[@"Content-Type"]) {
                    contentType = headers[@"Content-Type"];
                } else {
                    contentType = @"application/octet-stream";
                }
                TiBlob *blob = [[TiBlob alloc] initWithData:completedOperation.responseData mimetype:contentType];
                [weakself setValue:completedOperation.responseData forUndefinedKey:@"responseRawData"];
                [weakself setValue:blob forUndefinedKey:@"responseData"];
            }
            if (completedOperation.responseString != nil) {
                [weakself setValue:completedOperation.responseString forUndefinedKey:@"responseText"];
                
                NSString *xmlSubString = [[completedOperation.responseString substringToIndex:5] lowercaseString];
                if ([xmlSubString isEqualToString:@"<?xml"]) {
                    [weakself setValue:[weakself _responseXML:completedOperation.responseString] forUndefinedKey:@"responseXML"];
                } else {
                    [weakself setValue:(id)[NSNull null] forUndefinedKey:@"responseXML"];
                }
            }
            if (completedOperation.responseJSON != nil) {
                [weakself setValue:completedOperation.responseJSON forUndefinedKey:@"responseJSON"];
            }
            
            // Onload callback
            [weakself _fireEventToListener:@"onload"
                                withObject:successResponse
                                  listener:weakself.onloadCallback
                                thisObject:nil];
        } else {
            DLog(@"Missing onload callback");
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        // Error
        if (weakself.onerrorCallback != nil) {
            NSDictionary *errorResponse = @{@"error": [error localizedDescription],
                                            @"code": @(completedOperation.HTTPStatusCode),
                                            @"success": @NO};
            // Onerror callback
            [weakself _fireEventToListener:@"onerror"
                                withObject:errorResponse
                                  listener:weakself.onerrorCallback
                                thisObject:nil];
        } else {
            DLog(@"Missing onerror callback");
        }
        
    }];
    
    // Start request operation
    [self.engine enqueueOperation:self.operation forceReload:self.forceReload];
}

#pragma mark Private methods
- (TiProxy *)_responseXML:(NSString *)baseResponseText
{
    if (baseResponseText != nil && (![baseResponseText isEqual:(id)[NSNull null]])) {
        TiDOMDocumentProxy *dom = [[TiDOMDocumentProxy alloc] _initWithPageContext:[self executionContext]];
        @try {
            [dom parseString:baseResponseText];
        }
        @catch (NSException *exception) {
            return (id)[NSNull null];
        }
        return dom;
    }
    return (id)[NSNull null];
}

- (void)_createNetworkOperation
{
    self.operation = [self.engine operationWithURLString:self.url
                                                  params:nil
                                              httpMethod:self.verb];
    [self.operation setShouldContinueWithInvalidCertificate:YES];
}

- (void)_createNetworkOperation:(NSString *)uri
{
    self.operation = [self.engine operationWithURLString:uri
                                                  params:nil
                                              httpMethod:self.verb];
    [self.operation setShouldContinueWithInvalidCertificate:YES];
}

#pragma mark Singleton
- (MKNetworkEngine *)sharedEngine
{
    static MKNetworkEngine *engine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[MKNetworkEngine alloc] init];
    });
    return engine;
}

@end
