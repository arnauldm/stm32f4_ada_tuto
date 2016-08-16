with stm32f4.periphs;

package body stm32f4.rcc is

   procedure enable_clock
     (GPIOx : aliased in gpio.t_GPIO_port)
   is
   begin
      if GPIOx'address = periphs.GPIOA_base then
         periphs.RCC.AHB1ENR.GPIOAEN := 1;
      elsif GPIOx'address = periphs.GPIOB_base then
         periphs.RCC.AHB1ENR.GPIOBEN := 1;
      elsif GPIOx'address = periphs.GPIOC_base then
         periphs.RCC.AHB1ENR.GPIOCEN := 1;
      elsif GPIOx'address = periphs.GPIOD_base then
         periphs.RCC.AHB1ENR.GPIODEN := 1;
      else
         raise program_error;
      end if;
   end enable_clock;

end stm32f4.rcc;
