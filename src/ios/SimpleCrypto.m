/********* SimpleCrypto.m Cordova Plugin Implementation *******/

#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>
#import <Cordova/CDV.h>
#import "NSData+Base64.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"


@interface SimpleCrypto : CDVPlugin {
}

- (void)encrypt:(CDVInvokedUrlCommand*)command;
- (void)decrypt:(CDVInvokedUrlCommand*)command;
- (void)removeFiles:(CDVInvokedUrlCommand*)command;

@end

@implementation SimpleCrypto

- (void)encrypt:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;

        NSString *key = [command.arguments objectAtIndex:0];
        NSString *originFilePath = [command.arguments objectAtIndex:1];
        NSString *encryptedFilePath = [command.arguments objectAtIndex:2];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *accessibleOriginFilePath = [documentsPath stringByAppendingPathComponent:originFilePath];
        NSString *accessibleEncryptedFilePath = [documentsPath stringByAppendingPathComponent:encryptedFilePath];

        if (originFilePath != nil && [originFilePath length] > 0 && key != nil && [key length] > 0) {

            NSData *parsedDataToEncrypt = [NSData dataWithContentsOfFile:accessibleOriginFilePath];
            NSError *error;
            NSData *encryptedData = [RNEncryptor encryptData:parsedDataToEncrypt
                                                withSettings:kRNCryptorAES256Settings
                                                    password:key
                                                       error:&error];

            NSLog(@"Encryption Key: %@", key);
            NSLog(@"Encrypted");
            [encryptedData writeToFile:accessibleEncryptedFilePath atomically:YES];
            NSLog(@"Encrypted file writed");

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Successfull encrypt"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Nothing to encrypt"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)decrypt:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;

        NSString *key = [command.arguments objectAtIndex:0];
        NSString *encryptedFilePath = [command.arguments objectAtIndex:1];
        NSString *originFilePath = [command.arguments objectAtIndex:2];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *accessibleOriginFilePath = [documentsPath stringByAppendingPathComponent:originFilePath];
        NSString *accessibleEncryptedFilePath = [documentsPath stringByAppendingPathComponent:encryptedFilePath];


        if (encryptedFilePath != nil && [encryptedFilePath length] > 0 && key != nil && [key length] > 0) {

            NSData *parsedDataToDecrypt = [NSData dataWithContentsOfFile:accessibleEncryptedFilePath];
            NSError *error;
            NSData *decryptedData = [RNDecryptor decryptData:parsedDataToDecrypt
                                                withPassword:key
                                                       error:&error];

            NSLog(@"Decryption Key: %@", key);
            NSLog(@"Decrypted success");
            [decryptedData writeToFile:accessibleOriginFilePath atomically:YES];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Decrypted"];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Nothing to decrypt"];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeFiles:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{

        CDVPluginResult* pluginResult = nil;

        NSString *originFilePath = [command.arguments objectAtIndex:0];
        NSString *contain = [command.arguments objectAtIndex:1];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *accessibleOriginFilePath = [documentsPath stringByAppendingPathComponent:originFilePath];
        NSError *error = nil;

        // For each file in the directory, create full path and delete the file
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:accessibleOriginFilePath error:&error])
        {
            NSString *filePath = [accessibleOriginFilePath stringByAppendingPathComponent:file];
            NSLog(@"Files : %@", filePath);

            if ([filePath rangeOfString:contain].location == NSNotFound) {
                NSLog(@"Keep %@", filePath);
            } else {
                NSLog(@"Remove %@", filePath);
                BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
            }
        }

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Remove mp3 file done"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
