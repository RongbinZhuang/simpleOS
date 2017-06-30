#ifndef _MY_FILESYS_H_
#define _MY_FILESYS_H_
#include "type.h"
#include "global.h"

extern int     printf(const char *fmt, ...);
extern void spin(char * func_name);
extern int	send_recv(int function, int src_dest, MESSAGE* msg);

#endif
