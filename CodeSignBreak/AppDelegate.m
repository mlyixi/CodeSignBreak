//
//  AppDelegate.m
//  CodeSignBreak
//
//  Created by mlyixi on 11/15/14.
//  Copyright (c) 2014 mlyixi. All rights reserved.
//

#import "AppDelegate.h"
#import <Security/Security.h>
#import <XcodeKit/XcodeKit.h>

@interface AppDelegate ()
{
    SecCertificateRef cert;
    NSDictionary* certDict;
}
@property (weak) IBOutlet NSButton *patchCheck;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
NSString *kSDKSettingsString=@"/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.1.sdk/SDKSettings.plist";
NSString *kInfoString=@"/Contents/Developer/Platforms/iPhoneOS.platform/Info.plist";
NSString *kEntitleString=@"/Contents/Developer/iphoneentitlements";


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSString* certPath = [[NSBundle mainBundle] pathForResource:@"iPhoneDeveloper" ofType:@"cer"];
    NSData* certData = [NSData dataWithContentsOfFile:certPath];
    if( [certData length] ) {
        cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
        if( cert != NULL ) {
            certDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (id)kSecClassCertificate, kSecClass,
                                  cert, kSecValueRef,
                                  nil];
        } else {
            NSLog(@" *** ERROR *** trying to create certificate from data, but failed");
        }
    }
}

- (void)addCertificate
{
    if( cert != NULL ) {
        CFTypeRef result;
        OSStatus err = noErr;
        err = SecItemAdd((__bridge CFDictionaryRef)certDict, &result);
        assert(err == noErr || err == errSecDuplicateItem);
    }
}

- (void)deleteCertificate
{
    if( cert != NULL ) {
        OSStatus err = noErr;
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               kSecClassCertificate, kSecClass,
                               [NSArray arrayWithObject:(__bridge id)cert], kSecMatchItemList,
                               kSecMatchLimitOne, kSecMatchLimit,
                               nil];
        err = SecItemDelete((__bridge CFDictionaryRef)query);
        assert(err == noErr || err == errSecDuplicateItem);
    }
}

-(void)dragFinished:(NSString *)filePath patchProject:(BOOL)project
{
    if (!project) {
        // xcode.app here
        if (self.patchCheck.state!=NSOnState) {
            //  xcode.app patch here
            [self checkExitsAndPermission:filePath];
            [self addCertificate];
            [self patchInfo:filePath];
            [self patchSDKSettings:filePath];
            [self patchEntitlement:filePath];
        }else{
            // xcode.app unpatch here
            [self checkExitsAndPermission:filePath];
            [self deleteCertificate];
            [self unpatchInfo:filePath];
            [self unpatchSDKSettings:filePath];
            [self unpatchEntitlement:filePath];
        }
    }else
    {
        // project here
        if (self.patchCheck.state!=NSOnState) {
            // project path here
            [self patchProject:filePath];
        }else{
            // project unpatch here
            [self unpatchProject:filePath];
        }
    }
}

-(void)checkExitsAndPermission:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error=nil;
    NSDictionary *attributes=[fileManager attributesOfItemAtPath:filePath error:&error];
    NSString *fileOwner=[attributes fileOwnerAccountName];
    assert(fileOwner==NSUserName());
    
    NSString *infoPath=[filePath stringByAppendingPathComponent:kInfoString];
    assert([fileManager fileExistsAtPath:infoPath]==YES);
    assert([fileManager isWritableFileAtPath:infoPath]==YES);
}

-(void)patchSDKSettings:(NSString *)filePath
{
    NSString *sdkPath=[filePath stringByAppendingPathComponent:kSDKSettingsString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    assert([fileManager fileExistsAtPath:sdkPath]==YES);
    NSMutableDictionary *sdkDict=[[NSMutableDictionary alloc] initWithContentsOfFile:sdkPath];
    NSMutableDictionary *DefaultProperties=[sdkDict valueForKey:@"DefaultProperties"];
    
    [DefaultProperties setObject:@"NO" forKey:@"CODE_SIGNING_REQUIRED"];
    [DefaultProperties setObject:@"NO" forKey:@"ENTITLEMENTS_REQUIRED"];
    [sdkDict writeToFile:sdkPath atomically:YES];
    
}

-(void)unpatchSDKSettings:(NSString *)filePath
{
    NSString *sdkPath=[filePath stringByAppendingPathComponent:kSDKSettingsString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    assert([fileManager fileExistsAtPath:sdkPath]==YES);
    NSMutableDictionary *sdkDict=[[NSMutableDictionary alloc] initWithContentsOfFile:sdkPath];
    NSMutableDictionary *DefaultProperties=[sdkDict valueForKey:@"DefaultProperties"];
    
    [DefaultProperties setObject:@"YES" forKey:@"CODE_SIGNING_REQUIRED"];
    [DefaultProperties setObject:@"YES" forKey:@"ENTITLEMENTS_REQUIRED"];
    [sdkDict writeToFile:sdkPath atomically:YES];
    
}

-(void)patchInfo:(NSString *)filePath
{
    NSString *infoPath=[filePath stringByAppendingPathComponent:kInfoString];
    NSMutableDictionary *infoDict=[[NSMutableDictionary alloc] initWithContentsOfFile:infoPath];
    [infoDict setObject:@"NO" forKey:@"PROVISIONING_PROFILE_ALLOWED"];
    [infoDict setObject:@"NO" forKey:@"PROVISIONING_PROFILE_REQUIRED"];
    
   
    NSMutableDictionary *DefaultProperties=[infoDict valueForKey:@"DefaultProperties"];
    [DefaultProperties setObject:@"XCCodeSignContext" forKey:@"CODE_SIGN_CONTEXT_CLASS"];
    
    NSMutableDictionary *OverrideProperties=[infoDict valueForKey:@"OverrideProperties"];
    [OverrideProperties setObject:@"XCCodeSignContext" forKey:@"CODE_SIGN_CONTEXT_CLASS"];
    
    NSMutableDictionary *RuntimeRequirements=[infoDict valueForKey:@"RuntimeRequirements"];
    NSMutableArray *rqArray=[RuntimeRequirements valueForKey:@"Classed"];
    [rqArray replaceObjectAtIndex:0 withObject:@"XCCodeSignContext"];
    
    [infoDict writeToFile:infoPath atomically:YES];

}

-(void)unpatchInfo:(NSString *)filePath
{
    NSString *infoPath=[filePath stringByAppendingPathComponent:kInfoString];
    NSMutableDictionary *infoDict=[[NSMutableDictionary alloc] initWithContentsOfFile:infoPath];
    [infoDict removeObjectForKey:@"PROVISIONING_PROFILE_ALLOWED"];
    [infoDict removeObjectForKey:@"PROVISIONING_PROFILE_REQUIRED"];
    
    NSMutableDictionary *DefaultProperties=[infoDict valueForKey:@"DefaultProperties"];
    [DefaultProperties setObject:@"XCiPhoneOSCodeSignContext" forKey:@"CODE_SIGN_CONTEXT_CLASS"];
    
    NSMutableDictionary *OverrideProperties=[infoDict valueForKey:@"OverrideProperties"];
    [OverrideProperties setObject:@"XCiPhoneOSCodeSignContext" forKey:@"CODE_SIGN_CONTEXT_CLASS"];
    
    NSMutableDictionary *RuntimeRequirements=[infoDict valueForKey:@"RuntimeRequirements"];
    NSMutableArray *rqArray=[RuntimeRequirements valueForKey:@"Classed"];
    [rqArray replaceObjectAtIndex:0 withObject:@"XCiPhoneOSCodeSignContext"];
    
    [infoDict writeToFile:infoPath atomically:YES];
}

-(void)patchEntitlement:(NSString *)filePath
{
    NSString *entitlePath=[filePath stringByAppendingPathComponent:kEntitleString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:entitlePath]) {
        [fileManager createDirectoryAtPath:entitlePath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *txtFile=[[NSBundle mainBundle] pathForResource:@"Entitlements" ofType:@"txt"];
        NSString *pyFile=[entitlePath stringByAppendingPathComponent:@"Entitlements.py"];
        [fileManager copyItemAtPath:txtFile toPath:pyFile error:nil];
    };
}

-(void)unpatchEntitlement:(NSString *)filePath
{
    NSString *entitlePath=[filePath stringByAppendingPathComponent:kEntitleString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:entitlePath]) {
        [fileManager removeItemAtPath:entitlePath error:nil];
    };
}

-(void)patchProject:(NSString *)projectPath
{
    @try {
        XCObjectRegistry *registry = [XCObjectRegistry objectRegistryWithXcodeProject:projectPath];
        for (XCTarget *target in registry.project.targets) {
            for (XCConfiguration *config in target.configurationList.configurations) {
                [config.buildSettings setObject:@"" forKey:XCConfigurationPropertyCodeSignIdentity];
                [registry setResourceObject:config];
            }
            
        }
        NSString *scriptPath=[[NSBundle mainBundle] pathForResource:@"runscript" ofType:@"txt"];
        NSError *error=nil;
        NSString *script= [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:&error];
        XCRunScriptBuildPhase *rsb=[XCRunScriptBuildPhase createRunScriptBuildPhaseWithScript:script inRegistry:registry];
        for (XCTarget *target in registry.project.targets) {
            [target addBuildPhase:rsb];
            [registry setResourceObject:target];
        }
        
        [registry save];
        
    } @catch (NSException *exception) {
        NSLog(@"Could not parse pbxproj: %@",exception.description);
    }
}

-(void)unpatchProject:(NSString *)projectPath
{
    @try {
        XCObjectRegistry *registry = [XCObjectRegistry objectRegistryWithXcodeProject:projectPath];
        for (XCTarget *target in registry.project.targets) {
            for (XCConfiguration *config in target.configurationList.configurations) {
                [config.buildSettings removeObjectForKey:XCConfigurationPropertyCodeSignIdentity];
                [registry setResourceObject:config];
            }
        }

        for (XCTarget *target in registry.project.targets) {
            for (XCBuildPhase *bp in target.buildPhases) {
                if ([bp.type isEqualToString: @"PBXShellScriptBuildPhase"]) {
                    [target removeBuildPhase:bp];
                }
            }
        }
        
        [registry save];
        
    } @catch (NSException *exception) {
        NSLog(@"Could not parse pbxproj: %@",exception.description);
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    CFRelease(cert);
    return YES;
}
@end
