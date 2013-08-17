//
//  NSArray+reverse.m
//  Nostalgy4MailApp
//
//  Created by Jelmer van der Linde on 25-08-12.
//
//

#import "NSArray+reverse.h"

@implementation NSArray (reverse)

- (NSArray *)reversed
{
    return [[self reverseObjectEnumerator] allObjects];
}

@end
