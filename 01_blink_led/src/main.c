#include "stm32f4xx.h"
#include "stm32f4xx_exti.h"
#include "init.h"

#define DELAY  2600000 //200ms

#define GREEN_LED 12

void udelay(__IO uint32_t d) {
   __IO uint32_t i = 0;
   for (i = 0; i < d; i++);
}

int main(void) {

   system_init();

   /* Enable clocks */
   RCC->AHB1ENR  = RCC_AHB1ENR_GPIODEN;      /* GPIOD Periph clock enable */

   /* Set pin to output mode */
   GPIOD->MODER |=1 << (GREEN_LED * 2);

   while (1){
      udelay (DELAY);
      GPIOD->ODR |= (1 << GREEN_LED);   /* led on */
      udelay (DELAY);
      GPIOD->ODR &= ~(1 << GREEN_LED);  /* led off */
   }
}

