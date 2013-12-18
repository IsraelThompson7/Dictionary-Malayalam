//
//  ViewController.h
//  Dictionary
//
//  Created by Apple on 16/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSMutableArray *matches;
    NSDictionary *parts;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *autoCompeteTableview;
@property (weak, nonatomic) IBOutlet UITextView *results;

@end
