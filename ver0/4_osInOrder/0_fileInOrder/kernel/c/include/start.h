#ifndef _MY_CSTART_H
#define _MY_CSTART_H

#include "type.h"
#include "global.h"

void cstart();

extern void disp_str(char*);
extern void* memcpy(void* p_dst,void* p_src,int iSize);
extern void init_prot();

int		dwDispPos;
u8		gdt_ptr[6];	// 0~15:Limit  16~47:Base
DESCRIPTOR	gdt[GDT_SIZE];
u8		idt_ptr[6];	// 0~15:Limit  16~47:Base
GATE		idt[IDT_SIZE];
TSS		tss;

#endif
