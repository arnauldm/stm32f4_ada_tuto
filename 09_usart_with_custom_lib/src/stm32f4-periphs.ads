with stm32f4.layout;
with stm32f4.gpio; use stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.syscfg;
with stm32f4.exti;
with stm32f4.nvic;
with stm32f4.usart;

package stm32f4.periphs
   with spark_mode => off
is

   -----------------
   -- Peripherals --
   -----------------

   RCC      : aliased stm32f4.rcc.t_RCC_periph
      with import,
           address => stm32f4.layout.RCC_BASE;

   SYSCFG   : aliased stm32f4.syscfg.t_SYSCFG_periph
      with import, address => stm32f4.layout.SYSCFG_BASE;

   EXTI     : aliased stm32f4.exti.t_EXTI_periph
      with import, address => stm32f4.layout.EXTI_BASE;

   NVIC     : aliased stm32f4.nvic.t_NVIC
      with import, address => stm32f4.layout.NVIC_BASE;

   USART1   : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.USART1_BASE;

   USART2   : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.USART2_BASE;

   USART3   : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.USART3_BASE;

   UART4    : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.UART4_BASE;

   UART5    : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.UART5_BASE;

   USART6   : aliased stm32f4.usart.t_USART_periph
      with import, address => stm32f4.layout.USART6_BASE;

   -----------------
   -- GPIO points --
   -----------------


   PA0   : constant t_gpio_point  := (GPIO_A, 0);
   PA4   : constant t_gpio_point  := (GPIO_A, 4);
   PA11  : constant t_gpio_point  := (GPIO_A, 11);
   PA12  : constant t_gpio_point  := (GPIO_A, 12);

   PB6   : constant t_gpio_point  := (GPIO_B, 6);
   PB7   : constant t_gpio_point  := (GPIO_B, 7);
   PB11   : constant t_gpio_point  := (GPIO_B, 11);
   PB14   : constant t_gpio_point  := (GPIO_B, 14);
   PB15   : constant t_gpio_point  := (GPIO_B, 15);

   PC8   : constant t_gpio_point  := (GPIO_C, 8);
   PC9   : constant t_gpio_point  := (GPIO_C, 9);
   PC10   : constant t_gpio_point := (GPIO_C, 10);
   PC11   : constant t_gpio_point := (GPIO_C, 11);
   PC12   : constant t_gpio_point := (GPIO_C, 12);

   PD2   : constant t_gpio_point  := (GPIO_D, 2);
   PD8   : constant t_gpio_point  := (GPIO_D, 8);
   PD12  : constant t_gpio_point  := (GPIO_D, 12);
   PD13  : constant t_gpio_point  := (GPIO_D, 13);
   PD14  : constant t_gpio_point  := (GPIO_D, 14);
   PD15  : constant t_gpio_point  := (GPIO_D, 15);

   -------------------
   -- Led & buttons --
   -------------------

   LED_GREEN   : t_gpio_point renames PD12;
   LED_ORANGE  : t_gpio_point renames PD13;
   LED_RED     : t_gpio_point renames PD14;
   LED_BLUE    : t_gpio_point renames PD15;

   BLUE_BUTTON : t_gpio_point renames PA0;

   ------------
   -- USART1 --
   ------------

   USART1_TX   : t_gpio_point renames PB6;
   USART1_RX   : t_gpio_point renames PB7;

   ------------
   -- USART3 --
   ------------

   USART3_TX   : t_gpio_point renames PD8;
   USART3_RX   : t_gpio_point renames PB11;

end stm32f4.periphs;
