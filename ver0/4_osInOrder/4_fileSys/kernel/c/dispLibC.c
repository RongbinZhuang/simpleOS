#include "dispLibC.h"

char * itoa(char * str, int num)
{
	char *	p = str;
	char	ch;
	int	i;
	int	flag = 0;
	*p++ = '0';
	*p++ = 'x';
	if(num == 0){
		*p++ = '0';
	}
	else{	
		for(i=28;i>=0;i-=4){
			ch = (num >> i) & 0xF;
			if(flag || (ch > 0)){
				flag = 1;
				ch += '0';
				if(ch > '9'){
					ch += 7;
				}
				*p++ = ch;
			}
		}
	}

	*p = 0;
	return str;
}

/*======================================================================*
                               disp_int
 *======================================================================*/
void disp_int(int input)
{
	char output[16];
	itoa(output, input);
	disp_str(output);
}

void clearScreen()
{
	dwDispPos=0;
	for(int i=0;i<80*25;i++)
		disp_str((char*)" ");
	dwDispPos=0;
}
