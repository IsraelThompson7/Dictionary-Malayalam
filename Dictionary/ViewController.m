//
//  ViewController.m
//  Dictionary
//
//  Created by Apple on 16/12/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import "ViewController.h"
#import "EnglishToMalayalamDictionary.h"
#import "DictionaryDao.h"
#import "PorterStemmer.h"

@interface ViewController ()

@end

@implementation ViewController
#define SYSTEM_VERSION_LESS_THAN(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
const float kBigFontSize = 20.0f;
const float ksmallFontSize = 18.0f;

bool inFullScreen = NO;
CGRect normalFrame;
CGRect hiddenFrame;
CGRect normalViewFrame;
CGRect fullViewFrame;
float animationDuration = 0.5;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.searchbar.tintColor = [UIColor blackColor];
    }
    self.title = @"Dictionary";
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    parts = @{
              @"n": @"നാമം  :noun",
              @"v": @"ക്രിയ  :verb",
              @"a": @"വിശേഷണം  :adjective",
              @"adv": @"ക്രിയാവിശേഷണം  :adverb",
              @"pron": @"സര്‍വ്വനാമം  :pronoun",
              @"propn": @"സംജ്ഞാനാമം  :proper noun",
              @"phrv": @"ഉപവാക്യ ക്രിയ  :phrasal verb",
              @"conj": @"അവ്യയം  :conjunction",
              @"interj": @"വ്യാക്ഷേപകം  :interjection",
              @"prep": @"ഉപസര്‍ഗം  :preposition",
              @"pfx": @"പൂർവ്വപ്രത്യയം  :prefix",
              @"sfx": @"പ്രത്യയം  :suffix",
              @"idm": @"ഭാഷാശൈലി  :idiom",
              @"abbr": @"സംക്ഷേപം  :abbreviation",
              @"auxv": @"പൂരകകൃതി  :auxiliary verb"
              };
    
    self.searchbar.text = @"Apple";
    [self search:self.searchbar.text withStem:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFullScreen
{
    //Fully Visible
    normalFrame = self.navigationController.navigationBar.frame;
    
    //frame of the hidden nav bar
    hiddenFrame = normalFrame;
    hiddenFrame.origin.y -= CGRectGetHeight(normalFrame);
    
    //frame as in storyboard
    normalViewFrame = self.view.frame;
    
    //frame of our view moved up by height i=of nav bar & increased in height by same amount
    fullViewFrame = normalViewFrame;
    fullViewFrame.origin.y -= CGRectGetHeight(normalFrame);
    fullViewFrame.size.height += CGRectGetHeight(normalFrame);
}
- (void)toggleFullScreen
{
    if (inFullScreen)
    {
        [UIView animateWithDuration:animationDuration animations:^{
            self.navigationController.navigationBar.frame = normalFrame;
            self.view.frame = normalViewFrame;
        }completion:^(BOOL finished){
            
        }];
    }
    else
    {
        [UIView animateWithDuration:animationDuration animations:^{
            self.navigationController.navigationBar.frame = hiddenFrame;
            self.view.frame = fullViewFrame;
        }completion:^(BOOL finished){
            
        }];
    }
    inFullScreen = !inFullScreen;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (matches)
    {
        return [matches count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AutoCompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [matches objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self search:[matches objectAtIndex:indexPath.row] withStem:NO];
    self.searchbar.text = [matches objectAtIndex:indexPath.row];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.autoCompeteTableview.hidden = NO;
    self.results.hidden = YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.autoCompeteTableview.hidden = YES;
    self.results.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0)
    {
        DictionaryDao *dao = [[DictionaryDao alloc]init];
        matches = [dao fetchWords:@"olam" withText:searchText];
        [self.autoCompeteTableview reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.autoCompeteTableview.hidden = YES;
    self.results.hidden = NO;
    searchBar.text = nil;
    matches = nil;
    [self.autoCompeteTableview reloadData];
    [self.results becomeFirstResponder];
}

- (void)search:(NSString *)text withStem:(BOOL)stem
{
    NSLog(@"SearchText:%@", text);
    if (stem)
    {
        text = [PorterStemmer stemFromString:text];
        NSLog(@"stemmedText:%@", text);
    }
    DictionaryDao *dao = [[DictionaryDao alloc]init];
    NSMutableArray *rows = [dao fetchRows:@"olam" withText:text andExactMatch:!stem];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]init];
    NSString *prevEnglish = nil;
    NSString *prevPart = nil;
    id tempstring;
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.headIndent += 15.0f;
    paragraph.firstLineHeadIndent = paragraph.headIndent - 10.0f;
    for (EnglishToMalayalamDictionary *row in rows)
    {
        if (prevEnglish == nil || ![prevEnglish isEqualToString:row.en])
        {
            tempstring = [[NSMutableAttributedString alloc]initWithString:@"\n"];
            [content appendAttributedString:tempstring];
            prevPart = nil;
        }
        prevEnglish = row.en;
        if ([row.parts length] > 0)
        {
            if (prevPart == nil || ![prevPart isEqualToString:row.parts])
            {
                if (prevPart != nil)
                {
                    tempstring = [[NSMutableAttributedString alloc]initWithString:@"\n"];
                    [content appendAttributedString:tempstring];
                }
                NSString *part = parts[row.parts];
                if (part != nil)
                {
                    tempstring = [[NSMutableAttributedString alloc]initWithString:part attributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:ksmallFontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
                    [content appendAttributedString:tempstring];
                    tempstring = [[NSMutableAttributedString alloc]initWithString:@"\n"];
                    [content appendAttributedString:tempstring];
                }
            }
        }
        prevPart = row.parts;
        tempstring = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@". %@", row.ml] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kBigFontSize], NSParagraphStyleAttributeName: paragraph}];
        [content appendAttributedString:tempstring];
        tempstring = [[NSMutableAttributedString alloc]initWithString:@"\n"];
        [content appendAttributedString:tempstring];
    }
    bool detectLinks = NO;
    if ([rows count] == 0)
    {
        tempstring = [[NSMutableAttributedString alloc]initWithString:@"\nNO matches \n\nYou can add it at http://en.wiktionary.org" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ksmallFontSize], NSForegroundColorAttributeName: [UIColor grayColor]}];
        [content appendAttributedString:tempstring];
         detectLinks = YES;
    }
    self.results.attributedText = content;
    if (detectLinks)
    {
        self.results.dataDetectorTypes = UIDataDetectorTypeLink;
    }
    [self.results becomeFirstResponder];
    [self.results scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text withStem:YES];
}

- (void)showInfo
{
    NSLog(@"showInfo");
    self.autoCompeteTableview.hidden = YES;
    self.results.hidden = NO;
 
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    id tempString;
 
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n Dictionary\n\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kBigFontSize]}];
    [content appendAttributedString:tempString];
 
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"App developed by:\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:ksmallFontSize]}];
    [content appendAttributedString:tempString];
 
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"PrabhuNatarajan\n(prabhu.n90@gmail.com)\n\n"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ksmallFontSize]}];
    [content appendAttributedString:tempString];
 
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Content from:\n"] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:ksmallFontSize]}];
    [content appendAttributedString:tempString];
 
    tempString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"prabhuNatarajan (http://summaoru.blogspot.in)"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ksmallFontSize]}];
    [content appendAttributedString:tempString];
 
    self.results.attributedText = content;
    self.results.dataDetectorTypes = UIDataDetectorTypeAll;
    [self.results becomeFirstResponder];
}
 
@end
