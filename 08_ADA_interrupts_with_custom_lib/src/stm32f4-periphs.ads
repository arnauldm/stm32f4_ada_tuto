with system;

with stm32f4.rcc;
with stm32f4.syscfg;
with stm32f4.exti;
with stm32f4.gpio;
with stm32f4.nvic;

package stm32f4.periphs is

   --
   -- Base addresses
   --

   NVIC_Base      : constant address := 16#E000_E100#;
   GPIOD_Base     : constant address := 16#4002_0C00#;
   GPIOC_Base     : constant address := 16#4002_0800#;
   GPIOB_Base     : constant address := 16#4002_0400#;
   GPIOA_Base     : constant address := 16#4002_0000#;
   RCC_Base       : constant address := 16#4002_3800#;
   EXTI_Base      : constant address := 16#4001_3C00#;
   SYSCFG_Base    : constant address := 16#4001_3800#;

   --
   -- Peripherals
   --

   GPIOA : aliased stm32f4.gpio.t_GPIO_port
      with import, address => system'to_address (GPIOA_Base);
   -- Note: 'import' aspect means that the actual values are defined outside
   -- the application and should not be initialized

   GPIOD    : aliased stm32f4.gpio.t_GPIO_port
      with import, address => system'to_address (GPIOD_Base);

   RCC      : aliased stm32f4.rcc.t_RCC_periph
      with import, address => system'to_address (RCC_Base);

   SYSCFG   : aliased stm32f4.syscfg.t_SYSCFG_periph
      with import, address => system'to_address (SYSCFG_Base);

   EXTI     : aliased stm32f4.exti.t_EXTI_periph
      with import, address => system'to_address (EXTI_Base);

   NVIC     : aliased stm32f4.nvic.t_NVIC
      with import, address => system'to_address (NVIC_Base);

   --
   -- Led & buttons
   --

   green_led_pin  : constant stm32f4.gpio.GPIO_pin_index := 12;
   orange_led_pin : constant stm32f4.gpio.GPIO_pin_index := 13;
   red_led_pin    : constant stm32f4.gpio.GPIO_pin_index := 14;
   blue_led_pin   : constant stm32f4.gpio.GPIO_pin_index := 15;

   blue_button    : constant stm32f4.gpio.GPIO_pin_index := 0;

end stm32f4.periphs;
