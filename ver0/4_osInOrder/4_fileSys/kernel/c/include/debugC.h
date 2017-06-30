#ifndef _MY_DEBUG_H
#define _MY_DEBUG_H

#include "type.h"
#include "global.h"

extern int printf(const char*,...);
extern int vsprintf(char *buf, const char *fmt, va_list args);

#define ASSERT
#ifdef ASSERT
void assertion_failure(char *exp, char *file, char *base_file, int line);
#define assert(exp)  if (exp) ; \
        else assertion_failure(#exp, __FILE__, __BASE_FILE__, __LINE__)
#else
#define assert(exp)
#endif

void panic(const char *fmt, ...);

//void assertion_failure(char *exp, char *file, char *base_file, int line);
#endif
