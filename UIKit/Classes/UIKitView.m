//  Created by Sean Heber on 6/19/10.
#import "UIKitView.h"
#import "UIScreen.h"
#import "UIApplication.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UIKit+Private.h"

@implementation UIKitView
@synthesize UIScreen=_screen;

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		_screen = [UIScreen new];
		[self setLayer:[_screen _layer]];
		[self setWantsLayer:YES];
    }
    return self;
}

- (void)dealloc
{
	[_screen release];
	[_mainWindow release];
	[super dealloc];
}

- (UIWindow *)UIWindow
{
	if (!_mainWindow) {
		_mainWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_screen.bounds];
		_mainWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_mainWindow.screen = _screen;
		[_mainWindow makeKeyAndVisible];
	}
	
	return _mainWindow;
}

- (void)awakeFromNib
{
	[self setWantsLayer:YES];
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)viewDidMoveToSuperview
{	
	[_screen _setNSView:self.superview? self : nil];
}

- (void)updateTrackingAreas
{
	[self removeTrackingArea:_trackingArea];
	[_trackingArea release];
	_trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingCursorUpdate|NSTrackingMouseMoved|NSTrackingInVisibleRect|NSTrackingActiveInActiveApp owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	[[UIApplication sharedApplication] _screen:_screen didReceiveNSEvent:theEvent];
}

- (void)_launchApplicationDelegate:(id<UIApplicationDelegate>)appDelegate
{
	[[UIApplication sharedApplication] setDelegate:appDelegate];
	[appDelegate applicationDidFinishLaunching:[UIApplication sharedApplication]];
}

- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay
{
	if (delay) {
		UIImage *defaultImage = [UIImage imageNamed:@"Default-Landscape.png"];
		UIImageView *defaultImageView = [[[UIImageView alloc] initWithImage:defaultImage] autorelease];
		defaultImageView.contentMode = UIViewContentModeCenter;
		
		UIWindow *defaultWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_screen.bounds];
		defaultWindow.screen = _screen;
		defaultWindow.backgroundColor = [UIColor blackColor];	// dunno..
		defaultWindow.opaque = YES;
		[defaultWindow addSubview:defaultImageView];
		[defaultWindow makeKeyAndVisible];
		
		[self performSelector:@selector(_launchApplicationDelegate:) withObject:appDelegate afterDelay:delay];
		[defaultWindow performSelector:@selector(release) withObject:nil afterDelay:delay];
	} else {
		[self _launchApplicationDelegate:appDelegate];
	}
}

@end