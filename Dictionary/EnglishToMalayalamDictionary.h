//
//  EnglishToMalayalamDictionary.h
//  Dictionary
//
//  Created by Apple on 18/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnglishToMalayalamDictionary : NSObject

@property (nonatomic) int olamId;
@property (nonatomic, strong) NSString *en;
@property (nonatomic, strong) NSString *parts;
@property (nonatomic, strong) NSString *ml;

@end