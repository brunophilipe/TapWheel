//
//  BPQuickReference.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/28/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPQuickReference.h"
#import <MediaPlayer/MediaPlayer.h>

#import <string.h>

@import ObjectiveC;

static const char * getPropertyType(objc_property_t property);

@implementation BPQuickReference
{
	MPMusicPlayerController *_mediaPlayer;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_mediaPlayer = [[MPMusicPlayerController systemMusicPlayer] retain];
	}
	return self;
}

- (void)dealloc
{
	[_mediaPlayer dealloc];
	[super dealloc];
}

/**
 *	This method uses a private library to get how many songs are in the current play queue
 */
- (NSAttributedString*)playingQueueDescription
{
	#ifndef DEBUG
	#warning Private Library Usage
	#endif

	SEL selectorIndex = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@", @"unshuffl", @"edInde",@"xOfNo",@"wPlayi",@"ngItem"]);
	SEL selectorCount = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"numb",@"erOfI",@"tems"]);

	NSString *songIndex;

	if ([_mediaPlayer respondsToSelector:selectorIndex])
	{
		songIndex = [NSString stringWithFormat:@"%lu", (unsigned long)[_mediaPlayer performSelector:selectorIndex]];
	}
	else
	{
		songIndex = [NSString stringWithFormat:@"%lu", (unsigned long)[_mediaPlayer indexOfNowPlayingItem] + 1];
	}

	NSString *songCount = [NSString stringWithFormat:@"%lu", (unsigned long)[_mediaPlayer performSelector:selectorCount]];

	NSMutableAttributedString *result = [NSMutableAttributedString new];
	NSDictionary *smallTextAttrs = @{
		NSFontAttributeName: [UIFont fontWithName:@"ChicagoFLF" size:10.0]
	};
	NSDictionary *bigTextAttrs = @{
		NSFontAttributeName: [UIFont fontWithName:@"ChicagoFLF" size:13.0]
	};

	[result appendAttributedString:[[NSAttributedString alloc] initWithString:songIndex attributes:bigTextAttrs]];
	[result appendAttributedString:[[NSAttributedString alloc] initWithString:@" of " attributes:smallTextAttrs]];
	[result appendAttributedString:[[NSAttributedString alloc] initWithString:songCount attributes:bigTextAttrs]];

	return result;
}

@end

static const char * getPropertyType(objc_property_t property)
{
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		if (attribute[0] == 'T') {
			if (strlen(attribute) <= 4) {
				break;
			}
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
		}
	}
	return "@";
}
