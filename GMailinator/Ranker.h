//
//  Ranker.h
//  Nostalgy4MailApp
//
//  Created by Jelmer van der Linde on 23-08-12.
//
//

#ifndef __Nostalgy4MailApp__Ranker__
#define __Nostalgy4MailApp__Ranker__

#ifdef __cplusplus
extern "C" {
#endif

bool is_subset (NSString *needle, NSString *haystack);

double calculate_rank (NSString *left, NSString *right);
    
#ifdef __cplusplus
}
#endif

#endif /* defined(__Nostalgy4MailApp__Ranker__) */
