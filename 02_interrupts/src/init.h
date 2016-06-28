#ifndef _INIT_H
#define _INIT_H

#include "stm32f4xx.h"

#define VECT_TAB_OFFSET  0x00 /*!< Vector Table base offset field.
                                   This value must be a multiple of 0x200. */

/******************************************************************************/
/*                PLL Configuration                                           */
/******************************************************************************/

 /* PLL_VCO = (HSE_VALUE or HSI_VALUE / PLL_M) * PLL_N */
#define PLL_M      8
#define PLL_N      336
/* SYSCLK = PLL_VCO / PLL_P */
#define PLL_P      2
/* USB OTG FS, SDIO and RNG Clock =  PLL_VCO / PLLQ */
#define PLL_Q      7

void SetSysClock(void);
void system_init(void);

#endif
