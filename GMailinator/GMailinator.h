//
//  NoFlaggedMailbox.h
//  NoFlaggedMailbox
//
//  Created by Eelco Lempsink on 28-09-12.
//  Copyright (c) 2012 Eelco Lempsink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchManager.h"

@interface GMailinator : NSObject {
    SearchManager* sm;
}

+ (void)registerBundle;
@end

NSBundle *GetGMailinatorBundle(void);