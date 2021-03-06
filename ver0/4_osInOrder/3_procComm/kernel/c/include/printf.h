#ifndef _MY_PRINTF_H
#define _MY_PRINTF_H

#include "type.h"
#include "global.h"
extern void write(char *buf,int len);
extern void itoa(char*,int);
extern void strcpy(char*,char*);
extern int strlen(char*);
extern int printx(char*);
extern void	memset(void* p_dst, char ch, int size);

int printf(const char * fmt,...);
int vsprintf(char *buf, const char *fmt, va_list args);

#endif 
