/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

#import "murmur3.h"
#import "OPTLYBucketer.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTrafficAllocation.h"
#import "OPTLYVariation.h"

NSString *const OPTLYBucketerMutexPolicy = @"random";
NSString *const OPTLYBucketerOverlappingPolicy = @"overlapping";

int const MAX_TRAFFIC_VALUE = 10000;
int const HASH_SEED = 1;
uint64_t const MAX_HASH_VALUE = ((uint64_t)1) << 32;
NSString *const BUCKETING_ID_TEMPLATE = @"%@%@"; // "<user_id><experiment_id>"


@interface OPTLYBucketer ()

@property (readonly) int bucket_seed;
@property (readonly, strong) OPTLYProjectConfig *config;

@end

@implementation OPTLYBucketer

- (id)init {
    @try {
        NSAssert(NO, @"Use initWithConfig:");
    } @catch (NSException *exception) {
    } @finally {
        return nil;
    }
}

- (instancetype)initWithConfig:(OPTLYProjectConfig *)config {
    self = [super init];
    if (self != nil) {
        _bucket_seed = HASH_SEED;
        _config = config;
    }
    return self;
}

- (OPTLYVariation *)bucketExperiment:(OPTLYExperiment *)experiment
                          withBucketingId:(NSString *)bucketingId {
    BOOL ok = YES;
    // check for mutex
    NSString *groupId = experiment.groupId;
    if (groupId != nil) {
        OPTLYGroup *group = [self.config getGroupForGroupId:groupId];
        if (group == nil) {
            ok = NO;
        }
        else if ([group.policy isEqualToString:OPTLYBucketerOverlappingPolicy]) {
            // do nothing if it is overlapping policy
        }
        else if ([group.policy isEqualToString:OPTLYBucketerMutexPolicy]) {
            OPTLYExperiment *mutexExperiment = [self bucketToExperiment:group withBucketingId:bucketingId];
            if (mutexExperiment != experiment) { // check to see if the experiment the user should fall into is the same experiment we are bucketing
                ok = NO;
            }
        }
        else {
            ok = NO;
        }
    }
    
    // bucket to variation only if experiment passes Mutex check
    if (ok) {
        OPTLYVariation *variation = [self bucketToVariation:experiment withBucketingId:bucketingId];
        return variation;
    }
    else {
        // log message if the user is mutually excluded
        NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesUserMutuallyExcluded, bucketingId, experiment.experimentKey, groupId];
        [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        return nil;
    }
}

- (OPTLYExperiment *)bucketToExperiment:(OPTLYGroup *)group withBucketingId:(NSString *)bucketingId {
    NSString *hashId = [self makeHashIdFromBucketingId:bucketingId andEntityId:group.groupId];
    int bucketValue = [self generateBucketValue:hashId];
    
    if ([group.trafficAllocations count] == 0) {
        // log error if there are no traffic allocation values
        [OPTLYErrorHandler handleError:self.config.errorHandler
                                  code:OPTLYErrorTypesDataUnknown
                           description:NSLocalizedString(OPTLYErrorHandlerMessagesTrafficAllocationUnknown, group.groupId)];
        return nil;
    }
    
    for (OPTLYTrafficAllocation *trafficAllocation in group.trafficAllocations) {
        if (bucketValue <= trafficAllocation.endOfRange) {
            NSString *experimentId = trafficAllocation.entityId;
            OPTLYExperiment *experiment = [self.config getExperimentForId:experimentId];
            
            // propagate errors and logs for unknown experiment
            if (!experiment)
            {
                [OPTLYErrorHandler handleError:self.config.errorHandler
                                          code:OPTLYErrorTypesDataUnknown
                                   description:NSLocalizedString(OPTLYErrorHandlerMessagesExperimentUnknown, experimentId)];
                
                NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesForcedBucketingFailed, experimentId, bucketingId];
                [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
            }
            return experiment;
        }
    }
    
    // log error if invalid bucketing id
    [OPTLYErrorHandler handleError:self.config.errorHandler
                              code:OPTLYErrorTypesDatafileInvalid
                       description:NSLocalizedString(OPTLYErrorHandlerMessagesBucketingIdInvalid, bucketValue)];
    
    return nil;
}

- (OPTLYVariation *)bucketToVariation:(OPTLYExperiment *)experiment withBucketingId: (NSString *)bucketingId {
    NSString *hashId = [self makeHashIdFromBucketingId:bucketingId andEntityId:experiment.experimentId];
    int bucketValue = [self generateBucketValue:hashId];
    
    if ([experiment.trafficAllocations count] == 0) {
        // log error if there are no traffic allocation values
        NSString *logErrorMessage = NSLocalizedString(OPTLYErrorHandlerMessagesTrafficAllocationUnknown, experimentId);
        [OPTLYErrorHandler handleError:self.config.errorHandler
                                  code:OPTLYErrorTypesDataUnknown
                           description:logErrorMessage];
        [self.config.logger logMessage:logErrorMessage withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    for (OPTLYTrafficAllocation *trafficAllocation in experiment.trafficAllocations) {
        if (bucketValue <= trafficAllocation.endOfRange) {
            
            NSString *variationId = trafficAllocation.entityId;
            OPTLYVariation *variation = [experiment getVariationForVariationId:variationId];
            
            // propagate errors and logs for unknown variation
            if (!variation) {
                [OPTLYErrorHandler handleError:self.config.errorHandler
                                          code:OPTLYErrorTypesDataUnknown
                                   description:NSLocalizedString(OPTLYErrorHandlerMessagesVariationUnknown, variationId)];
                
                NSString *variationUnknownMessage = [NSString stringWithFormat:OPTLYLoggerMessagesForcedBucketingFailed, variationId, bucketingId];
                [self.config.logger logMessage:variationUnknownMessage withLevel:OptimizelyLogLevelError];
            }
            else {
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesBucketAssigned, variation.variationKey, bucketingId];
                [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            }
            return variation;
        }
    }
    
    // log error if invalid bucketing id
    [OPTLYErrorHandler handleError:self.config.errorHandler
                              code:OPTLYErrorTypesDatafileInvalid
                       description:NSLocalizedString(OPTLYErrorHandlerMessagesBucketingIdInvalid, bucketValue)];
    
    return nil;
}

- (int)generateBucketValue:(NSString *)hashId {
    double ratio = ((double) [self generateUnsignedHashCode32Bit:hashId] / (double) MAX_HASH_VALUE);
    return ratio * MAX_TRAFFIC_VALUE;
}

- (uint32_t)generateUnsignedHashCode32Bit:(NSString *)hashId {
    const char *str = [hashId UTF8String];
    int len = (int)[hashId length];
    uint32_t result = 0;
    MurmurHash3_x86_32(str, len, self.bucket_seed, &result);
    return result;
}

- (NSString *)makeHashIdFromBucketingId:(NSString *)bucketingId andEntityId:(NSString *)entityId {
    return [NSString stringWithFormat:BUCKETING_ID_TEMPLATE, bucketingId, entityId];
}

@end
