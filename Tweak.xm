@interface TabDocument
	@property(nonatomic, getter=isBlankDocument) bool blankDocument;
	- (id)URLString;
	@property(readonly, nonatomic) bool isContentReady;
@end

@interface TabController
	@property(retain, nonatomic) TabDocument *activeTabDocument;
@end

@interface BrowserController
	@property(readonly, nonatomic) TabController *tabController;
	- (void)navigationBarURLWasTapped:(id)arg1 completionHandler:(id)arg2;
@end

@interface BrowserRootViewController
	@property(readonly, nonatomic)BrowserController *browserController;
@end

%hook TabDocument

- (void)setActive:(BOOL)arg1
{
	%orig;

	if (arg1)
	{
		if (MSHookIvar<BOOL>(self, "_isBlank"))
		{
			double delayInSeconds = 0.25;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				if (MSHookIvar<BOOL>(self, "_isBlank") && !MSHookIvar<BOOL>(self, "_webViewIsLoading"))
					[MSHookIvar<BrowserController*>(self, "_browserController") navigationBarURLWasTapped:nil completionHandler:nil];
			});
		}
	}
}

%end

// %hook BrowserRootViewController
//
// - (void)viewDidAppear:(BOOL)animated
// {
// 	%orig;
// 	TabController *tc = [self.browserController tabController];
//
// 	if (tc)
// 	{
// 		TabDocument *activeTabDocument = [tc activeTabDocument];
// 		if(activeTabDocument)
// 		{
// 			if (MSHookIvar<BOOL>(activeTabDocument, "_isBlank"))
// 				[self.browserController navigationBarURLWasTapped:nil completionHandler:nil];
// 		}
// 	}
// }
//
// %end
//
// %hook TabController
//
// 	- (void)_newTabFromTabViewButton
// 	{
// 		%orig;
// 		BrowserController *controller = MSHookIvar<BrowserController*>(self,"_browserController");
// 		[controller navigationBarURLWasTapped:nil completionHandler:nil];
// 	}
//
// %end
//
// %hook BrowserController
//
// 	- (void)openNewTab:(id)arg1
// 	{
// 		%orig;
// 		double delayInSeconds = 1.0;
// 		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
// 		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
// 				[self navigationBarURLWasTapped:nil completionHandler:nil];
// 		});
// 	}
//
// 	- (void)openNewPrivateTab:(id)arg1
// 	{
// 		%orig;
// 		double delayInSeconds = 1.0;
// 		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
// 		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
// 				[self navigationBarURLWasTapped:nil completionHandler:nil];
// 		});
// 	}
//
// %end
