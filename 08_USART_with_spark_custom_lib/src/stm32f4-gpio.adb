
-- About SPARK:
-- In this driver implementation, there is no such
-- complex algorithmic requiring effective SPARK prove,
-- as the package body is only composed on registers
-- fields setters and getters. Using SPARK in this
-- package body would be mostly useless in this very
-- case

package body stm32f4.gpio
   with spark_mode => off
is

   -- Here we choose to use local accessors instead of
   -- a full switch case, in order to:
   --   1) reduce the generated asm
   --   2) avoid writting errors in switch/case write which
   --      can't be detected through SPARK rules
   GPIOx : constant array (t_gpio_port_index) of access t_GPIO_port :=
     (GPIOA'access, GPIOB'access, GPIOC'access, GPIOD'access, GPIOE'access);


   procedure set_mode
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      mode     : in  t_pin_mode)
   is
   begin
      GPIOx(port).all.MODER.pin(pin)   := mode;
   end set_mode;


   procedure set_type
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      otype    : in  t_pin_output_type)
   is
   begin
      GPIOx(port).all.OTYPER.pin(pin)   := otype;
   end set_type;


   procedure set_speed
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      ospeed   : in  t_pin_output_speed)
   is
   begin
      GPIOx(port).all.OSPEEDR.pin(pin)  := ospeed;
   end set_speed;


   procedure set_pupd
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      pupd     : in  t_pin_pupd)
   is
   begin
      GPIOx(port).all.PUPDR.pin(pin)  := pupd;
   end set_pupd;


   procedure set_bsr_r
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      bsr_r    : in  bit)
   is
   begin
      GPIOx(port).all.BSRR.BR(pin) := bsr_r;
   end set_bsr_r;


   procedure set_bsr_s
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      bsr_s    : in  bit)
   is
   begin
      GPIOx(port).all.BSRR.BS(pin) := bsr_s;
   end set_bsr_s;


   procedure set_lck
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      lck      : in  t_pin_lock)
   is
   begin
      GPIOx(port).all.LCKR.pin(pin)  := lck;
   end set_lck;


   procedure set_af
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      af       : in  t_pin_alt_func)
   is
   begin
      if pin < 8 then
         GPIOx(port).all.AFRL.pin(pin)  := af;
      else
         GPIOx(port).all.AFRH.pin(pin)  := af;
      end if;
   end set_af;


   procedure write_pin
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      value    : in  bit)
   is
   begin
      GPIOx(port).all.ODR.pin (pin) := value;
   end write_pin;


   procedure read_pin
     (port     : in  t_gpio_port_index;
      pin      : in  t_gpio_pin_index;
      value    : out bit)
   is
   begin
      value := GPIOx(port).all.IDR.pin (pin);
   end read_pin;


   procedure turn_on (point : in t_gpio_point)
   is
   begin
      write_pin (point.port, point.pin, 1);
   end turn_on;


   procedure turn_off (point : in t_gpio_point)
   is
   begin
      write_pin (point.port, point.pin, 0);
   end turn_off;


   procedure toggle (point : in t_gpio_point)
   is
      current : bit;
   begin
      read_pin (point.port, point.pin, current);
      write_pin (point.port, point.pin, not current);
   end toggle;


   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      otype    : t_pin_output_type;
      ospeed   : t_pin_output_speed;
      pupd     : t_pin_pupd)
   is
   begin
      set_mode (point.port, point.pin, mode);
      set_type (point.port, point.pin, otype);
      set_speed (point.port, point.pin, ospeed);
      set_pupd (point.port, point.pin, pupd);
   end configure;


   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      pupd     : t_pin_pupd)
   is
   begin
      set_mode (point.port, point.pin, mode);
      set_pupd (point.port, point.pin, pupd);
   end configure;


end stm32f4.gpio;
