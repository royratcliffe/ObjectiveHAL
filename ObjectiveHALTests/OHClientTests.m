//
//  ObjectiveHAL - OHClientTests.m
//  Copyright (c) 2013 Mobile App Machine LLC. All rights reserved.
//
//  Created by: Bennett Smith
//

    // Class under test
#import "OHClient.h"

    // Collaborators
#import "OHLink.h"
#import "OHResource.h"

    // Test support
#import <SenTestingKit/SenTestingKit.h>
#import "NSData+TestInfected.h"

#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_WARN; // LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

// Uncomment the next two lines to use OCHamcrest for test assertions:
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

// Uncomment the next two lines to use OCMockito for mock objects:
//#define MOCKITO_SHORTHAND
//#import <OCMockitoIOS/OCMockitoIOS.h>

@interface OHClientTests : SenTestCase
@property (nonatomic, assign) BOOL done;
@end

@implementation OHClientTests
{
    // test fixture ivars go here
    NSURL *baseURL;
    OHClient *client;
    NSTimeInterval timeout;
}

+ (void)setUp
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogInfo(@"*** BEGINNING A TEST RUN ***");
}

+ (void)tearDown
{
    DDLogInfo(@"*** ENDING A TEST RUN ***");
}

- (void)setUp
{
    [super setUp];
    timeout = 30.0;
    baseURL = [NSURL URLWithString:@"http://localhost:7100"];
    client = [OHClient clientWithBaseURL:baseURL];
    self.done = NO;
}

- (void)tearDown
{
    baseURL = nil;
    client = nil;
    [super tearDown];
}

// assertThatBool([self waitForCompletion:90.0], is(equalToBool(YES)));
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.done);
    
    return self.done;
}

- (void)waitUntilChangeObservedForKey:(NSString *)key ofObject:(id)object
{
    [client addObserver:self forKeyPath:key options:0 context:NULL];
    [self waitForCompletion:timeout];
}


- (void)testFetchRootObject
{
    // given
    NSString *rootPath = @"apps";
    
    // when
    [client fetchRootObjectFromPath:rootPath];
    
    // then
    [self waitUntilChangeObservedForKey:@"rootObjectAvailable" ofObject:client];
    
    NSLog(@"rootObject = %@", client.rootObject);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rootObjectAvailable"]) {
        self.done = YES;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
