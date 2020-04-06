/******************************************************************************
*
* Copyright (C) 2010 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/*
 * platform_mb.c
 *
 * MicroBlaze platform specific functions.
 */

#ifdef __MICROBLAZE__

#include "platform.h"
#include "platform_config.h"

#include "mb_interface.h"
//#include "mytransmitter.h"

#include "xparameters.h"
#include "xintc.h"
#include "xtmrctr_l.h"

//#include "xiic.h"
//extern XIic IICInstance;
//#include "xspi.h"
//extern XSpi SPIInstance;

//void spi_handler(void *p){
//	XSpi_InterruptHandler(&SPIInstance);
//	//clean it
//	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK_SPI);
//}

//void icc_hander(void *p){
//	XIic_InterruptHandler(&IICInstance);
//	//clean it
//	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK_ICC);
//}

//void myip_handler(void *p){
//	myip_callback();
//	//clean it
//	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK_MYIP);
//	MYTRANSMITTER_ACK((void*)MYTRANSMITTER_BASE);
//}

void hex_timer_handler(void *p){
	hex_callback();

	/* Load timer, clear interrupt bit */
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR_HEX, 0,
			XTC_CSR_INT_OCCURED_MASK
			| XTC_CSR_LOAD_MASK);

	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR_HEX, 0,
			XTC_CSR_ENABLE_TMR_MASK
			| XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK
			| XTC_CSR_DOWN_COUNT_MASK);

	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK_HEX);
}

void
xadapter_timer_handler(void *p)
{
	timer_callback();

	/* Load timer, clear interrupt bit */
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_INT_OCCURED_MASK
			| XTC_CSR_LOAD_MASK);

	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_ENABLE_TMR_MASK
			| XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK
			| XTC_CSR_DOWN_COUNT_MASK);

	XIntc_AckIntr(XPAR_INTC_0_BASEADDR, PLATFORM_TIMER_INTERRUPT_MASK);
}

#define MHZ (66)
#define TIMER_TLR (25000000*((float)MHZ/100))
#define TIMER_TLR_HEX (25000000*((float)MHZ)/100000)

void
platform_setup_timer()
{
	/* set the number of cycles the timer counts before interrupting */
	/* 100 Mhz clock => .01us for 1 clk tick. For 100ms, 10000000 clk ticks need to elapse  */
	XTmrCtr_SetLoadReg(PLATFORM_TIMER_BASEADDR, 0, TIMER_TLR);
	XTmrCtr_SetLoadReg(PLATFORM_TIMER_BASEADDR_HEX, 0, TIMER_TLR_HEX);

	/* reset the timers, and clear interrupts */
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0, XTC_CSR_INT_OCCURED_MASK | XTC_CSR_LOAD_MASK );
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR_HEX, 0, XTC_CSR_INT_OCCURED_MASK | XTC_CSR_LOAD_MASK );

	/* start the timers */
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR, 0,
			XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);
	XTmrCtr_SetControlStatusReg(PLATFORM_TIMER_BASEADDR_HEX, 0,
			XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_ENABLE_INT_MASK
			| XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);

	/* Register Timer handler */

	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
			PLATFORM_TIMER_INTERRUPT_INTR,
			(XInterruptHandler)xadapter_timer_handler,
			0);

	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
			PLATFORM_TIMER_INTERRUPT_INTR_HEX,
			(XInterruptHandler)hex_timer_handler,
			0);
//	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
//			PLATFORM_TIMER_INTERRUPT_INTR_MYIP,
//			(XInterruptHandler)myip_handler,
//			0);

}

//void platform_setup_icc(){
//	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
//			PLATFORM_TIMER_INTERRUPT_INTR_ICC,
//				(XInterruptHandler)icc_hander,
//				0);
//}

//void platform_setup_spi(){
//	XIntc_RegisterHandler(XPAR_INTC_0_BASEADDR,
//			PLATFORM_TIMER_INTERRUPT_INTR_SPI,
//				(XInterruptHandler)spi_handler,
//				0);
//}


void platform_enable_interrupts()
{
	microblaze_enable_interrupts();
}
#endif
