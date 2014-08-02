//
//  CPBionicHeart.h
//  TabataTimer2
//
//  Created by Cameron N Perry on 8/1/14.
//  Copyright (c) 2014 Cameron Perry. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

#define MIN_HEART_RATE 60.0
#define MAX_HEART_RATE 150.0
#define STARTING_HEART_RATE 85.0

@protocol CPBionicHeart <NSObject>

@optional
-(void)permissionsUpdated:(HKAuthorizationStatus)status;
-(void)didSaveBeat:(HKSample*)sample success:(BOOL)success error:(NSError *)error;

@end

@interface CPBionicHeart : NSObject

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, weak) id <CPBionicHeart>delegate;

-(void)start;
-(void)stop;

@end
