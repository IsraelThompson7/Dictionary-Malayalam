//
//  DictionaryDao.m
//  Dictionary
//
//  Created by Apple on 18/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "DictionaryDao.h"
#import "EnglishToMalayalamDictionary.h"
#import "sqlite3.h"

@implementation DictionaryDao

- (NSString *) getDatabasePath:(NSString *)databaseName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:databaseName ofType:@"db" inDirectory:@"/"];
    return path;
}

- (NSMutableArray *) fetchRows:(NSString *)databaseName withText:(NSString *)text andExactMatch:(BOOL)exact
{
    NSLog(@"fetch Rows : %@", text);
    text = [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT olam_id, en, part, ml FROM enml WHERE en %@ '%@%@' order by en, part COLLATE NOCASE limit 500", exact ? @"LIKE": @"LIKE", text, exact ? @"" : @"%"];
    NSLog(@"SQL : %@", sql);
    NSString *pathName = [self getDatabasePath:databaseName];
    const char *dbPath = [pathName UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open(dbPath, &db) == SQLITE_OK)
    {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                EnglishToMalayalamDictionary *row = [[EnglishToMalayalamDictionary alloc]init];
                row.olamId = sqlite3_column_int(stmt, 0);
                row.en = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
                row.parts = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
                row.ml = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
                [rows addObject:row];
            }
            sqlite3_finalize(stmt);
        }
        else
        {
            NSLog(@"ERROR : %s", sqlite3_errmsg(db));
        }
        sqlite3_close(db);
    }
    return rows;
}
- (NSMutableArray *)fetchWords:(NSString *)databaseName withText:(NSString *)text
{
    text = [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSMutableArray *rows = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT en FROM enwords WHERE en like '%@%%' order by en COLLATE NOCASE limit 100", text];
    NSString *pathName = [self getDatabasePath:databaseName];
    const char *dbPath = [pathName UTF8String];
    sqlite3 *db;
    if (sqlite3_open(dbPath, &db) == SQLITE_OK)
    {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString *en = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(stmt, 0)];
                [rows addObject:en];
            }
            sqlite3_finalize(stmt);
        }
        else
        {
            NSLog(@"ERROR : %s", sqlite3_errmsg(db));
        }
    }
    return rows;
}
@end
