//
//  XcodeImageView.m
//  CodeSignBreak
//
//  Created by mlyixi on 11/17/14.
//  Copyright (c) 2014 mlyixi. All rights reserved.
//

#import "XcodeImageView.h"

@implementation XcodeImageView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard=[sender draggingPasteboard];
    path=[[pboard propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
    CFStringRef fileExtension=(__bridge CFStringRef)[path pathExtension];
    CFStringRef fileUTI=UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    if (UTTypeConformsTo(fileUTI, kUTTypeApplication)) {
        highlight=YES;
        [self setNeedsDisplay: YES];
        
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    [self.delegate dragFinished:path patchProject:NO];
    return YES;
}

@end
