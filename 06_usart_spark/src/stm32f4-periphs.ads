with stm32f4.layout;
with stm32f4.gpio; use stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.syscfg;
with stm32f4.exti;
with stm32f4.nvic;

package stm32f4.periphs
   with spark_mode => on
is

   -----------------
   -- Peripherals --
   -----------------

   -- Note: GPIOs are not declared here to avoid circular dependencies
   -- between packages

   -- Disable some warnings when using gnatprove.
   -- https://github.com/AdaCore/spark2014/blob/master/share/spark/explain_codes/E0012.md
   -- See also comments in stm32f4-gpio.ads

   pragma Warnings (Off, "is assumed to have no effects on other non-volatile objects");
   pragma Warnings (Off, "assuming no concurrent accesses to non-atomic object");
   pragma Warnings (Off, "assuming valid reads from object");

   RCC      : stm32f4.rcc.t_RCC_periph
      with import, volatile, address => stm32f4.layout.RCC_BASE;

   SYSCFG   : stm32f4.syscfg.t_SYSCFG_periph
      with import, volatile, address => stm32f4.layout.SYSCFG_BASE;

   EXTI     : stm32f4.exti.t_EXTI_periph
      with import, volatile, address => stm32f4.layout.EXTI_BASE;

   NVIC     : stm32f4.nvic.t_NVIC
      with import, volatile, address => stm32f4.layout.NVIC_BASE;

   pragma Warnings (On);

   -----------------
   -- GPIO points --
   -----------------

   PA0   : constant t_gpio_point  := (GPIO_A, 0);

   PB6   : constant t_gpio_point  := (GPIO_B, 6);
   PB7   : constant t_gpio_point  := (GPIO_B, 7);
   PB11  : constant t_gpio_point  := (GPIO_B, 11);

   PC6   : constant t_gpio_point  := (GPIO_C, 6);
   PC7   : constant t_gpio_point  := (GPIO_C, 7);

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
   -- USARTs --
   ------------

   USART1_TX   : t_gpio_point renames PB6;
   USART1_RX   : t_gpio_point renames PB7;

   USART3_TX   : t_gpio_point renames PD8;
   USART3_RX   : t_gpio_point renames PB11;

   USART6_TX   : t_gpio_point renames PC6;
   USART6_RX   : t_gpio_point renames PC7;

end stm32f4.periphs;
