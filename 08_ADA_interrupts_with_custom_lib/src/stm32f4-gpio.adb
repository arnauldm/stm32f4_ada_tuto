
package body stm32f4.gpio is

   procedure configure
     (pin      : t_GPIO_pin;
      mode     : t_pin_mode;
      otype    : t_pin_output_type;
      ospeed   : t_pin_speed;
      pupd     : t_pin_pupd)
   is
      GPIOx       : t_GPIO_port renames pin.gpio;
      pin_number  : t_GPIO_pin_index renames pin.pin_number;
   begin
      GPIOx.MODER.pin (pin_number)     := mode;
      GPIOx.OTYPER.pin (pin_number)    := otype;
      GPIOx.OSPEEDR.pin (pin_number)   := ospeed;
      GPIOx.PUPDR.pin (pin_number)     := pupd;
   end configure;


   procedure configure
     (pin      : t_GPIO_pin;
      mode     : t_pin_mode;
      pupd     : t_pin_pupd)
   is
      GPIOx       : t_GPIO_port renames pin.gpio;
      pin_number  : t_GPIO_pin_index renames pin.pin_number;
   begin
      GPIOx.MODER.pin (pin_number)     := mode;
      GPIOx.PUPDR.pin (pin_number)     := pupd;
   end configure;


   procedure set_alternate_function
     (pin      : t_GPIO_pin;
      af       : t_AF)
   is
      GPIOx       : t_GPIO_port renames pin.gpio;
      pin_number  : t_GPIO_pin_index renames pin.pin_number;
   begin
      if pin_number in GPIOx.AFRL.pin'range then
         GPIOx.AFRL.pin (pin_number) := af;
      else
         GPIOx.AFRH.pin (pin_number) := af;
      end if;
   end set_alternate_function;


   procedure set
     (pin      : t_GPIO_pin;
      value    : bit)
   is
      GPIOx       : t_GPIO_port renames pin.gpio;
      pin_number  : t_GPIO_pin_index renames pin.pin_number;
   begin
      GPIOx.ODR.pin (pin_number) := value;
   end set;


   procedure turn_on (pin : t_GPIO_pin)
   is
   begin
      set (pin, 1);
   end turn_on;


   procedure turn_off (pin : t_GPIO_pin)
   is
   begin
      set (pin, 0);
   end turn_off;


end stm32f4.gpio;
