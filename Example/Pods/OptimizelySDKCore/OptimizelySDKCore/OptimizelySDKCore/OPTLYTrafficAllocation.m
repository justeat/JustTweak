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

#import "OPTLYTrafficAllocation.h"
#import "OPTLYErrorHandlerMessages.h"

static const NSInteger kMinTrafficAllocationValue = 0;
static const NSInteger kMaxTrafficAllocationValue = 10000;

@implementation OPTLYTrafficAllocation

- (BOOL)validate:(NSError * __autoreleasing *)error {
    BOOL valid = [super validate:error];
    
    if ((self.endOfRange > kMaxTrafficAllocationValue) ||
        (self.endOfRange < kMinTrafficAllocationValue))
    {
        if (*error != nil) {
            *error = [OPTLYJSONModelError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                code:OPTLYErrorTypesDatafileInvalid
                                            userInfo:@{NSLocalizedDescriptionKey :
                                                           [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesTrafficAllocationNotInRange, nil), self.endOfRange]}];

        }
        valid = NO;
    }
    
    return valid;
}

@end
