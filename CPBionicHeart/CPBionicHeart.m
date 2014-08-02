//
//  CPBionicHeart.m
//  TabataTimer2
//
//  Created by Cameron N Perry on 8/1/14.
//  Copyright (c) 2014 Cameron Perry. All rights reserved.
//

#import "CPBionicHeart.h"


/*
 Status of the Bionic Heart repeating timer
 Stopped = Not initialized, active
 Running = currently running & updating
 Paused = initialized, and skipping updates
 */
typedef NS_ENUM(NSUInteger, BionicHeartUpdateStatus){
    BionicHeartStatusStopped = 0,
    BionicHeartStatusRunning,
    BionicHeartStatusPaused,
};

@interface CPBionicHeart()

@property (nonatomic, readwrite) BionicHeartUpdateStatus status;
@property (nonatomic, readwrite) HKAuthorizationStatus permissions;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readwrite) double heartRate;


@end


@implementation CPBionicHeart


-(instancetype)init {
    if( !(self = [super init])){
        return nil;
    }

    self.status = BionicHeartStatusStopped;
    self.heartRate = 85.0;

    return self;
}

-(void)setUpHealthStore {
    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];

        self.permissions = [self authStatus];

        if(self.permissions == HKAuthorizationStatusNotDetermined){
            [self requestAuthorization];
        }
    }

}

-(HKAuthorizationStatus)authStatus {
    return [self.healthStore authorizationStatusForType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
}

-(void)requestAuthorization {

    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSet *permissionSet = [NSSet setWithObjects:heartRateType, nil];

    [self.healthStore requestAuthorizationToShareTypes:permissionSet readTypes:permissionSet completion:^(BOOL success, NSError *error){
        if(!success){
            NSLog(@"Warning - did you allow permission?");
        }

        self.permissions = [self authStatus];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.permissions == HKAuthorizationStatusSharingDenied){
                NSLog(@"Denied Access");
                [self.timer invalidate];
            }
        });
    }];

}

-(void)updateTime:(NSTimer *)timer {
    if(self.status != BionicHeartStatusRunning){
        return;
    }

    [self recordNewHeartRate:[self nextHeartRate]];
}

-(void)start {
    // Will create store and get permissions
    [self setUpHealthStore];

    if(!self.timer){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
    self.status = BionicHeartStatusRunning;

}

-(void)stop {
    self.status = BionicHeartStatusStopped;
    [self.timer invalidate];

}

-(void)recordNewHeartRate:(double)heartRate {
    self.heartRate = heartRate;

    if(self.permissions == HKAuthorizationStatusSharingAuthorized){
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

        HKQuantity *hr = [HKQuantity quantityWithUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]] doubleValue:self.heartRate];
        NSDate *date = [NSDate date];
        NSDictionary *metaData = @{ HKMetadataKeyDeviceName : @"BionicHeart" };
        HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:quantityType quantity:hr startDate:date endDate:date metadata:metaData];
        
        [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
            if(success ) {
                NSLog(@"Sample: %@",sample.quantity);
            }

            if(!success || error){
                if([self.delegate respondsToSelector:@selector(didSaveBeatSuccess:error:)]){
                    [self.delegate didSaveBeatSuccess:success error:error];
                    NSLog(@"Save Error: %@",[error localizedDescription]);
                }
            }

        }];

    }

}

-(void)setPermissions:(HKAuthorizationStatus)permissions {
    _permissions = permissions;
    if([self.delegate respondsToSelector:@selector(permissionsUpdated:)]){
        [self.delegate permissionsUpdated:permissions];
    }
}

-(double)nextHeartRate {
    NSInteger delta = arc4random()%3; // between zero and 2
    NSInteger plusMinus = arc4random()%2 ? -1 : 1;
    double nextHR = self.heartRate + (plusMinus * delta);

    if(nextHR <= MIN_HEART_RATE || nextHR >= MAX_HEART_RATE){
        nextHR = self.heartRate + -1*(plusMinus * delta);
    }
    return nextHR;
}

@end
