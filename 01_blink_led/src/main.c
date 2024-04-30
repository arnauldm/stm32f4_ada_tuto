#include "stm32f4xx.h"
#include "stm32f4xx_exti.h"
#include "init.h"

#define DELAY  5200000 //400ms

#define GREEN_LED 12
#define RED_LED 14

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
   GPIOD->MODER |=1 << (RED_LED * 2);

   while (1){
      udelay (DELAY);
      GPIOD->ODR |= (1 << GREEN_LED);   /* led on */
      GPIOD->ODR &= ~(1 << RED_LED);    /* led off */
      udelay (DELAY);
      GPIOD->ODR &= ~(1 << GREEN_LED);  /* led off */
      GPIOD->ODR |= (1 << RED_LED);    /* led on */
   }
}

