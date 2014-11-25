//
//  ProjectImageView.m
//  CodeSignBreak
//
//  Created by mlyixi on 11/17/14.
//  Copyright (c) 2014 mlyixi. All rights reserved.
//

#import "ProjectImageView.h"

@implementation ProjectImageView
NSString *kXcodeProjectUTI=@"com.apple.xcode.project";

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard=[sender draggingPasteboard];
    path=[[pboard propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
    CFStringRef fileExtension=(__bridge CFStringRef)[path pathExtension];
    CFStringRef fileUTI=UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, (__bridge CFStringRef)(kXcodeProjectUTI))) {
        highlight=YES;
        [self setNeedsDisplay: YES];
        
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    [self.delegate dragFinished:path patchProject:YES];
    return YES;
}
@end
