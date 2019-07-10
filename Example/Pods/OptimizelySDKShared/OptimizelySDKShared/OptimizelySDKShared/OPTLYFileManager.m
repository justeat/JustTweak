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

#import "OPTLYFileManager.h"

@interface OPTLYFileManager()
@property (nonatomic, strong) NSString *baseDir;
@end

@implementation OPTLYFileManager

- (instancetype)initWithBaseDir:(NSString *)baseDir {
    self = [super init];
    if (self != nil) {
        _baseDir = baseDir;
    }
    return self;
}

- (id)init {
    NSAssert(true, @"Use initWithBaseDir.");
    self = [super init];
    return self;
}

- (BOOL)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
          subDir:(nullable NSString *)subDir
           error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    BOOL ok = YES;
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:subDir];
    NSString *filePath = [self filePathFor:fileName subDir:subDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileDir isDirectory:nil]) {
        ok = [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:error];
    }
    if (ok) {
        // NSDataWritingAtomic
        // A hint to write data to an auxiliary file first and then exchange the files.
        // https://developer.apple.com/documentation/foundation/nsdatawritingoptions/nsdatawritingatomic?language=objc
        // NSDataWritingFileProtectionCompleteUnlessOpen
        // In this case, the file cannot be opened for reading or writing
        // when the device is locked, although new files can be created with
        // this class. If one of these files is open when the device is locked,
        // reading and writing are still allowed.
        // https://developer.apple.com/documentation/foundation/nsdatawritingoptions/nsdatawritingfileprotectioncompleteunlessopen?language=objc
        ok = [data writeToFile:filePath
                       options:NSDataWritingAtomic|NSDataWritingFileProtectionCompleteUnlessOpen
                         error:error];
    }
    return ok;
}


- (nullable NSData *)getFile:(nonnull NSString *)fileName
                      subDir:(nullable NSString *)subDir
                       error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSString *filePath = [self filePathFor:fileName subDir:subDir];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    return fileData;
}


- (bool)fileExists:(nonnull NSString *)fileName
            subDir:(nullable NSString *)subDir
{
    NSString *filePath = [self filePathFor:fileName subDir:subDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool fileExists = [fileManager fileExistsAtPath:filePath];
    return fileExists;
}

- (bool)subDirExists:(nullable NSString *)subDir
{
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:subDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    bool dirExists = [fileManager fileExistsAtPath:fileDir];
    return dirExists;
}

- (BOOL)removeFile:(nonnull NSString *)fileName
            subDir:(nullable NSString *)subDir
             error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSString *filePath = [self filePathFor:fileName subDir:subDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:filePath error:error];
}

- (BOOL)removeDataSubDir:(nullable NSString *)subDir
                   error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:subDir];
    return [fileManager removeItemAtPath:fileDir error:error];
}

- (BOOL)removeAllFiles:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:self.baseDir error:error];
}

# pragma mark - Helper Methods
- (NSString *)filePathFor:(NSString *)fileName subDir:(NSString *)subDir
{
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:subDir];
    NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
