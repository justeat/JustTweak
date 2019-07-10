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
 * This class handles all file-related methods.
 * The files are saved in the Library directory for iOS and tmp directory for tvOS so that the file can not be read by app users.
 * The file directories are further broken down into data types:
 *   /optimizely/datafile
 *   /optimizely/user-profile/
 *   /optimizely/event-dispatcher/
 *
 */

@interface OPTLYFileManager : NSObject
/**
 * File manager initializer.
 *
 * @param baseDir The base directory where the file manager data will be stored.
 * @return an instance of OPTLYFileManager.
 **/
- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir;

/**
 * Saves a file.
 * If a file of the same name type exists already, then that file will be overwritten.
 *
 * @param fileName A string that represents the name of the file to save.
 *  Can include a file suffix if desired (e.g., .txt or .json).
 * @param data The data to save to the file.
 * @param subDir A path sub directory to help segment data (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (BOOL)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
          subDir:(nullable NSString *)subDir
           error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Gets a file.
 *
 * @param fileName A string that represents the name of the file to retrieve.
 * @param subDir A path sub directory to help segment data (e.g., datafile, user profile, event dispatcher, etc.)
 * @return The file in NSData format.
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (nullable NSData *)getFile:(nonnull NSString *)fileName
                      subDir:(nullable NSString *)subDir
                       error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Determines if a file exists.
 *
 * @param fileName A string that represents the name of the file to check.
 * @param subDir A path sub directory to help segment data (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a file exists or not (or could not be determined).
 *
 **/
- (bool)fileExists:(nonnull NSString *)fileName
            subDir:(nullable NSString *)subDir;

/**
 * Determines if a sub directory (in the base directory) exists.
 *
 * @param subDir A string that represents the sub directory to check.
 * @return A boolean value that states if a sub directory exists or not.
 *  This method will return false if the directory path could not be determined.
 *
 **/
- (bool)subDirExists:(nullable NSString *)subDir;

/**
 * Deletes a file.
 *
 * @param fileName A string that represents the name of the file to delete.
 * @param subDir A path sub directory to help segment data (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file removal fails.
 *  If error is nil, than the file deletion was successful.
 *
 **/
- (BOOL)removeFile:(nonnull NSString *)fileName
            subDir:(nullable NSString *)subDir
             error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes all data persisted.
 *
 * @param error An error object which will store any errors if the file removal fails.
 *
 **/
- (BOOL)removeAllFiles:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 * Removes a particular data type.
 *
 * @param subDir A path sub directory to help segment data (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the directory removal fails.
 *
 **/
- (BOOL)removeDataSubDir:(nullable NSString *)subDir
                   error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
