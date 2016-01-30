//
//  ServerDownAppViewController.m
//  ServerDownApp
//
//  Created by Daniel on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/* todo:
    server:
            call put
            figure out "differences"
            call push
 
 */

#import "ServerDownAppViewController.h"
#import "Cell.h"

@implementation ServerDownAppViewController

@synthesize loaded;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];

    serverList = [[NSMutableArray alloc] init];
    [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadServers) object:nil]];
    
    @synchronized (self) {
        token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        delegate = (ServerDownAppAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!token)
            delegate.delegate = self;
        else {
            [self setLoaded:YES];
            [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadList) object:nil]];
            [token retain];
        }
    }

    pending = [[NSMutableArray alloc] init];
    [super viewDidLoad];
}

- (void)tokenReady {
    @synchronized (self) {
        if (![self loaded]) {
            [self setLoaded:YES];
            [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadList) object:nil]];
        }
        token = delegate.token;
    }
}

- (void)loadServers {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error = NULL;
    NSString *list;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    list = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://coffeepp.com:43985/serve/out.txt"] encoding:NSUTF8StringEncoding error:&error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (error) {
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internet connection failed. Couldn't connect to our servers" waitUntilDone:YES];
    } else {
        NSArray *tmpa = [list componentsSeparatedByString:@"\n"];
        [list release];
        for (id element in tmpa) {
            NSArray *arr = [element componentsSeparatedByString:@","];
            if ([arr count] > 1)
                [serverList addObject:[arr objectAtIndex:0]];
        }
    }
    [tv performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [pool drain];
}

- (void)loadList {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    selectedServers = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    NSString *tmp;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    tmp = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://10.0.1.2:43986/srvdwn?a=q&i=%@&isAdmin=false", token]] encoding:NSUTF8StringEncoding error:&error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (error) {
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internet connection failed. Couldn't connect to our servers" waitUntilDone:YES];
    } else {
        NSArray *chunks = [tmp componentsSeparatedByString:@";"];
        for (id chunk in chunks) {
            if ([chunk length] > 0) {
                [selectedServers addObject:chunk];
            }
        }
    }
    [tmp release];
    [tv performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [pool drain];
}

- (void)showAlert:(NSString *)message {
    UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [aview show];
    [aview release];
}

- (void)viewDidUnload {
    [serverList release];
    [selectedServers release];
    [super viewDidUnload];
    delegate.delegate = nil;
    [queue release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [tv reloadData];
    // Return YES for supported orientations
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:nil options:nil];
		for (id currentObject in topLevelObjects) {
			if ([currentObject isKindOfClass:[UITableViewCell class]]) {
				cell = (Cell *)currentObject;
				break;
			}
		}
	}
    
    NSString *tmp = [serverList objectAtIndex:indexPath.row];
    cell.watching.hidden = ([selectedServers indexOfObject:tmp] == NSNotFound) || !selectedServers;
    @synchronized (pending) {
        if ([pending indexOfObject:tmp] == NSNotFound) {
            [cell.activity stopAnimating];
        } else {
            [cell.activity startAnimating];        
        }
    }
    cell.serverName.text = tmp;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [serverList count];
}

- (void)threadedSync:(NSIndexPath *)withObject {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *tmp = [serverList objectAtIndex:withObject.row];
    NSError *error;
    if ([selectedServers indexOfObject:tmp] == NSNotFound) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *response = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://10.0.1.2:43986/srvdwn?a=a&i=%@&s=%@&isAdmin=false", token, tmp]] encoding:NSUTF8StringEncoding error:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([response isEqualToString:@"ok"]) {
            [selectedServers addObject:tmp];
        } else if ([response isEqualToString:@"nok"]) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internal server error. Please report this issue." waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internet connection failed. Couldn't connect to our servers" waitUntilDone:NO];
        }
        [response release];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *response = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://10.0.1.2:43986/srvdwn?a=r&i=%@&s=%@&isAdmin=false", token, tmp]] encoding:NSUTF8StringEncoding error:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([response isEqualToString:@"ok"]) {
            [selectedServers removeObject:tmp];
        } else if ([response isEqualToString:@"nok"]) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internal server error. Please report this issue." waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Internet connection failed. Couldn't connect to our servers" waitUntilDone:NO];
        }
        [response release];
    }
    // weird code because: we do not want to remove all instances and another thread could fuck up the order
    @synchronized (pending) {
        [pending removeObjectAtIndex:[pending indexOfObject:tmp]];
    }
    [self performSelectorOnMainThread:@selector(mainThreadAnimatedTV:) withObject:withObject waitUntilDone:YES];
    [pool drain];
}

- (void)mainThreadAnimatedTV:(NSIndexPath *)withObject {
    [tv reloadRowsAtIndexPaths:[NSArray arrayWithObject:withObject] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!delegate.token) {
        UIAlertView *aview = [[UIAlertView alloc] initWithTitle:@"Push not working" message:@"You need to allow push notifications in order to use this application." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [aview show];
        [aview release];
        return;
    }
    
    @synchronized (pending) {
        NSString *tmp = [serverList objectAtIndex:indexPath.row];
        if ([pending indexOfObject:tmp] == NSNotFound) {
            [pending addObject:tmp];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [pending addObject:tmp];
        }
    }

    [queue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(threadedSync:) object:indexPath]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tv = tableView; // i do not know why, but assigning it in IB fails.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Select servers";
}

@end
