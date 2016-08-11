
package body stm32f4.usart is

   procedure initialize is
   begin

      -- STM32F407 User Manual, p. 20-23
      --
      --       USART1  USART2  USART3  UART4  UART5  USART6
      --
      -- TX     PA9     PA2     PB10    PA0    PC12   PC6
      --        PB6     PD5     PC10    PC10
      --                        PD8 
      -- RX     PA10    PA3     PB11    PA1           PC7
      --        PB7     PD6     PC11    PC11
      --                        PD9 

      -- Configure USART1 in asynchronous mode with ports PA9 (TX) and
      -- PA10 (TX)

      -- Enable USART1 clock 
      stm32f4.periphs.RCC.APB2ENR.USART1EN := 1;

      -- Enable GPIOA clock 
      stm32f4.periphs.RCC.AHB1ENR.GPIOAEN  := 1;
      
      -- Set PA9 and PA10 as USART1 alternate function
      stm32f4.periphs.GPIOA.MODER.pin (9)  := stm32f4.gpio.MODE_AF;
      stm32f4.periphs.GPIOA.MODER.pin (10) := stm32f4.gpio.MODE_AF;

      stm32f4.periphs.GPIOA.OTYPER.pin (9)  := stm32f4.gpio.PUSH_PULL;
      stm32f4.periphs.GPIOA.OTYPER.pin (10) := stm32f4.gpio.PUSH_PULL;

      stm32f4.periphs.GPIOA.OSPEEDR.pin (9)  := stm32f4.gpio.SPEED_HIGH;
      stm32f4.periphs.GPIOA.OSPEEDR.pin (10) := stm32f4.gpio.SPEED_HIGH;

      stm32f4.periphs.GPIOA.PUPDR.pin (9)  := stm32f4.gpio.PULL_UP;
      stm32f4.periphs.GPIOA.PUPDR.pin (10) := stm32f4.gpio.PULL_UP;

      stm32f4.periphs.GPIOA.AFRH.pin (9)  := GPIO_AF_USART1;
      stm32f4.periphs.GPIOA.AFRH.pin (10) := GPIO_AF_USART1;
   end initialize;

end stm32f4.usart;
