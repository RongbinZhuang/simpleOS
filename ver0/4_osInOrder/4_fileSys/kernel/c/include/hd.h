#ifndef _MY_HD_H_
#define _MY_HD_H_
#include "type.h"
#include "global.h"

extern int     printf(const char *fmt, ...);
extern int  get_ticks();
extern int	send_recv(int function, int src_dest, MESSAGE* msg);
extern void spin(char * func_name);
extern void	dump_msg(const char * title, MESSAGE* m);
extern void put_irq_handler(int irq, irq_handler handler);
extern void	enable_irq(int irq);
extern void	port_read(u16 port, void* buf, int n);
extern void panic(const char *fmt, ...);
extern void	out_byte(u16 port, u8 value);
extern u8	in_byte(u16 port);
extern void	inform_int(int task_nr);

#endif
