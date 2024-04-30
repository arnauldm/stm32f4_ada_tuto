#include "stm32f4xx.h"
#include "stm32f4xx_exti.h"
#include "init.h"

#define LED_GREEN       12
#define LED_RED         14
#define BLUE_BUTTON     0

#define DELAY           2600000 //200ms

int currentLED = LED_GREEN;

void udelay(__IO uint32_t d) {
   __IO uint32_t i = 0;
   for (i = 0; i < d; i++);
}

void EXTI0_IRQHandler(void)
{
   /* Clear the led */
   GPIOD->ODR &= ~(1 << currentLED);   

   /* Change current led */
   currentLED = (currentLED == LED_GREEN) ? LED_RED : LED_GREEN;

   /* Clear Pending Request bit to acknowledge the interrupt (this bit is
    * cleared by programming it to 1 ! */
   EXTI->PR = EXTI_Line0;
}

int main(void) {

   system_init();

   /* 
    * Enable LEDs
    */

   /* GPIOD Periph clock enable */
   RCC->AHB1ENR  = RCC_AHB1ENR_GPIODEN;

   /* Set pins to output mode */
   GPIOD->MODER |=1 << (LED_GREEN * 2);
   GPIOD->MODER |=1 << (LED_RED * 2);

   /* Clear the leds (write low signal to the outputs) */
   GPIOD->ODR &= ~(1 << LED_GREEN);
   GPIOD->ODR &= ~(1 << LED_RED);

   /* 
    * Enable the blue button
    */

   /* GPIOA Periph clock enable */
   RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;      

   /* GPIOA0 pin set to input mode (00) */
   GPIOA->MODER   &= ~(3 << (BLUE_BUTTON * 2));   

   /* Push-pull mode (0) */
   GPIOA->OTYPER  &= ~(1 << BLUE_BUTTON);         

   /* Default (idle) state is at 0V. Set GPIO pin to pull-down (2) */
   GPIOA->PUPDR   &= ~(3 << (BLUE_BUTTON * 2));   /* clear bits */
   GPIOA->PUPDR   |=  (2 << (BLUE_BUTTON * 2)); 

   /* Set GPIO Speed to high speed (2) */
   GPIOA->OSPEEDR &= ~(3 << (BLUE_BUTTON * 2));   /* clear bits */
   GPIOA->OSPEEDR |=  (2 << (BLUE_BUTTON * 2));   

   /* 
    * Enable interrupts
    */

   /* P<port>x interrupts are managed by the EXTIx interrupt line. Thus,
    * interrupts on BLUE_BUTTON are managed by EXTI0. BLUE_BUTTON is attached
    * on the PA0 pin but EXTI0 can also manage interrupts on ports PB0, PC0,
    * PD0, etc. We must indicate in SYSCFG_EXTICR1 register that EXTI0 will
    * only manage PAx pins (BLUE_BUTTON) (p. 293) */
   SYSCFG->EXTICR[0] &= 0xfffffff0;

   /* Clear EXTI line configuration */
   EXTI->IMR |=  EXTI_Line0;  /* Interrupt request from line x is not masked (1) */
   EXTI->EMR &= ~EXTI_Line0;  /* Event Mask Register is masked (0) */

   /* Trigger the selected external interrupt on rising edge */
   EXTI->RTSR |= EXTI_Line0;  /* Rising */
   EXTI->FTSR &= ~EXTI_Line0;  /* Clear falling */

   /* Set the IRQ priority level (in the range 0-15). The lower the value, the
    * greater the priority is. The Reset, Hard fault, and NMI exceptions, with
    * fixed negative priority values, always have higher priority than any other
    * exception. When the processor is executing an exception handler, the
    * exception handler is preempted if a higher priority exception occurs. 
    * Note: 'EXTI0_IRQn' stands for EXTI Line0 Interrupt */
   NVIC->IP[EXTI0_IRQn] = 0;

   /* Enable the Selected IRQ Channels */
   NVIC->ISER[0] = (uint32_t) 0x01 << EXTI0_IRQn;

   while (1){
      udelay (DELAY);
      GPIOD->ODR |= (1 << currentLED);    /* led on */
      udelay (DELAY);
      GPIOD->ODR &= ~(1 << currentLED);   /* led off */
   }
}

