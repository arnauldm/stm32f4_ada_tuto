with stm32f4.periphs;
with stm32f4.gpio; use stm32f4.gpio;

package body stm32f4.rcc
   with spark_mode => on
is

   procedure enable_gpio_clock
     (port : in stm32f4.gpio.t_gpio_port_index)
   is
   begin
      case port is
         when GPIO_A => stm32f4.periphs.RCC.AHB1ENR.GPIOAEN := true;
         when GPIO_B => stm32f4.periphs.RCC.AHB1ENR.GPIOBEN := true;
         when GPIO_C => stm32f4.periphs.RCC.AHB1ENR.GPIOCEN := true;
         when GPIO_D => stm32f4.periphs.RCC.AHB1ENR.GPIODEN := true;
         when GPIO_E => stm32f4.periphs.RCC.AHB1ENR.GPIOEEN := true;
      end case;
   end enable_gpio_clock;

end stm32f4.rcc;
