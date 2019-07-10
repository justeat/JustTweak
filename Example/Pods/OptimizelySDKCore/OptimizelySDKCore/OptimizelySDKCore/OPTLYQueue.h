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

#import <Foundation/Foundation.h>

/*
 This is a simple queue implementation that takes in a max size (or provides a default max size of 1000).
 A queue follows a FIFO (First In First Out) policy, so the the oldest item gets dequeued first.
 */
extern const NSInteger OPTLYQueueDefaultMaxSize;

@interface OPTLYQueue : NSObject

/// the queue
@property (nonatomic, strong) NSArray *queue;
/// the maximum size of the queue
@property (nonatomic, assign) NSInteger maxQueueSize;

/*
 * Initializes the queue with a max size.
 *
 * @param maxQueueSize The max queue size.
 * @return An instance of the queue.
 */
- (instancetype)initWithQueueSize:(NSInteger)maxQueueSize;

/**
 * Add data to the queue.
 *
 * @param data The data to put in the queue.
 * @return Boolean value if the enqueue was successful.
 */
- (bool)enqueue:(id)data;

/**
 * Returns and removes the oldest item in the queue (the queue is mutated).
 *
 * @return The oldest item from the queue.
 */
- (id)dequeue;

/**
 * Returns and removes the oldest N item in the queue (the queue is mutated).
 *
 * @param numberOfItems The number of itmes to remove.
 * @return The oldest N items from the queue.
 */
- (NSArray *)dequeueNItems:(NSInteger)numberOfItems;

/**
 * Removes an item from the queue
 *
 * @param item The item to be removed.
 */
- (void)removeItem:(id)item;

/**
 * Returns a copy of the oldest item in the queue (the queue is not mutated).
 *
 * @return A copy of the oldest item in the queue.
 */
- (id)front;

/**
 * Returns an index of the latest item in the queue (the queue is not mutated).
 *
 * @return An index of the latest item in the queue.
 */
- (NSInteger)lastItemIndex;

/**
 * Returns a copy of the oldest N items in the queue (the queue is not mutated).
 *
 * @return An array with a copy of the oldest N items in the queue.
 */
- (NSArray *)firstNItems:(NSInteger)numberOfItems;

/**
 * Gets the size of the queue.
 *
 * @return The size of the queue.
 */
- (NSInteger)size;

/**
 * Checks if the queue is full.
 *
 * @return A boolean that states whter the queue is full or not.
 */
- (bool)isFull;

/**
 * Checks if the queue is empty.
 *
 * @return A boolean that states whether the queue is empty or not.
 */
- (bool)isEmpty;

@end
