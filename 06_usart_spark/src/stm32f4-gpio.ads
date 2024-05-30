with stm32f4.layout;

package stm32f4.gpio
   with
      spark_mode => on
is

   type t_gpio_pin_index is range 0 .. 15
      with size => 4;

   type t_gpio_port_index is (GPIO_A, GPIO_B, GPIO_C, GPIO_D, GPIO_E)
      with size => 4;

   -------------------------------------------
   -- GPIO port mode register (GPIOx_MODER) --
   -------------------------------------------

   type t_pin_mode is (MODE_IN, MODE_OUT, MODE_AF, MODE_ANALOG)
      with size => 2;

   for t_pin_mode use
     (MODE_IN     => 2#00#,
      MODE_OUT    => 2#01#,
      MODE_AF     => 2#10#,
      MODE_ANALOG => 2#11#);

   type t_pins_mode is array (t_gpio_pin_index) of t_pin_mode
      with pack, size => 32;

   type t_GPIOx_MODER is record
      pin : t_pins_mode;
   end record
      with pack, size => 32, volatile_full_access;
      -- Note: volatile_full_access: the register is volatile and the full
      --       32-bits needs to be written at once.

   ---------------------------------------------------
   -- GPIO port output type register (GPIOx_OTYPER) --
   ---------------------------------------------------

   type t_pin_output_type is (PUSH_PULL, OPEN_DRAIN)
      with size => 1;

   for t_pin_output_type use
     (PUSH_PULL   => 0,
      OPEN_DRAIN  => 1);

   type t_pins_output_type is array (t_gpio_pin_index) of t_pin_output_type
      with pack, size => 16;

   type t_GPIOx_OTYPER is record
      pin : t_pins_output_type;
   end record
      with size => 32, volatile_full_access;

   for t_GPIOx_OTYPER use record
      pin at 0 range 0 .. 15;
   end record;

   -----------------------------------------------------
   -- GPIO port output speed register (GPIOx_OSPEEDR) --
   -----------------------------------------------------

   type t_pin_output_speed is
     (SPEED_LOW, SPEED_MEDIUM, SPEED_HIGH, SPEED_VERY_HIGH)
      with size => 2;

   for t_pin_output_speed use
     (SPEED_LOW         => 0,
      SPEED_MEDIUM      => 1,
      SPEED_HIGH        => 2,
      SPEED_VERY_HIGH   => 3);

   type t_pins_output_speed is array (t_gpio_pin_index) of t_pin_output_speed
      with pack, size => 32;

   type t_GPIOx_OSPEEDR is record
      pin : t_pins_output_speed;
   end record
      with pack, size => 32, volatile_full_access;

   --------------------------------------------------------
   -- GPIO port pull-up/pull-down register (GPIOx_PUPDR) --
   --------------------------------------------------------

   type t_pin_pupd is (FLOATING, PULL_UP, PULL_DOWN)
      with size => 2;

   for t_pin_pupd use
     (FLOATING    => 0,
      PULL_UP     => 1,
      PULL_DOWN   => 2);

   type t_pins_pupd is array (t_gpio_pin_index) of t_pin_pupd
      with pack, size => 32;

   type t_GPIOx_PUPDR is record
      pin : t_pins_pupd;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------------------------------------
   -- GPIO port input data register (GPIOx_IDR) --
   -----------------------------------------------

   type t_pins_idr is array (t_gpio_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_IDR is record
      pin      : t_pins_idr;
   end record
      with size => 32, volatile_full_access;

   for t_GPIOx_IDR use record
      pin      at 0 range 0 .. 15;
   end record;

   ------------------------------------------------
   -- GPIO port output data register (GPIOx_ODR) --
   ------------------------------------------------

   type t_pins_odr is array (t_gpio_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_ODR is record
      pin      : t_pins_odr;
   end record
      with size => 32, volatile_full_access;

   for t_GPIOx_ODR use record
      pin      at 0 range 0 .. 15;
   end record;

   ---------------------------------------------------
   -- GPIO port bit set/reset register (GPIOx_BSRR) --
   ---------------------------------------------------

   type t_pins_bsrr is array (t_gpio_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_BSRR is record
      BS : t_pins_bsrr;
      BR : t_pins_bsrr;
   end record
      with pack, size => 32, volatile_full_access;

   --------------------------------------------------------
   -- GPIO port configuration lock register (GPIOx_LCKR) --
   --------------------------------------------------------

   type t_pin_lock is (NOT_LOCKED, LOCKED)
      with size => 1;

   for t_pin_lock use
     (NOT_LOCKED  => 0,
      LOCKED      => 1);

   type t_pins_lock is array (t_gpio_pin_index) of t_pin_lock
      with pack, size => 16;

   type t_GPIOx_LCKR is record
      pin      : t_pins_lock;
      lock_key : bit;
   end record
      with size => 32, volatile_full_access;

   for t_GPIOx_LCKR use record
      pin      at 0 range 0  .. 15;
      lock_key at 0 range 16 .. 16;
   end record;

   -------------------------------------------------------
   -- GPIO alternate function low register (GPIOx_AFRL) --
   -------------------------------------------------------

   type t_pin_alt_func is range 0 .. 15 with size => 4;

   -- See RM0090, p. 274
   GPIO_AF_USART1 : constant t_pin_alt_func := 7;
   GPIO_AF_USART2 : constant t_pin_alt_func := 7;
   GPIO_AF_USART3 : constant t_pin_alt_func := 7;
   GPIO_AF_UART4  : constant t_pin_alt_func := 8;
   GPIO_AF_UART5  : constant t_pin_alt_func := 8;
   GPIO_AF_USART6 : constant t_pin_alt_func := 8;
   GPIO_AF_SDIO   : constant t_pin_alt_func := 12;

   type t_pins_alt_func_0_7 is array (t_gpio_pin_index range 0 .. 7)
      of t_pin_alt_func
      with pack, size => 32;

   type t_pins_alt_func_8_15 is array (t_gpio_pin_index range 8 .. 15)
      of t_pin_alt_func
      with pack, size => 32;

   type t_GPIOx_AFRL is record
      pin  : t_pins_alt_func_0_7;
   end record
      with pack, size => 32, volatile_full_access;

   type t_GPIOx_AFRH is record
      pin  : t_pins_alt_func_8_15;
   end record
      with pack, size => 32, volatile_full_access;

   ----------------------
   -- GPIO peripherals --
   ----------------------

   type t_GPIO_port is record
      MODER       : t_GPIOx_MODER;
      OTYPER      : t_GPIOx_OTYPER;
      OSPEEDR     : t_GPIOx_OSPEEDR;
      PUPDR       : t_GPIOx_PUPDR;
      IDR         : t_GPIOx_IDR;
      ODR         : t_GPIOx_ODR;
      BSRR        : t_GPIOx_BSRR;
      LCKR        : t_GPIOx_LCKR;
      AFRL        : t_GPIOx_AFRL;
      AFRH        : t_GPIOx_AFRH;
   end record
      with volatile;

   for t_GPIO_port use record
      MODER       at 16#00# range 0 .. 31;
      OTYPER      at 16#04# range 0 .. 31;
      OSPEEDR     at 16#08# range 0 .. 31;
      PUPDR       at 16#0C# range 0 .. 31;
      IDR         at 16#10# range 0 .. 31;
      ODR         at 16#14# range 0 .. 31;
      BSRR        at 16#18# range 0 .. 31;
      LCKR        at 16#1C# range 0 .. 31;
      AFRL        at 16#20# range 0 .. 31;
      AFRH        at 16#24# range 0 .. 31;
   end record;

   -- Facility to help keep tracking of GPIO's
   type t_gpio_point is record
      port : t_gpio_port_index;
      pin  : t_gpio_pin_index;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   -- Note: GPIOs are not declared in stm32f4-periphs.ads to avoid
   -- circular dependencies between packages

   -- Disable some warnings when using gnatprove.
   -- https://github.com/AdaCore/spark2014/blob/master/share/spark/explain_codes/E0012.md
   -- GNATprove warns us because he assumes that:
   -- - as the variable is not atomic, it is not accessed concurrently
   -- - no write through potential aliases can lead to reading an invalid value
   --   for the variable.

   pragma Warnings (Off, "is assumed to have no effects on other non-volatile objects");
   pragma Warnings (Off, "assuming no concurrent accesses to non-atomic object");
   pragma Warnings (Off, "assuming valid reads from object");


   GPIOA : aliased stm32f4.gpio.t_GPIO_port
      with import, volatile, address => stm32f4.layout.GPIOA_BASE;

   GPIOB : aliased stm32f4.gpio.t_GPIO_port
      with import, volatile, address => stm32f4.layout.GPIOB_BASE;

   GPIOC : aliased stm32f4.gpio.t_GPIO_port
      with import, volatile, address => stm32f4.layout.GPIOC_BASE;

   GPIOD : aliased stm32f4.gpio.t_GPIO_port
      with import, volatile, address => stm32f4.layout.GPIOD_BASE;

   GPIOE : aliased stm32f4.gpio.t_GPIO_port
      with import, volatile, address => stm32f4.layout.GPIOE_BASE;

   pragma Warnings (On);

   ---------------
   -- Utilities --
   ---------------

   -- set the GPIO mode (input, output, alternate, analog)
   procedure set_mode
     (point    : in  t_gpio_point;
      mode     : in  t_pin_mode)
      with
         global => null;

   -- set the GPIO type (push-pull, open-drain)
   procedure set_type
     (point    : in  t_gpio_point;
      otype    : in  t_pin_output_type)
      with
         global => null;

   -- set the GPIO speed, from low to very high speed
   procedure set_speed
     (point    : in  t_gpio_point;
      ospeed   : in  t_pin_output_speed)
      with
         global => null;

   -- set the gpio pull mode (no pull, pull-up or pull-down mode)
   procedure set_pupd
     (point    : in  t_gpio_point;
      pupd     : in  t_pin_pupd)
      with
         global => null;

   -- set the GPIO behavior on the output data register bit write action
   -- (reset action)
   procedure set_bsr_r
     (point    : in  t_gpio_point;
      bsr_r    : in  bit)
      with
         global => null;

   -- set the GPIO behavior on the output data register bit write action
   -- (set action)
   procedure set_bsr_s
     (point    : in  t_gpio_point;
      bsr_s    : in  bit)
      with
         global => null;

   -- lock the GPIO configuration
   procedure set_lck
     (point    : in  t_gpio_point;
      lck      : in  t_pin_lock)
      with
         global => null;

   -- set the GPIO alternate function (see the SoC datasheet to get the
   -- list of available alternate functions)
   procedure set_af
     (point    : in  t_gpio_point;
      af       : in  t_pin_alt_func)
      with
         global => null;

   -- set the GPIO output value on GPIO in output mode
   procedure write_pin
     (point    : in  t_gpio_point;
      value    : in  bit);

   -- set the GPIO input value on GPIO in input mode
   function read_pin (point : in  t_gpio_point)
      return bit;

   ----------------
   -- Facilities --
   ----------------

   procedure turn_on  (point : in t_gpio_point);
   procedure turn_off (point : in t_gpio_point);
   procedure toggle   (point : in t_gpio_point);

   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      otype    : t_pin_output_type;
      ospeed   : t_pin_output_speed;
      pupd     : t_pin_pupd);

   procedure configure
     (point    : t_gpio_point;
      mode     : t_pin_mode;
      pupd     : t_pin_pupd);

end stm32f4.gpio;
