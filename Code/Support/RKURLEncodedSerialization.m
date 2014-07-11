//
//  RKURLEncodedSerialization.m
//  RestKit
//
//  Created by Blake Watters on 9/4/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKURLEncodedSerialization.h"
#import "CMDQueryStringSerialization.h"

@implementation RKURLEncodedSerialization

+ (id)objectFromData:(NSData *)data error:(NSError **)error
{
    NSString *string = [NSString stringWithUTF8String:[data bytes]];
    return RKDictionaryFromURLEncodedStringWithEncoding(string, NSUTF8StringEncoding);
}

+ (NSData *)dataFromObject:(id)object error:(NSError **)error
{
    NSString *string = RKURLEncodedStringFromDictionaryWithEncoding(object, NSUTF8StringEncoding);
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

NSDictionary *RKDictionaryFromURLEncodedStringWithEncoding(NSString *URLEncodedString, NSStringEncoding encoding)
{
    return [CMDQueryStringSerialization dictionaryWithQueryString:URLEncodedString];
}

NSString *RKURLEncodedStringFromDictionaryWithEncoding(NSDictionary *dictionary, NSStringEncoding encoding)
{
    return [CMDQueryStringSerialization queryStringWithDictionary:dictionary];
}

// This replicates `AFPercentEscapedQueryStringPairMemberFromStringWithEncoding`. Should send PR exposing non-static version
NSString *RKPercentEscapedQueryStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding)
{
    // Escape characters that are legal in URIs, but have unintentional semantic significance when used in a query string parameter
    static NSString * const kAFLegalCharactersToBeEscaped = @":/.?&=;+!@$()~";

	return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}

NSDictionary *RKQueryParametersFromStringWithEncoding(NSString *string, NSStringEncoding encoding)
{
    NSRange chopRange = [string rangeOfString:@"?"];
    if (chopRange.length > 0) {
        chopRange.location += 1; // we want inclusive chopping up *through *"?"
        if (chopRange.location < [string length]) string = [string substringFromIndex:chopRange.location];
    }
    return RKDictionaryFromURLEncodedStringWithEncoding(string, encoding);
}
