
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
   --   1) reduce code size
   --   2) reduce the generated asm and avoid performance overhead
   --   3) copy/pasting code line might introduce errors not detected by SPARK!
   --   4) increase readability
   GPIOx : constant array (t_gpio_port_index) of access t_GPIO_port :=
     (GPIOA'access, GPIOB'access, GPIOC'access, GPIOD'access, GPIOE'access);


   procedure set_mode
     (point    : in  t_gpio_point;
      mode     : in  t_pin_mode)
   is
   begin
      GPIOx(point.port).all.MODER.pin(point.pin)   := mode;
   end set_mode;


   procedure set_type
     (point    : in  t_gpio_point;
      otype    : in  t_pin_output_type)
   is
   begin
      GPIOx(point.port).all.OTYPER.pin(point.pin)  := otype;
   end set_type;


   procedure set_speed
     (point    : in  t_gpio_point;
      ospeed   : in  t_pin_output_speed)
   is
   begin
      GPIOx(point.port).all.OSPEEDR.pin(point.pin) := ospeed;
   end set_speed;


   procedure set_pupd
     (point    : in  t_gpio_point;
      pupd     : in  t_pin_pupd)
   is
   begin
      GPIOx(point.port).all.PUPDR.pin(point.pin)   := pupd;
   end set_pupd;


   procedure set_bsr_r
     (point    : in  t_gpio_point;
      bsr_r    : in  bit)
   is
   begin
      GPIOx(point.port).all.BSRR.BR(point.pin)  := bsr_r;
   end set_bsr_r;


   procedure set_bsr_s
     (point    : in  t_gpio_point;
      bsr_s    : in  bit)
   is
   begin
      GPIOx(point.port).all.BSRR.BS(point.pin)  := bsr_s;
   end set_bsr_s;


   procedure set_lck
     (point    : in  t_gpio_point;
      lck      : in  t_pin_lock)
   is
   begin
      GPIOx(point.port).all.LCKR.pin(point.pin) := lck;
   end set_lck;


   procedure set_af
     (point    : in  t_gpio_point;
      af       : in  t_pin_alt_func)
   is
   begin
      if point.pin < 8 then
         GPIOx(point.port).all.AFRL.pin(point.pin) := af;
      else
         GPIOx(point.port).all.AFRH.pin(point.pin) := af;
      end if;
   end set_af;


   procedure write_pin
     (point    : in  t_gpio_point;
      value    : in  bit)
   is
   begin
      GPIOx(point.port).all.ODR.pin (point.pin) := value;
   end write_pin;


   function read_pin (point : in  t_gpio_point)
      return bit
   is
   begin
      return GPIOx(point.port).all.IDR.pin (point.pin);
   end read_pin;


   procedure turn_on (point : in t_gpio_point)
   is
   begin
      write_pin (point, 1);
   end turn_on;


   procedure turn_off (point : in t_gpio_point)
   is
   begin
      write_pin (point, 0);
   end turn_off;


   procedure toggle (point : in t_gpio_point)
   is
   begin
      write_pin (point, not read_pin (point));
   end toggle;


   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      otype    : t_pin_output_type;
      ospeed   : t_pin_output_speed;
      pupd     : t_pin_pupd)
   is
   begin
      set_mode (point, mode);
      set_type (point, otype);
      set_speed (point, ospeed);
      set_pupd (point, pupd);
   end configure;


   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      pupd     : t_pin_pupd)
   is
   begin
      set_mode (point, mode);
      set_pupd (point, pupd);
   end configure;


end stm32f4.gpio;
