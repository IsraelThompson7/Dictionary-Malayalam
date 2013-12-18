//
//  PorterStemmer.m
//  Dictionary
//
//  Created by Apple on 18/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PorterStemmer.h"
#import "porter.c"

#define MAX_STEMMER_STRING_LENGTH 256

@implementation PorterStemmer

+ (NSString *)stemFromString:(NSString *)input
{
    struct stemmer stemmer;
    char stemBuffer[MAX_STEMMER_STRING_LENGTH];
    
    strncpy(stemBuffer, [input cStringUsingEncoding:NSUTF8StringEncoding], MAX_STEMMER_STRING_LENGTH -1);
    
    int i = strlen(stemBuffer);
    stemBuffer[stem(&stemmer, stemBuffer, i-1) +1] = '\0';
    
    NSString *stem = [NSString stringWithCString:stemBuffer encoding:NSUTF8StringEncoding];
    return stem;
}
@end

@implementation NSString (PorterStemmer)

- (NSString *)stem
{
    return [PorterStemmer stemFromString:self];
}

@end
