#include "tty.h"

#define TTY_FIRST	(tty_table)
#define TTY_END		(tty_table + NR_CONSOLES)

static void init_tty(TTY* p_tty);
static void tty_do_read(TTY* p_tty);
static void tty_do_write(TTY* p_tty);
static void put_key(TTY* p_tty, u32 key);

void task_tty()
{
	TTY*	p_tty; 

	init_keyboard();

	for (p_tty=TTY_FIRST;p_tty<TTY_END;p_tty++) {
		init_tty(p_tty);
	}
	select_console(0);
	while (1) {
		for (p_tty=TTY_FIRST;p_tty<TTY_END;p_tty++) {
			tty_do_read(p_tty);
			tty_do_write(p_tty);
		}
	}
}

void in_process(TTY* p_tty,u32 key)
{
     char output[2] = {'\0', '\0'};

        if (!(key & FLAG_EXT)) 
		{
			if (p_tty->inbuf_count < TTY_IN_BYTES) {
				*(p_tty->p_inbuf_head) = key;
				p_tty->p_inbuf_head++;
				if (p_tty->p_inbuf_head == p_tty->in_buf + TTY_IN_BYTES) {
					p_tty->p_inbuf_head = p_tty->in_buf;
				}
			p_tty->inbuf_count++;
		}
        }
        else {
                int raw_code = key & MASK_RAW;
                switch(raw_code) {
                case ENTER:
			put_key(p_tty, '\n');
			break;
                case BACKSPACE:
			put_key(p_tty, '\b');
			break;
                case UP:
                        if ((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
				scroll_screen(p_tty->p_console, SCR_DN);
                        }
			break;
			case DOWN:
				if ((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {
					scroll_screen(p_tty->p_console, SCR_UP);
				}
				break;
		case F1:
				break;
		case F2:
				break;
		case F3:
			if ((key & FLAG_ALT_L) || (key & FLAG_ALT_R)) {
				select_console(0);
			}
			break;
		case F4:
				break;
		case F5:
			if ((key & FLAG_ALT_L) || (key & FLAG_ALT_R)) {
				select_console(1);
			}
			break;
		case F6:
			if ((key & FLAG_ALT_L) || (key & FLAG_ALT_R)) {
				select_console(2);
			}
			break;
		case F7:
				break;
		case F8:
				break;
		case F9:
				break;
		case F10:
				break;
		case F11:
				break;
		case F12:
				break;
			/* Alt + F1~F12 */
                default:
                        break;
                }
        }
}

static void tty_do_read(TTY* p_tty)
{
	if (is_current_console(p_tty->p_console)) {
		keyboard_read(p_tty);
	}
}

static void tty_do_write(TTY* p_tty)
{
	if (p_tty->inbuf_count) {
		char ch = *(p_tty->p_inbuf_tail);
		p_tty->p_inbuf_tail++;
		if (p_tty->p_inbuf_tail == p_tty->in_buf + TTY_IN_BYTES) {
			p_tty->p_inbuf_tail = p_tty->in_buf;
		}
		p_tty->inbuf_count--;

		out_char(p_tty->p_console, ch);
	}
}

static void init_tty(TTY* p_tty)
{
	p_tty->inbuf_count = 0;
	p_tty->p_inbuf_head = p_tty->p_inbuf_tail = p_tty->in_buf;
	init_screen(p_tty);
}


static void put_key(TTY* p_tty, u32 key)
{
	if (p_tty->inbuf_count < TTY_IN_BYTES) {
		*(p_tty->p_inbuf_head) = key;
		p_tty->p_inbuf_head++;
		if (p_tty->p_inbuf_head == p_tty->in_buf + TTY_IN_BYTES) {
			p_tty->p_inbuf_head = p_tty->in_buf;
		}
		p_tty->inbuf_count++;
	}
}

void tty_write(TTY* p_tty, char* buf, int len)
{
	char* p = buf;
	int i = len;

	while (i) {
		out_char(p_tty->p_console, *p++);
		//disp_str((char*)"B");
		i--;
	}
}

/*======================================================================*
                              sys_write
*======================================================================*/
int sys_write(char* buf, int len, PROCESS* p_proc)
{
	tty_write(&tty_table[p_proc->nr_tty], buf, len);
	return 0;
}

