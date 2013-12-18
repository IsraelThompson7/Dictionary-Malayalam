//
//  PorterStemmer.h
//  Dictionary
//
//  Created by Apple on 18/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PorterStemmer : NSObject

+ (NSString *)stemFromString:(NSString *)input;

@end

@interface NSString (PorterStemmer)

- (NSString *)stem;

@end