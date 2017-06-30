#ifndef _MY_KEYBOARDLIB_H
#define _MY_KEYBOARDLIB_H

#include "type.h"
#include "global.h"
#include "keymap.h"

extern void disp_str(char*);
extern void disp_int(int);
extern void put_irq_handler(int irq, irq_handler handler);
extern void enable_irq(int);
extern void disable_irq(int);
extern u8 in_byte(u16 port);
extern void keyboard_read();
extern void disable_int();
extern void enable_int();
extern irq_handler irq_table[];
extern void in_process(TTY*,u32 key);

void init_keyboard();
void keyboard_handler(int irq);
typedef struct s_kb {
	char*	p_head;			/* 指向缓冲区中下一个空闲位置 */
	char*	p_tail;			/* 指向键盘任务应处理的字节 */
	int	count;			/* 缓冲区中共有多少字节 */
	char	buf[KB_IN_BYTES];	/* 缓冲区 */
}KB_INPUT;

#endif
