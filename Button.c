#include <stdint.h>
#include "tm4c123gh6pm.h"

extern char status;
extern int fire;

void Button_Init()
{
	SYSCTL_RCGCGPIO_R |= 0x04;
	int delay=SYSCTL_RCGCGPIO_R;
	GPIO_PORTC_DEN_R |= 0x38;
	GPIO_PORTC_DIR_R &= ~0x38;
	GPIO_PORTC_AFSEL_R &= ~0x38;
}

void Button_Grab()
{
	int data=(GPIO_PORTC_DATA_R&0x38)>>3;
	if(data==0x01)
		status='F';
	else if(data==0x02)
		status='B';
	if((data&0x20)==0x20)
		fire=1;
}
