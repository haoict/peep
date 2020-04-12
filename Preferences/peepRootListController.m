#include "peepRootListController.h"

@implementation peepRootListController
- (NSBundle *)resourceBundle {
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/peepPrefs.bundle"];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)code {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cbyrne/peep"] options:@{} completionHandler:nil];
}

-(void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ko-fi.com/ConorTheDev"] options:@{} completionHandler:nil];
}

-(void)bug {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/cbyrne/peep/issues/new"] options:@{} completionHandler:nil];
}
@end
