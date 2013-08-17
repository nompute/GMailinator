//
//  Ranker.cpp
//  Nostalgy4MailApp
//
//  Created by Jelmer van der Linde on 23-08-12.
//  Taken from https://github.com/textmate/textmate/blob/master/Frameworks/text/src/ranker.cc
//
//

#include <algorithm>

#include "Ranker.h"

bool is_subset (NSString *needle, NSString *haystack)
{
	NSInteger n = 0, m = 0;
    char const *needle_chars = [needle UTF8String];
    char const *haystack_chars = [haystack UTF8String];
    
	while (n < [needle length] && m < [haystack length])
	{
		if(needle_chars[n] == haystack_chars[m] || toupper(needle_chars[n]) == haystack_chars[m])
			++n;
		++m;
	}
	
    return n == [needle length];
}

double calculate_rank (NSString *left, NSString *right)
{
	size_t const n = [left length];
	size_t const m = [right length];
    
    char const *lhs = [left UTF8String];
    char const *rhs = [right UTF8String];
    
	size_t matrix[n][m], first[n], last[n];
	bool capitals[m];
	bzero(matrix, sizeof(matrix));
	std::fill_n(&first[0], n, m);
	std::fill_n(&last[0],  n, 0);
    
	bool at_bow = true;
	for(size_t j = 0; j < m; ++j)
	{
		char ch = rhs[j];
		capitals[j] = (at_bow && isalnum(ch)) || isupper(ch);
		at_bow = !isalnum(ch) && ch != '\'' && ch != '.';
	}
    
	for(size_t i = 0; i < n; ++i)
	{
		size_t j = i == 0 ? 0 : first[i-1] + 1;
		for(; j < m; ++j)
		{
			if(tolower(lhs[i]) == tolower(rhs[j]))
			{
				matrix[i][j] = i == 0 || j == 0 ? 1 : matrix[i-1][j-1] + 1;
				first[i]     = std::min(j, first[i]);
				last[i]      = std::max(j+1, last[i]);
			}
		}
	}
    
	for(ssize_t i = n-1; i > 0; --i)
	{
		size_t bound = last[i]-1;
		if(bound < last[i-1])
		{
			while(first[i-1] < bound && matrix[i-1][bound-1] == 0)
				--bound;
			last[i-1] = bound;
		}
	}
    
	for(ssize_t i = n-1; i > 0; --i)
	{
		for(size_t j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] && matrix[i-1][j-1])
				matrix[i-1][j-1] = matrix[i][j];
		}
	}
    
	for(size_t i = 0; i < n; ++i)
	{
		for(size_t j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] > 1 && i+1 < n && j+1 < m)
				matrix[i+1][j+1] = matrix[i][j] - 1;
		}
	}
    
	// =========================
	// = Greedy walk of Matrix =
	// =========================
    
	size_t capitalsTouched = 0; // 0-n
	size_t substrings = 0;      // 1-n
	size_t prefixSize = 0;      // 0-m
    
	size_t i = 0;
	while(i < n)
	{
		size_t bestJIndex = 0;
		size_t bestJLength = 0;
		for(size_t j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] && capitals[j])
			{
				bestJIndex = j;
				bestJLength = matrix[i][j];
                
				for(size_t k = j; k < j + bestJLength; ++k)
					capitalsTouched += capitals[k] ? 1 : 0;
                
				break;
			}
			else if(bestJLength < matrix[i][j])
			{
				bestJIndex = j;
				bestJLength = matrix[i][j];
			}
		}
        
		if(i == 0)
			prefixSize = bestJIndex;
        
		size_t len = 0;
		bool foundCapital = false;
		do {
            
			++i; ++len;
			first[i] = std::max(bestJIndex + len, first[i]);
			if(len < bestJLength && n < 4)
			{
				if(capitals[first[i]])
					continue;
                
				for(size_t j = first[i]; j < last[i] && !foundCapital; ++j)
				{
					if(matrix[i][j] && capitals[j])
						foundCapital = true;
				}
			}
            
		} while(len < bestJLength && !foundCapital);
                
		++substrings;
	}
    
	// ================================
	// = Calculate rank based on walk =
	// ================================
    
	size_t totalCapitals = std::count(&capitals[0], &capitals[0] + m, true);
	double score = 0.0;
	double denom = n*(n+1) + 1;
	if(n == capitalsTouched)
	{
		score = (denom - 1) / denom;
	}
	else
	{
		double subtract = substrings * n + (n - capitalsTouched);
		score = (denom - subtract) / denom;
	}
	score += (m - prefixSize) / (double)m / (2*denom);
	score += capitalsTouched / (double)totalCapitals / (4*denom);
	score += n / (double)m / (8*denom);
    
	return score;
}

