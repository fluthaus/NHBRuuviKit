//
//  RKSTableViewController.m
//
//  NHBRuuviKitSample
//  http://dev.fluthaus.de/NHBRuuviKit
//
//  Copyright © 2018, nhb | fluthaus. All rights reserved.
//  Licensed under the New BSD License (see LICENSE)
//

@import NHBRuuviKit;

#import "RKSTableViewController.h"
#import "RKSAppDelegate.h"
#import "RKSRuuviTag.h"

@interface RKSTableViewController ()

// to display the ruuvi tags in the order they are discovered, we keep track of known tags with a ordered collection
@property (readwrite, strong) NSMutableOrderedSet<RKSRuuviTag*>* ruuviTags;

@end

@implementation RKSTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

	self.ruuviTags = [NSMutableOrderedSet orderedSet];

	// we want to get notified when a tag is discovered or updated, so we can refresh the table view
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ruuviTagDidUpdate:) name:kRKNotificationName_RuuviTagDidUpdate object:nil];
}

-(void)ruuviTagDidUpdate:(NSNotification*)notification
{
	[self.ruuviTags addObject:notification.object];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ruuviTags.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];

	RKSRuuviTag* ruuviTag = self.ruuviTags[indexPath.row];
   	cell.textLabel.text = ruuviTag.CBIdentifier.UUIDString;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ C°", ruuviTag.ruuviData.ruuviTemperature ?: @"n/a"];  // <-- if you just want to display something else than temperature, look here
    
    return cell;
}

#pragma mark - Resetting

-(IBAction)reset:(id)sender
{
	[(RKSAppDelegate*)UIApplication.sharedApplication.delegate resetRuuviTags];
	[self.ruuviTags removeAllObjects];
	[self.tableView reloadData];
}

@end


