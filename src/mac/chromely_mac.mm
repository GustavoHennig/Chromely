/*
* chromely_mac.m
*
* This is a Claude generated description:
This file, `chromely_mac.m`, is an Objective-C implementation for creating and managing a window on macOS using the Chromium Embedded Framework (CEF). It provides the necessary functionality for handling events, creating the application window, and managing its lifecycle.

The file consists of several classes and functions:

1. `NSApplication+ChromelyApplication`: This category extends the `NSApplication` class to provide a custom implementation for handling events. It swizzles (exchanges) the implementation of the `sendEvent:` and `terminate:` methods to handle events and termination in a specific way.

2. `RootWindowDelegate`: This class is responsible for handling window-related events, such as window closing, minimization, and application hide/unhide events. It also manages the cleanup process when the window is closed.

3. `ChromelyAppDelegate`: This class is the application delegate that manages the creation of the main window, sets up the window's appearance and behavior (e.g., frameless, fullscreen, resizable), and handles window resizing and moving events.

4. `createwindow`: This function is the entry point for creating the application window. It initializes the `ChromelyApplication` instance, creates the `ChromelyAppDelegate`, and runs the CEF message loop.

5. `createwindowdata`: This function creates the `ChromelyAppDelegate` and returns an `APPDATA` struct containing the `NSApplication` instance and an `NSAutoreleasePool`.

6. `run`: This function runs the `NSApplication` event loop.

7. `quit`: This function releases the `NSAutoreleasePool` and terminates the `NSApplication`.

8. `minimize` and `maximize`: These functions minimize and maximize the window, respectively, by sending the appropriate messages to the window's `NSWindow` instance.

The file also includes various helper functions and callbacks to interact with the CEF framework and handle events related to the application window's lifecycle.
*/

// include the Cocoa Frameworks
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include "cef_application_mac.h"
#include "include/internal/cef_types_mac.h"

// include Chromely custom header
#include "chromely_mac.h"

namespace {
  bool g_handling_send_event = false;
}  // namespace

/*
* I1 - ChromelyApplication manages events.
* Provide the CefAppProtocol implementation required by CEF.
*/
@interface NSApplication (ChromelyApplication) <CefAppProtocol>
- (void)_swizzled_sendEvent:(NSEvent*)event;
- (void)_swizzled_terminate:(id)sender;

@end


// I2 - Receives notifications from controls and the browser window. Will delete
// itself when done.
@interface RootWindowDelegate : NSObject <NSWindowDelegate> {
 @private
  NSWindow* window_;
  CHROMELYPARAM chromelyParam_;
  bool force_close_;
}

@property(nonatomic, readwrite) bool force_close;

- (id)initWithWindow:(NSWindow*)window
       andParams:(CHROMELYPARAM)param;
@end  // @interface RootWindowDelegate


/*
* I3 - ChromelyAppDelegate manages events.
*/
@interface ChromelyAppDelegate : NSObject <NSApplicationDelegate>  {
    NSWindow * window_;
    RootWindowDelegate* window_delegate_;
    NSView   *cefParentView_;
    CHROMELYPARAM chromelyParam_;
}

- (void)setParams:(CHROMELYPARAM)param;
- (void)createApplication:(id)object;
- (NSUInteger)windowCustomStyle;

- (void)tryToTerminateApplication:(NSApplication*)app;
@end

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/

@implementation RootWindowDelegate

@synthesize force_close = force_close_;

- (id)initWithWindow:(NSWindow*)window
        andParams:(CHROMELYPARAM)param {
  if (self = [super init]) {
    window_ = window;
    chromelyParam_ = param;
    [window_ setDelegate:self];
    force_close_ = false;

    // Register for application hide/unhide notifications.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidHide:)
               name:NSApplicationDidHideNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidUnhide:)
               name:NSApplicationDidUnhideNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(windowDidMiniaturize:)
               name:NSWindowDidMiniaturizeNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(windowWillClose:)
               name:NSWindowWillCloseNotification
             object:window_];           
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
  [super dealloc];
#endif  // !__has_feature(objc_arc)
}

// Called when we are activated (when we gain focus).
- (void)windowDidBecomeKey:(NSNotification*)notification {
    /// CHROMELYPARAM- function pointer?
}

// Called when we are deactivated (when we lose focus).
- (void)windowDidResignKey:(NSNotification*)notification {
    /// CHROMELYPARAM- function pointer?
}

// Called when we have been minimized.
- (void)windowDidMiniaturize:(NSNotification*)notification {
    /// CHROMELYPARAM- function pointer?
}

// Called when we have been unminimized.
- (void)windowDidDeminiaturize:(NSNotification*)notification {
    /// CHROMELYPARAM- function pointer?
}

// Called when the application has been hidden.
- (void)applicationDidHide:(NSNotification*)notification {
  // If the window is miniaturized then nothing has really changed.
  if (![window_ isMiniaturized]) {
    /// CHROMELYPARAM- function pointer?
  }
}

// Called when the application has been unhidden.
- (void)applicationDidUnhide:(NSNotification*)notification {
  // If the window is miniaturized then nothing has really changed.
  if (![window_ isMiniaturized]) {
    /// CHROMELYPARAM- function pointer?
  }
}

// Called when the window is about to close. Perform the self-destruction
// sequence by getting rid of the window. By returning YES, we allow the window
// to be removed from the screen.
- (BOOL)windowShouldClose:(NSWindow*)window {
  NSLog(@"windowShouldClose called");	
  if (!force_close_) {
  /// CHROMELYPARAM- function pointer?
    }

  // Don't want any more delegate callbacks after we destroy ourselves.
  window_.delegate = nil;
  // Delete the window.
#if !__has_feature(objc_arc)
  [window autorelease];
#endif  // !__has_feature(objc_arc)
  window_ = nil;

  // Clean ourselves up after clearing the stack of anything that might have the
  // window on it.
  [self cleanup];

  // Allow the close.
  return YES;
}

- (void)windowWillClose:(NSNotification*)notification {
  NSLog(@"windowWillClose called");	

  NSWindow *closingWindow = [notification object];

  if (closingWindow.mainWindow == YES) {
    NSLog(@"windowWillClose called for mainWindow");
    [self cleanup];
    // chromelyParam_.exitCallback();
  }
}

// Deletes itself.
- (void)cleanup {
  // Don't want any more delegate callbacks after we destroy ourselves.
  window_.delegate = nil;
  window_.contentView = [[NSView alloc] initWithFrame:NSZeroRect];
  // Delete the window.
#if !__has_feature(objc_arc)
  [window_ autorelease];
#endif  // !__has_feature(objc_arc)
  window_ = nil;
 /// root_window_->OnNativeWindowClosed(); -     /// CHROMELYPARAM- function pointer?

  chromelyParam_.exitCallback();
}

@end  // @implementation RootWindowDelegate

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/*
* ChromelyApplication manages events.
* Provide the CefAppProtocol implementation required by CEF.
*/

@implementation NSApplication (ChromelyApplication)

// This selector is called very early during the application initialization.
+ (void)load {
  // Swap NSApplication::sendEvent with _swizzled_sendEvent.
  Method original = class_getInstanceMethod(self, @selector(sendEvent));
  Method swizzled =
      class_getInstanceMethod(self, @selector(_swizzled_sendEvent));
  method_exchangeImplementations(original, swizzled);

  Method originalTerm = class_getInstanceMethod(self, @selector(terminate:));
  Method swizzledTerm =
      class_getInstanceMethod(self, @selector(_swizzled_terminate:));
  method_exchangeImplementations(originalTerm, swizzledTerm);
}

- (BOOL)isHandlingSendEvent {
   return g_handling_send_event;
}

- (void)setHandlingSendEvent:(BOOL)handlingSendEvent {
  g_handling_send_event = handlingSendEvent;
}

- (void)_swizzled_sendEvent:(NSEvent*)event {
  CefScopedSendingEvent sendingEventScoper;
  // Calls NSApplication::sendEvent due to the swizzling.
  [self _swizzled_sendEvent:event];
}

- (void)_swizzled_terminate:(id)sender {
  [self _swizzled_terminate:sender];
}

@end

/*
* ChromelyAppDelegate manages events.
*/

@implementation ChromelyAppDelegate

- (void)setParams:(CHROMELYPARAM)param {
    chromelyParam_ = param;
}

// Create the application on the UI thread.
- (void)createApplication:(id)object {

  // Set the delegate for application events.
  NSApplication* application = [NSApplication sharedApplication];
  [application setDelegate:self];

  [application setActivationPolicy:NSApplicationActivationPolicyRegular];

  // Create the main window.

  // The CEF framework library is loaded at runtime so we need to use this
  // mechanism for retrieving the class.
  Class window_class = NSClassFromString(@"UnderlayOpenGLHostingWindow");

  NSUInteger customStyleMask = [self windowCustomStyle];
  window_ = [[window_class alloc]
               initWithContentRect: NSMakeRect(chromelyParam_.x, chromelyParam_.y, chromelyParam_.width, chromelyParam_.height)
               styleMask:customStyleMask
               backing:NSBackingStoreBuffered
               defer:NO ];

    NSString *title = [NSString stringWithUTF8String: chromelyParam_.titleUtf8Ptr];
	  [window_ setTitle:title];
    [window_ setAcceptsMouseMovedEvents:YES];

    // No dark mode, please
    window_.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];

    // Create the delegate for browser window events.
    window_delegate_ = [[RootWindowDelegate alloc] initWithWindow:window_
                                                  andParams:chromelyParam_];

    cefParentView_ = [window_ contentView];
    chromelyParam_.createCallback(window_, cefParentView_);

    if (chromelyParam_.centerscreen == 1)
        [window_ center];

    if (chromelyParam_.nominbutton == 1)
        [[window_ standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];

    if (chromelyParam_.nomaxbutton == 1)
        [[window_ standardWindowButton:NSWindowZoomButton] setHidden:YES];

    // Make window frameless without buttons and draggable invisible titlebar
    if (chromelyParam_.frameless == 1) {
        [[window_ standardWindowButton:NSWindowCloseButton] setHidden:YES];
        [[window_ standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        [[window_ standardWindowButton:NSWindowZoomButton] setHidden:YES];
        window_.titleVisibility = NSWindowTitleHidden;
        window_.titlebarAppearsTransparent = true;
    }

    [window_ makeKeyAndOrderFront:NSApp];

    // Rely on the window delegate to clean us up rather than immediately
    // releasing when the window gets closed. We use the delegate to do
    // everything from the autorelease pool so the window isn't on the stack
    // during cleanup (ie, a window close from javascript).
    [window_ setReleasedWhenClosed:NO];

    [NSApp activateIgnoringOtherApps:YES];
}

- (NSUInteger)windowCustomStyle {
    if (chromelyParam_.fullscreen == 1)
        return NSWindowStyleMaskFullScreen;

    NSUInteger styleMask = NSWindowStyleMaskTitled
                           | NSWindowStyleMaskClosable
                           | NSWindowStyleMaskMiniaturizable;

    if (chromelyParam_.frameless == 1)
        styleMask |= NSWindowStyleMaskFullSizeContentView;

    if (chromelyParam_.noresize == 0)
        styleMask |= NSWindowStyleMaskResizable;

    return styleMask;
}

- (void) windowWillMove:(NSNotification *)notification {
    chromelyParam_.movingCallback();
}

- (void)windowDidResize:(NSNotification *)notification {
    NSRect windowRect = [window_ frame];
    NSRect contentRect = [window_ contentRectForFrameRect:windowRect];
    chromelyParam_.resizeCallback(contentRect.size.width, contentRect.size.height);
}

- (void)tryToTerminateApplication:(NSApplication*)app {
    chromelyParam_.exitCallback();
}

- (NSApplicationTerminateReply)applicationShouldTerminate:
    (NSApplication*)sender {
  return NSTerminateNow;
}

- (void)dealloc {
    [cefParentView_ release];

    // Delete the window.
    #if !__has_feature(objc_arc)
      [window_ autorelease];
    #endif  // !__has_feature(objc_arc)
      window_ = nil;

    [super dealloc];

    chromelyParam_.exitCallback();
}

@end


/*
* Exported methods implementation
*/

void createwindow(CHROMELYPARAM* pParam) {

      @autoreleasepool {
        // Initialize the ChromelyApplication instance.
        [NSApplication sharedApplication];

        // Create the application delegate.
        ChromelyAppDelegate *appDelegate = [[ChromelyAppDelegate alloc] init];
        [appDelegate setParams:*pParam];
        [appDelegate performSelectorOnMainThread:@selector(createApplication:)
                               withObject:nil
                               waitUntilDone:NO];

        // Run the CEF message loop. This will block until CefQuitMessageLoop() is
        // called.
        pParam->runMessageLoopCallback();

        // Shut down CEF.
        pParam->cefShutdownCallback();

        // Release the delegate.
        #if !__has_feature(objc_arc)
        [appDelegate release];
        #endif  // !__has_feature(objc_arc)
        appDelegate = nil;
    }  // @autoreleasepool
}

APPDATA createwindowdata(CHROMELYPARAM* pParam) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSApp = [NSApplication sharedApplication];


    // Create the application delegate.
    ChromelyAppDelegate *appDelegate = [[[ChromelyAppDelegate alloc] init] autorelease];
    NSLog(@"Created: appDelegate appDelegate:%@", appDelegate);

    [appDelegate setParams:*pParam];
    NSLog(@"appDelegate setParams set");

    [appDelegate performSelectorOnMainThread:@selector(createApplication:)
                            withObject:nil
                            waitUntilDone:NO];
    NSLog(@"appDelegate performSelectorOnMainThread");

    APPDATA appData;
    appData.app = NSApp;
    appData.pool = pool;

    return appData;
}

void run(void* application) {
    [(NSApplication *)application run];
}

void quit(void* application, void* pool) {
    [(NSAutoreleasePool *)pool release];
    [(NSApplication *)application performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

void minimize(void* view) {
  [[CAST_CEF_WINDOW_HANDLE_TO_NSVIEW(view) window] performMiniaturize:nil];
}

void maximize(void* view) {
  [[CAST_CEF_WINDOW_HANDLE_TO_NSVIEW(view) window] performZoom:nil];
}

// Function to show a folder selection dialog and return the selected folder path
const char* showselectfolderwindow(void* parentWindow) {
    __block const char* resultString = NULL;

    // Create a semaphore to wait for the sheet to close
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    // Ensure execution on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSWindow* window = (__bridge NSWindow*)parentWindow;

            NSOpenPanel* panel = [NSOpenPanel openPanel];

            [panel setCanChooseFiles:NO];
            [panel setCanChooseDirectories:YES];
            [panel setAllowsMultipleSelection:NO];

            [panel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result) {
                if (result == NSModalResponseOK) {
                    NSURL* folderURL = [[panel URLs] objectAtIndex:0];
                    NSString* folderPath = [folderURL path];

                    const char* cString = [folderPath UTF8String];
                    // Duplicate the string to ensure it remains valid after the function returns
                    resultString = strdup(cString);
                }
                // Signal that the sheet has been dismissed
                dispatch_semaphore_signal(sema);
            }];
        }
    });

    // Wait until the sheet is dismissed
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return resultString;
}

// Function to free the allocated string
void freestring(const char* str) {
    if (str != NULL) {
        free((void*)str);
    }
}


