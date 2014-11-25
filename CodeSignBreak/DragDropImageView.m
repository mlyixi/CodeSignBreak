//
//  DragDropImageView.m
//  CodeSignBreak
//
//  Created by mlyixi on 11/17/14.
//  Copyright (c) 2014 mlyixi. All rights reserved.
//

#import "DragDropImageView.h"

@implementation DragDropImageView

@synthesize delegate;
- (id)initWithCoder:(NSCoder *)coder
{
    self=[super initWithCoder:coder];
    if ( self ) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    highlight=NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    highlight=NO;
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if ( highlight ) {
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: dirtyRect];
    }
}

@end
