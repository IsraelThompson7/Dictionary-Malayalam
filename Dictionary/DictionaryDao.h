//
//  DictionaryDao.h
//  Dictionary
//
//  Created by Apple on 18/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryDao : NSObject

- (NSString *)getDatabasePath: (NSString *) databaseName;
- (NSMutableArray *)fetchRows: (NSString *) databaseName withText:(NSString *) text andExactMatch:(BOOL) exact;
- (NSMutableArray *)fetchWords: (NSString *) databaseName withText:(NSString *) text;

@end
