#import "NetImthinkerTiExtendnwHTTPClientProxy.h"
#import "TiBlob.h"
#import "TiUtils.h"
#import "TiDOMDocumentProxy.h"
#import "NSString+URIEncode_Decode.h"

#pragma mark Anonymous class extension
@interface NetImthinkerTiExtendnwHTTPClientProxy ()

#pragma mark Private properties
@property NSString *verb;
@property NSString *url;
@property BOOL forceReload;
@property NSMutableDictionary *requestHeaderDict;
@property NSDictionary *openOptions;
@property NSTimeInterval timeoutVal;
@property KrollCallback *onloadCallback;
@property KrollCallback *onerrorCallback;
@property KrollCallback *ondatastreamCallback;
@property KrollCallback *onsendstreamCallback;

#pragma mark Private methods
- (TiProxy *)_responseXML:(NSString *)baseResponseText;

@end

#pragma mark Implementation
@implementation NetImthinkerTiExtendnwHTTPClientProxy

- (void)open:(id)args
{
    DLog(@"Call open method");
    
    ENSURE_ARG_OR_NIL_AT_INDEX(self.verb, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(self.url, args, 1, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(self.openOptions, args, 2, NSDictionary);
    self.engine = [self sharedEngine];
    self.requestHeaderDict = [[NSMutableDictionary alloc] init];
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
    
    NSNumber *timeout;
    ENSURE_ARG_OR_NIL_AT_INDEX(timeout, args, 0, NSNumber);
    if (timeout) {
        self.timeoutVal = [timeout doubleValue] / 1000;
    } else {
        self.timeoutVal = 60.0;
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
                NSString *encodedString = [NSString encodeURIComponent:[TiUtils stringValue:args[key]]];
                [queryParameters addObject:[NSString stringWithFormat:@"%@=%@", key, encodedString]];
            }
            if ([queryParameters count] != 0) {
                NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
                NSString *newRequestURI = [self.url stringByAppendingFormat:@"?%@", queryString];
                self.operation = [self.engine operationWithURLString:newRequestURI params:nil httpMethod:self.verb];
            } else {
                self.operation = [self.engine operationWithURLString:self.url params:nil httpMethod:self.verb];
            }
        } else {
            self.operation = [self.engine operationWithURLString:self.url params:nil httpMethod:self.verb];
        }
    } else {
        self.operation = [self.engine operationWithURLString:self.url params:nil httpMethod:self.verb];
        
        if (args != nil) {
            for (id arg in args) {
                if ([arg isKindOfClass:[NSString class]]) {
                    // NSString
                    [self.operation addData:[(NSString *)arg dataUsingEncoding:NSUTF8StringEncoding] forKey:nil];
                    
                } else if ([arg isKindOfClass:[NSDictionary class]]) {
                    // Params mutable array
                    NSMutableArray *queryParameters = [NSMutableArray new];
                    // NSDictionary
                    for (id key in arg) {
                        id value = arg[key];
                        if ([value isKindOfClass:[TiBlob class]] || [value isKindOfClass:[TiFile class]]) {
                            // Blob
                            TiBlob *blob = [value isKindOfClass:[TiBlob class]] ? (TiBlob *)value : [(TiFile *)value blob];
                            if ([blob type] == TiBlobTypeFile) {
                                // File
                                [self.operation addFile:[blob path] forKey:key];
                            } else {
                                // Data
                                NSData *data = [blob data];
                                [self.operation addData:data forKey:key];
                            }
                            
                        } else {
                            // Other format (URIEncode)
                            NSString *encodedString = [NSString encodeURIComponent:[TiUtils stringValue:value]];
                            [queryParameters addObject:[NSString stringWithFormat:@"%@=%@", key, encodedString]];
                        }
                    }
                    if ([queryParameters count] != 0) {
                        __block NSString *query = [queryParameters componentsJoinedByString:@"&"];
                        [self.operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
                            return query;
                        } forType:@"application/x-www-form-urlencoded"];
                    }
                    
                } else if ([arg isKindOfClass:[TiBlob class]] || [arg isKindOfClass:[TiFile class]]) {
                    // TiBlob or TiFile
                    TiBlob *blob = [arg isKindOfClass:[TiBlob class]] ? (TiBlob *)arg : [(TiFile *)arg blob];
                    if ([blob type] == TiBlobTypeFile) {
                        // File
                        [self.operation addFile:[blob path] forKey:nil];
                    } else {
                        NSData *data = [blob data];
                        [self.operation addData:data forKey:nil];
                    }
                    
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
        [self.operation setTimeoutInterval:self.timeoutVal];
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

#pragma mark Singleton
- (MKNetworkEngine *)sharedEngine
{
    static MKNetworkEngine *engine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[MKNetworkEngine alloc] init];
        [engine useCache];
    });
    return engine;
}

@end
