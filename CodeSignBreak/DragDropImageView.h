//
//  DragDropImageView.h
//  CodeSignBreak
//
//  Created by mlyixi on 11/17/14.
//  Copyright (c) 2014 mlyixi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@protocol DragDropImageViewDelegate

- (void)dragFinished:(NSString *)filePath patchProject:(BOOL)project;

@end

@interface DragDropImageView : NSImageView <NSDraggingDestination>
{
    NSString *path;
    BOOL highlight;
}

@property(nonatomic,assign) IBOutlet id <DragDropImageViewDelegate> delegate;

- (id)initWithCoder:(NSCoder *)coder;

@end
