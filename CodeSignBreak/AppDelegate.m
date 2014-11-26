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
NSString *kSDKsPath=@"/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs";
NSString *kSDKSetting=@"/SDKSettings.plist";
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
        
        // delete all iphone developer certifications.
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               kSecClassCertificate, kSecClass,
                               [NSArray arrayWithObject:(__bridge id)cert], kSecMatchItemList,
                               kSecMatchLimitOne, kSecMatchLimit,
                               nil];
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status==noErr) {
            err = SecItemDelete((__bridge CFDictionaryRef)query);
            assert(err == noErr || err == errSecDuplicateItem);
        }
        // add iphone developer certifications.
        err = SecItemAdd((__bridge CFDictionaryRef)certDict, &result);
        assert(err == noErr || err == errSecDuplicateItem);
    }
}

- (void)deleteCertificate
{
    // delete all iphone developer certifications.
    if( cert != NULL ) {
        OSStatus err = noErr;
        NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                               kSecClassCertificate, kSecClass,
                               [NSArray arrayWithObject:(__bridge id)cert], kSecMatchItemList,
                               kSecMatchLimitOne, kSecMatchLimit,
                               nil];
        CFArrayRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status==noErr) {
            err = SecItemDelete((__bridge CFDictionaryRef)query);
            assert(err == noErr || err == errSecDuplicateItem);
        }
    }
}

-(void)killProcessesNamed:(NSString*)appName
{
    for ( NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications] )
    {
        if ( [[[app executableURL] lastPathComponent] containsString:appName] )
        {
            [app terminate];
        }
    }
}
-(void)dragFinished:(NSString *)filePath patchProject:(BOOL)project
{
//    [self killProcessesNamed:@"Xcode"];
    if (!project) {
        // xcode.app here
        if (self.patchCheck.state!=NSOnState) {
            //  xcode.app patch here
            if ([self checkExistsAndPermission:filePath]) {
                [self addCertificate];
                [self patchInfo:filePath];
                [self patchEntitlement:filePath];
                
                [self patchSDKSettings:filePath];
            }
        }else{
            // xcode.app unpatch here
            if ([self checkExistsAndPermission:filePath]) {
                [self deleteCertificate];
                [self unpatchInfo:filePath];
                [self unpatchEntitlement:filePath];
                
                [self unpatchSDKSettings:filePath];
            }
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

-(BOOL)checkExistsAndPermission:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *infoPath=[filePath stringByAppendingPathComponent:kInfoString];
    if (![fileManager fileExistsAtPath:infoPath]) {
        NSAlert *alert=[[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Are you sure you dragged the Xcode?"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return NO;
    }
    NSError *error=nil;
    NSDictionary *attributes=[fileManager attributesOfItemAtPath:filePath error:&error];
    NSString *fileOwner=[attributes fileOwnerAccountName];
    if (fileOwner!=NSUserName()&&![fileManager isWritableFileAtPath:infoPath]) {
        NSAlert *alert=[[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"You are not the owner of Xcode or have no write permission.\n\r Run \"sudo chown -R $USER /Applications/Xcode.app\""];
        [alert addButtonWithTitle:@"Cancel"];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return NO;
    }
    return YES;
}

-(void)patchSDKSettings:(NSString *)filePath
{
    NSString *sdkPath=[filePath stringByAppendingPathComponent:kSDKsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    assert([fileManager fileExistsAtPath:sdkPath]==YES);
    NSArray *dirContents=[fileManager contentsOfDirectoryAtPath:sdkPath error:nil];
    for (NSString *sdk in dirContents) {
        NSString *sdkSettingPath=[[sdkPath stringByAppendingPathComponent:sdk] stringByAppendingPathComponent:kSDKSetting];
        NSMutableDictionary *sdkSettingDict=[[NSMutableDictionary alloc] initWithContentsOfFile:sdkSettingPath];
        NSMutableDictionary *DefaultProperties=[sdkSettingDict valueForKey:@"DefaultProperties"];
        [DefaultProperties setObject:@"NO" forKey:@"CODE_SIGNING_REQUIRED"];
        [DefaultProperties setObject:@"NO" forKey:@"ENTITLEMENTS_REQUIRED"];
        [sdkSettingDict writeToFile:sdkSettingPath atomically:YES];
    }
}

-(void)unpatchSDKSettings:(NSString *)filePath
{
    NSString *sdkPath=[filePath stringByAppendingPathComponent:kSDKsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    assert([fileManager fileExistsAtPath:sdkPath]==YES);
    NSArray *dirContents=[fileManager contentsOfDirectoryAtPath:sdkPath error:nil];
    for (NSString *sdk in dirContents) {
        NSString *sdkSettingPath=[[sdkPath stringByAppendingPathComponent:sdk] stringByAppendingPathComponent:kSDKSetting];
        NSMutableDictionary *sdkSettingDict=[[NSMutableDictionary alloc] initWithContentsOfFile:sdkSettingPath];
        NSMutableDictionary *DefaultProperties=[sdkSettingDict valueForKey:@"DefaultProperties"];
        
        [DefaultProperties setObject:@"YES" forKey:@"CODE_SIGNING_REQUIRED"];
        [DefaultProperties setObject:@"YES" forKey:@"ENTITLEMENTS_REQUIRED"];
        [sdkSettingDict writeToFile:sdkSettingPath atomically:YES];
    }    
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
        NSString *pyFile=[entitlePath stringByAppendingPathComponent:@"gen_entitlements.py"];
        [fileManager copyItemAtPath:txtFile toPath:pyFile error:nil];
        NSDictionary *attributes=@{NSFilePosixPermissions:[NSNumber numberWithShort:0777]};
        [fileManager setAttributes:attributes ofItemAtPath:pyFile error:nil];
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
