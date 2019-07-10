/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                        *
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

#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

// Model object representing a Decision Ticket sent when layer decision is made.

@class OPTLYEventHeader, OPTLYEventDecision, OPTLYEventDecisionTicket, OPTLYEventFeature;
@protocol OPTLYEventDecisionTicket, OPTLYEventFeature;

@interface OPTLYDecisionEventTicket : OPTLYJSONModel

//The time the decision was made.
@property (nonatomic, assign) long long timestamp;
// Revision of client DATA, corresponding to a stored snapshot
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *revision;
// Unique ID shared by all events in the current activation cycle
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *activationId;
// GUID ID uniquely identifying the decision event triggering
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *decisionId;
// GUID ID uniquely identifying the user’s current session
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *sessionId;
// Project ID of the decision.
@property (nonatomic, strong, nonnull) NSString *projectId;
// Account ID of the decision.
@property (nonatomic, strong, nonnull) NSString *accountId;
// The type of client engine sending this event: ‘ios’, ‘android’, ‘js’.
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *clientEngine;
// The version of the client engine sending this event.
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *clientVersion;
// Event information taken from the http header instead of the payload
@property (nonatomic, strong, nullable) OPTLYEventHeader<OPTLYOptional> *header;
// The layer affected by this decision
@property (nonatomic, strong, nonnull) NSString *layerId;
// Visitor-specific input to Client Decision Engine
@property (nonatomic, strong, nullable) NSArray<OPTLYEventDecisionTicket *><OPTLYEventDecisionTicket, OPTLYOptional> *decisionTicket;
// Output of the Client Decision Engine
@property (nonatomic, strong, nonnull) OPTLYEventDecision *decision;
// The ID of the user
@property (nonatomic, strong, nonnull) NSString *visitorId;
// The unique user ID of the user (if available)
@property (nonatomic, strong, nullable) NSString<OPTLYOptional> *visitorUUID;
// Features attached to the user
@property (nonatomic, strong, nonnull) NSArray<OPTLYEventFeature *><OPTLYEventFeature> *userFeatures;
// If true, then the experience in this decision was held back at the global level
@property (nonatomic, assign) BOOL isGlobalHoldback;
// If true, then anonymize IP.
@property (nonatomic) BOOL anonymizeIP;

@end
