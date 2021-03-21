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
	- (void)navigationBarURLWasTapped:(id)arg1;
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
				{
					if (@available(iOS 14, *))
						[MSHookIvar<BrowserController*>(self, "_browserController") navigationBarURLWasTapped:nil completionHandler:nil];
					else
						[MSHookIvar<BrowserController*>(self, "_browserController") navigationBarURLWasTapped:nil];	
				}
			});
		}
	}
}

%end
