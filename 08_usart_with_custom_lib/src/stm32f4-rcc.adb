with system; use system;
with stm32f4.periphs;

package body stm32f4.rcc
   with spark_mode => off
is

   procedure enable_gpio_clock
     (GPIOx : aliased in gpio.t_GPIO_port)
   is
   begin
      if GPIOx'address = periphs.GPIOA_base then
         periphs.RCC.AHB1ENR.GPIOAEN := true;
      elsif GPIOx'address = periphs.GPIOB_base then
         periphs.RCC.AHB1ENR.GPIOBEN := true;
      elsif GPIOx'address = periphs.GPIOC_base then
         periphs.RCC.AHB1ENR.GPIOCEN := true;
      elsif GPIOx'address = periphs.GPIOD_base then
         periphs.RCC.AHB1ENR.GPIODEN := true;
      else
         raise program_error;
      end if;
   end enable_gpio_clock;


   procedure enable_gpio_clock (pin : gpio.t_GPIO_pin)
   is
   begin
      enable_gpio_clock (pin.gpio.all);
   end enable_gpio_clock;

end stm32f4.rcc;
