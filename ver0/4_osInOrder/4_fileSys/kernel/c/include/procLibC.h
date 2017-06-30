#ifndef _MY_PROCLIB_H
#define _MY_PROCLIB_H

#include "global.h"
#include "type.h"

extern void assertion_failure(char *exp, char *file, char *base_file, int line);
#define assert(exp)  if (exp) ; \
        else assertion_failure(#exp, __FILE__, __BASE_FILE__, __LINE__)

extern void disp_str(char*);
extern void*	memcpy(void* p_dst, void* p_src, int size);
extern void	memset(void* p_dst, char ch, int size);
extern void disable_int();
extern int	sendrec(int function, int src_dest, MESSAGE* p_msg);
extern void panic(const char*fmt,...);
extern int     printf(const char *fmt, ...);

extern int k_reenter;
extern DESCRIPTOR gdt[];
extern PROCESS proc_table[];
extern TTY tty_table[];
extern TSS tss;
extern PROCESS* p_proc_ready;
extern char	task_stack[];
extern void out_char(CONSOLE*,char);

void init_descriptor(DESCRIPTOR *p_desc,u32 base,u32 limit,u16 attribute);
u32 seg2phys(u16 seg);
void schedule();
int	sys_sendrec(int function, int src_dest, MESSAGE* m, struct proc* p);
int	sys_printx(int _unused1, int _unused2, char* s, struct proc * p_proc);
int send_recv(int function, int src_dest, MESSAGE* msg);
void dump_msg(const char * title, MESSAGE* m);
void inform_int(int task_nr);

#endif

