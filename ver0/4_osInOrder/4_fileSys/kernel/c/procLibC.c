#include "procLibC.h"

static void block(struct proc* p);
static void unblock(struct proc* p);
static int  msg_send(struct proc* current, int dest, MESSAGE* m);
static int  msg_receive(struct proc* current, int src, MESSAGE* m);
static int  deadlock(int src, int dest);

void initProc()
{
	disp_str((char*)"initProc entered\n");
	/* 填充 GDT 中 TSS 这个描述符 */
	memset(&tss, 0, sizeof(tss));
	tss.ss0 = SELECTOR_KERNEL_DS;
	init_descriptor(&gdt[INDEX_TSS],
			vir2phys(seg2phys(SELECTOR_KERNEL_DS), &tss),
			sizeof(tss) - 1,
			DA_386TSS);
	tss.iobase = sizeof(tss); /* 没有I/O许可位图 */



	/* 填充 GDT 中进程的 LDT 的描述符 */
	PROCESS* p_proc	= proc_table;
	u16 selector_ldt = INDEX_LDT_FIRST << 3;
	for(int i=0;i<NR_TASKS+NR_PROCS;i++){
		init_descriptor(&gdt[selector_ldt>>3],
				vir2phys(seg2phys(SELECTOR_KERNEL_DS),
					proc_table[i].ldts),
				LDT_SIZE * sizeof(DESCRIPTOR) - 1,
				DA_LDT);
		p_proc++;
		selector_ldt += 1 << 3;
	}
}

void init_descriptor(DESCRIPTOR *p_desc,u32 base,u32 limit,u16 attribute)
{
	p_desc->limit_low	= limit & 0x0FFFF;
	p_desc->base_low	= base & 0x0FFFF;
	p_desc->base_mid	= (base >> 16) & 0x0FF;
	p_desc->attr1		= attribute & 0xFF;
	p_desc->limit_high_attr2= ((limit>>16) & 0x0F) | (attribute>>8) & 0xF0;
	p_desc->base_high	= (base >> 24) & 0x0FF;
}

u32 seg2phys(u16 seg)
{
	DESCRIPTOR* p_dest = &gdt[seg >> 3];
	return (p_dest->base_high<<24 | p_dest->base_mid<<16 | p_dest->base_low);
}

void schedule()
{
	struct proc*	p;
	int		greatest_ticks = 0;

	while (!greatest_ticks) {
		for (p = &FIRST_PROC; p <= &LAST_PROC; p++) {
			if (p->p_flags == 0) {
				if (p->ticks > greatest_ticks) {
					greatest_ticks = p->ticks;
					p_proc_ready = p;
				}
			}
		}

		if (!greatest_ticks)
			for (p = &FIRST_PROC; p <= &LAST_PROC; p++)
				if (p->p_flags == 0)
					p->ticks = p->priority;
	}
}

int ldt_seg_linear(struct proc* p, int idx)
{
	DESCRIPTOR* d = &p->ldts[idx];

	return d->base_high << 24 | d->base_mid << 16 | d->base_low;
}

void* va2la(int pid, void* va)
{
	struct proc* p = &proc_table[pid];

	u32 seg_base = ldt_seg_linear(p, INDEX_LDT_RW);
	u32 la = seg_base + (u32)va;

	if (pid < NR_TASKS + NR_PROCS) {
		//assert(la == (u32)va);
	}

	return (void*)la;
}


int	sys_sendrec(int function, int src_dest, MESSAGE* m, struct proc* p)
{
	assert(k_reenter == 0);	/* make sure we are not in ring0 */
	assert((src_dest >= 0 && src_dest < NR_TASKS + NR_PROCS) ||
	       src_dest == ANY ||
	       src_dest == INTERRUPT);

	int ret = 0;
	int caller = proc2pid(p);
	MESSAGE* mla = (MESSAGE*)va2la(caller, m);
	mla->source = caller;

	assert(mla->source != src_dest);

	/**
	 * Actually we have the third message type: BOTH. However, it is not
	 * allowed to be passed to the kernel directly. Kernel doesn't know
	 * it at all. It is transformed into a SEND followed by a RECEIVE
	 * by `send_recv()'.
	 */
	if (function == SEND) {
		ret = msg_send(p, src_dest, m);
		if (ret != 0)
			return ret;
	}
	else if (function == RECEIVE) {
		ret = msg_receive(p, src_dest, m);
		if (ret != 0)
			return ret;
	}
	else {
		panic("{sys_sendrec} invalid function: "
		      "%d (SEND:%d, RECEIVE:%d).", function, SEND, RECEIVE);
	}

	return 0;
};

int	sys_printx(int _unused1, int _unused2, char* s, struct proc * p_proc)
{
	const char * p;
	char ch;

	char reenter_err[] = "? k_reenter is incorrect for unknown reason";
	reenter_err[0] = MAG_CH_PANIC;

	/**
	 * @note Code in both Ring 0 and Ring 1~3 may invoke printx().
	 * If this happens in Ring 0, no linear-physical address mapping
	 * is needed.
	 *
	 * @attention The value of `k_reenter' is tricky here. When
	 *   -# printx() is called in Ring 0
	 *      - k_reenter > 0. When code in Ring 0 calls printx(),
	 *        an `interrupt re-enter' will occur (printx() generates
	 *        a software interrupt). Thus `k_reenter' will be increased
	 *        by `kernel.asm::save' and be greater than 0.
	 *   -# printx() is called in Ring 1~3
	 *      - k_reenter == 0.
	 */
	if (k_reenter == 0)  /* printx() called in Ring<1~3> */
		p = va2la(proc2pid(p_proc), s);
	else if (k_reenter > 0) /* printx() called in Ring<0> */
		p = s;
	else	/* this should NOT happen */
		p = reenter_err;

	/**
	 * @note if assertion fails in any TASK, the system will be halted;
	 * if it fails in a USER PROC, it'll return like any normal syscall
	 * does.
	 */
	if ((*p == MAG_CH_PANIC) ||
	    (*p == MAG_CH_ASSERT && p_proc_ready < &proc_table[NR_TASKS])) {
		disable_int();
		char * v = (char*)V_MEM_BASE;
		const char * q = p + 1; /* +1: skip the magic char */

		while (v < (char*)(V_MEM_BASE + V_MEM_SIZE)) {
			*v++ = *q++;
			*v++ = RED_CHAR;
			if (!*q) {
				while (((int)v - V_MEM_BASE) % (SCR_WIDTH * 16)) {
					/* *v++ = ' '; */
					v++;
					*v++ = GRAY_CHAR;
				}
				q = p + 1;
			}
		}

		__asm__ __volatile__("hlt");
	}

	while ((ch = *p++) != 0) {
		if (ch == MAG_CH_PANIC || ch == MAG_CH_ASSERT)
			continue; /* skip the magic char */

		out_char(tty_table[p_proc->nr_tty].p_console, ch);
	}

	return 0;
};

int send_recv(int function, int src_dest, MESSAGE* msg)
{
	int ret = 0;

	if (function == RECEIVE)
		memset(msg, 0, sizeof(MESSAGE));

	switch (function) {
	case BOTH:
		ret = sendrec(SEND, src_dest, msg);
		//disp_str((char*)"heihei");
		if (ret == 0)
			ret = sendrec(RECEIVE, src_dest, msg);
		break;
	case SEND:
	case RECEIVE:
		ret = sendrec(function, src_dest, msg);
		break;
	default:
		assert((function == BOTH) ||
		       (function == SEND) || (function == RECEIVE));
		break;
	}

	return ret;
}

void reset_msg(MESSAGE* p)
{
	memset(p, 0, sizeof(MESSAGE));
}

int msg_send(struct proc* current, int dest, MESSAGE* m)
{
	struct proc* sender = current;
	struct proc* p_dest = proc_table + dest; /* proc dest */

	assert(proc2pid(sender) != dest);

	/* check for deadlock here */
	if (deadlock(proc2pid(sender), dest)) {
		panic(">>DEADLOCK<< %s->%s", sender->p_name, p_dest->p_name);
	}

	if ((p_dest->p_flags & RECEIVING) && /* dest is waiting for the msg */
	    (p_dest->p_recvfrom == proc2pid(sender) ||
	     p_dest->p_recvfrom == ANY)) {
		assert(p_dest->p_msg);
		assert(m);

		phys_copy(va2la(dest, p_dest->p_msg),
			  va2la(proc2pid(sender), m),
			  sizeof(MESSAGE));
		p_dest->p_msg = 0;
		p_dest->p_flags &= ~RECEIVING; /* dest has received the msg */
		p_dest->p_recvfrom = NO_TASK;
		unblock(p_dest);

		assert(p_dest->p_flags == 0);
		assert(p_dest->p_msg == 0);
		assert(p_dest->p_recvfrom == NO_TASK);
		assert(p_dest->p_sendto == NO_TASK);
		assert(sender->p_flags == 0);
		assert(sender->p_msg == 0);
		assert(sender->p_recvfrom == NO_TASK);
		assert(sender->p_sendto == NO_TASK);
	}
	else { /* dest is not waiting for the msg */
		sender->p_flags |= SENDING;
		assert(sender->p_flags == SENDING);
		sender->p_sendto = dest;
		sender->p_msg = m;

		/* append to the sending queue */
		struct proc * p;
		if (p_dest->q_sending) {
			p = p_dest->q_sending;
			while (p->next_sending)
				p = p->next_sending;
			p->next_sending = sender;
		}
		else {
			p_dest->q_sending = sender;
		}
		sender->next_sending = 0;

		block(sender);

		assert(sender->p_flags == SENDING);
		assert(sender->p_msg != 0);
		assert(sender->p_recvfrom == NO_TASK);
		assert(sender->p_sendto == dest);
	}

	return 0;
}



int msg_receive(struct proc* current, int src, MESSAGE* m)
{
	struct proc* p_who_wanna_recv = current; /**
						  * This name is a little bit
						  * wierd, but it makes me
						  * think clearly, so I keep
						  * it.
						  */
	struct proc* p_from = 0; /* from which the message will be fetched */
	struct proc* prev = 0;
	int copyok = 0;

	assert(proc2pid(p_who_wanna_recv) != src);

	if ((p_who_wanna_recv->has_int_msg) &&
	    ((src == ANY) || (src == INTERRUPT))) {
		/* There is an interrupt needs p_who_wanna_recv's handling and
		 * p_who_wanna_recv is ready to handle it.
		 */

		MESSAGE msg;
		reset_msg(&msg);
		msg.source = INTERRUPT;
		msg.type = HARD_INT;
		assert(m);
		phys_copy(va2la(proc2pid(p_who_wanna_recv), m), &msg,
			  sizeof(MESSAGE));

		p_who_wanna_recv->has_int_msg = 0;

		assert(p_who_wanna_recv->p_flags == 0);
		assert(p_who_wanna_recv->p_msg == 0);
		assert(p_who_wanna_recv->p_sendto == NO_TASK);
		assert(p_who_wanna_recv->has_int_msg == 0);

		return 0;
	}


	/* Arrives here if no interrupt for p_who_wanna_recv. */
	if (src == ANY) {
		/* p_who_wanna_recv is ready to receive messages from
		 * ANY proc, we'll check the sending queue and pick the
		 * first proc in it.
		 */
		if (p_who_wanna_recv->q_sending) {
			p_from = p_who_wanna_recv->q_sending;
			copyok = 1;

			assert(p_who_wanna_recv->p_flags == 0);
			assert(p_who_wanna_recv->p_msg == 0);
			assert(p_who_wanna_recv->p_recvfrom == NO_TASK);
			assert(p_who_wanna_recv->p_sendto == NO_TASK);
			assert(p_who_wanna_recv->q_sending != 0);
			assert(p_from->p_flags == SENDING);
			assert(p_from->p_msg != 0);
			assert(p_from->p_recvfrom == NO_TASK);
			assert(p_from->p_sendto == proc2pid(p_who_wanna_recv));
		}
	}
	else {
		/* p_who_wanna_recv wants to receive a message from
		 * a certain proc: src.
		 */
		p_from = &proc_table[src];

		if ((p_from->p_flags & SENDING) &&
		    (p_from->p_sendto == proc2pid(p_who_wanna_recv))) {
			/* Perfect, src is sending a message to
			 * p_who_wanna_recv.
			 */
			copyok = 1;

			struct proc* p = p_who_wanna_recv->q_sending;
			assert(p); /* p_from must have been appended to the
				    * queue, so the queue must not be NULL
				    */
			while (p) {
				assert(p_from->p_flags & SENDING);
				if (proc2pid(p) == src) { /* if p is the one */
					p_from = p;
					break;
				}
				prev = p;
				p = p->next_sending;
			}

			assert(p_who_wanna_recv->p_flags == 0);
			assert(p_who_wanna_recv->p_msg == 0);
			assert(p_who_wanna_recv->p_recvfrom == NO_TASK);
			assert(p_who_wanna_recv->p_sendto == NO_TASK);
			assert(p_who_wanna_recv->q_sending != 0);
			assert(p_from->p_flags == SENDING);
			assert(p_from->p_msg != 0);
			assert(p_from->p_recvfrom == NO_TASK);
			assert(p_from->p_sendto == proc2pid(p_who_wanna_recv));
		}
	}

	if (copyok) {
		/* It's determined from which proc the message will
		 * be copied. Note that this proc must have been
		 * waiting for this moment in the queue, so we should
		 * remove it from the queue.
		 */
		if (p_from == p_who_wanna_recv->q_sending) { /* the 1st one */
			assert(prev == 0);
			p_who_wanna_recv->q_sending = p_from->next_sending;
			p_from->next_sending = 0;
		}
		else {
			assert(prev);
			prev->next_sending = p_from->next_sending;
			p_from->next_sending = 0;
		}

		assert(m);
		assert(p_from->p_msg);
		/* copy the message */
		phys_copy(va2la(proc2pid(p_who_wanna_recv), m),
			  va2la(proc2pid(p_from), p_from->p_msg),
			  sizeof(MESSAGE));

		p_from->p_msg = 0;
		p_from->p_sendto = NO_TASK;
		p_from->p_flags &= ~SENDING;
		unblock(p_from);
	}
	else {  /* nobody's sending any msg */
		/* Set p_flags so that p_who_wanna_recv will not
		 * be scheduled until it is unblocked.
		 */
		p_who_wanna_recv->p_flags |= RECEIVING;

		p_who_wanna_recv->p_msg = m;

		if (src == ANY)
			p_who_wanna_recv->p_recvfrom = ANY;
		else
			p_who_wanna_recv->p_recvfrom = proc2pid(p_from);

		block(p_who_wanna_recv);

		assert(p_who_wanna_recv->p_flags == RECEIVING);
		assert(p_who_wanna_recv->p_msg != 0);
		assert(p_who_wanna_recv->p_recvfrom != NO_TASK);
		assert(p_who_wanna_recv->p_sendto == NO_TASK);
		assert(p_who_wanna_recv->has_int_msg == 0);
	}

	return 0;
}
static void block(struct proc* p)
{
	assert(p->p_flags);
	schedule();
}

static void unblock(struct proc* p)
{
	assert(p->p_flags == 0);
}

static int deadlock(int src, int dest)
{
	struct proc* p = proc_table + dest;
	while (1) {
		if (p->p_flags & SENDING) {
			if (p->p_sendto == src) {
				/* print the chain */
				p = proc_table + dest;
				printl("=_=%s", p->p_name);
				do {
					assert(p->p_msg);
					p = proc_table + p->p_sendto;
					printl("->%s", p->p_name);
				} while (p != proc_table + src);
				printl("=_=");

				return 1;
			}
			p = proc_table + p->p_sendto;
		}
		else {
			break;
		}
	}
	return 0;
}
void dump_msg(const char * title, MESSAGE* m)
{
	int packed = 0;
	printl("{%s}<0x%x>{%ssrc:%s(%d),%stype:%d,%s(0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x)%s}%s",  //, (0x%x, 0x%x, 0x%x)}",
	       title,
	       (int)m,
	       packed ? "" : "\n        ",
	       proc_table[m->source].p_name,
	       m->source,
	       packed ? " " : "\n        ",
	       m->type,
	       packed ? " " : "\n        ",
	       m->u.m3.m3i1,
	       m->u.m3.m3i2,
	       m->u.m3.m3i3,
	       m->u.m3.m3i4,
	       (int)m->u.m3.m3p1,
	       (int)m->u.m3.m3p2,
	       packed ? "" : "\n",
	       packed ? "" : "\n"/* , */
		);
}
void inform_int(int task_nr)
{
	struct proc* p = proc_table + task_nr;

	if ((p->p_flags & RECEIVING) && /* dest is waiting for the msg */
	    ((p->p_recvfrom == INTERRUPT) || (p->p_recvfrom == ANY))) {
		p->p_msg->source = INTERRUPT;
		p->p_msg->type = HARD_INT;
		p->p_msg = 0;
		p->has_int_msg = 0;
		p->p_flags &= ~RECEIVING; /* dest has received the msg */
		p->p_recvfrom = NO_TASK;
		assert(p->p_flags == 0);
		unblock(p);

		assert(p->p_flags == 0);
		assert(p->p_msg == 0);
		assert(p->p_recvfrom == NO_TASK);
		assert(p->p_sendto == NO_TASK);
	}
	else {
		p->has_int_msg = 1;
	}
}


