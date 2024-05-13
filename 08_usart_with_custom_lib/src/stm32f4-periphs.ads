with system; use system;

with stm32f4.rcc;
with stm32f4.syscfg;
with stm32f4.exti;
with stm32f4.gpio;
with stm32f4.nvic;
with stm32f4.usart;

package stm32f4.periphs is

   --------------------
   -- Base addresses --
   --------------------

   NVIC_Base   : constant address := system'to_address (16#E000_E100#);
   RCC_Base    : constant address := system'to_address (16#4002_3800#); -- AHB1
   GPIOD_Base  : constant address := system'to_address (16#4002_0C00#); -- AHB1
   GPIOC_Base  : constant address := system'to_address (16#4002_0800#); -- AHB1
   GPIOB_Base  : constant address := system'to_address (16#4002_0400#); -- AHB1
   GPIOA_Base  : constant address := system'to_address (16#4002_0000#); -- AHB1
   EXTI_Base   : constant address := system'to_address (16#4001_3C00#); -- APB2
   SYSCFG_Base : constant address := system'to_address (16#4001_3800#); -- APB2
   SDIO_Base   : constant address := system'to_address (16#4001_2C00#); -- APB2
   USART6_Base : constant address := system'to_address (16#4001_1400#); -- APB2
   USART1_Base : constant address := system'to_address (16#4001_1000#); -- APB2
   UART5_Base  : constant address := system'to_address (16#4000_5000#); -- APB1
   UART4_Base  : constant address := system'to_address (16#4000_4C00#); -- APB1
   USART3_Base : constant address := system'to_address (16#4000_4800#); -- APB1
   USART2_Base : constant address := system'to_address (16#4000_4400#); -- APB1

   -----------------
   -- Peripherals --
   -----------------

   GPIOA : aliased stm32f4.gpio.t_GPIO_port
      with import, address => GPIOA_Base;
   -- Note: 'import' aspect means that the actual values are defined outside
   -- the application and should not be initialized

   GPIOB : aliased stm32f4.gpio.t_GPIO_port
      with import, address => GPIOB_Base;

   GPIOC : aliased stm32f4.gpio.t_GPIO_port
      with import, address => GPIOC_Base;

   GPIOD    : aliased stm32f4.gpio.t_GPIO_port
      with import, address => GPIOD_Base;

   RCC      : aliased stm32f4.rcc.t_RCC_periph
      with import, address => RCC_Base;

   SYSCFG   : aliased stm32f4.syscfg.t_SYSCFG_periph
      with import, address => SYSCFG_Base;

   EXTI     : aliased stm32f4.exti.t_EXTI_periph
      with import, address => EXTI_Base;

   NVIC     : aliased stm32f4.nvic.t_NVIC
      with import, address => NVIC_Base;

   USART1   : aliased stm32f4.usart.t_USART_periph
      with import, address => USART1_Base;

   USART2   : aliased stm32f4.usart.t_USART_periph
      with import, address => USART2_Base;

   USART3   : aliased stm32f4.usart.t_USART_periph
      with import, address => USART3_Base;

   UART4    : aliased stm32f4.usart.t_USART_periph
      with import, address => UART4_Base;

   UART5    : aliased stm32f4.usart.t_USART_periph
      with import, address => UART5_Base;

   USART6   : aliased stm32f4.usart.t_USART_periph
      with import, address => USART6_Base;

   ---------------
   -- GPIO pins --
   ---------------

   PA0   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOA'access, 0);
   PA4   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOA'access, 4);
   PA11  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOA'access, 11);
   PA12  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOA'access, 12);

   PB6   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOB'access, 6);
   PB7   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOB'access, 7);
   PB11   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOB'access, 11);
   PB14   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOB'access, 14);
   PB15   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOB'access, 15);

   PC8   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOC'access, 8);
   PC9   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOC'access, 9);
   PC10   : constant stm32f4.gpio.t_GPIO_pin := (GPIOC'access, 10);
   PC11   : constant stm32f4.gpio.t_GPIO_pin := (GPIOC'access, 11);
   PC12   : constant stm32f4.gpio.t_GPIO_pin := (GPIOC'access, 12);

   PD2   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 2);
   PD8   : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 8);
   PD12  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 12);
   PD13  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 13);
   PD14  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 14);
   PD15  : constant stm32f4.gpio.t_GPIO_pin  := (GPIOD'access, 15);

   -------------------
   -- Led & buttons --
   -------------------

   LED_GREEN   : stm32f4.gpio.t_GPIO_pin renames PD12;
   LED_ORANGE  : stm32f4.gpio.t_GPIO_pin renames PD13;
   LED_RED     : stm32f4.gpio.t_GPIO_pin renames PD14;
   LED_BLUE    : stm32f4.gpio.t_GPIO_pin renames PD15;

   BLUE_BUTTON : stm32f4.gpio.t_GPIO_pin renames PA0;

   ------------
   -- USART1 --
   ------------

   USART1_TX   : stm32f4.gpio.t_GPIO_pin renames PB6;
   USART1_RX   : stm32f4.gpio.t_GPIO_pin renames PB7;

   ------------
   -- USART3 --
   ------------

   USART3_TX   : stm32f4.gpio.t_GPIO_pin renames PD8;
   USART3_RX   : stm32f4.gpio.t_GPIO_pin renames PB11;

end stm32f4.periphs;
