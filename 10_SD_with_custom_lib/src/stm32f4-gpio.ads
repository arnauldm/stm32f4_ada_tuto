
--
-- Ref. : RM0090, p. 283-290
-- Note: GPIO registers can be accessed by byte, half-words or words
--

package stm32f4.gpio is

   subtype t_GPIO_pin_index is natural range 0 .. 15;

   -------------------------------------------
   -- GPIO port mode register (GPIOx_MODER) --
   -------------------------------------------

   type t_pin_mode is new uint2;

   type t_pins_mode is array (t_GPIO_pin_index) of t_pin_mode
      with pack, size => 32;

   type t_GPIOx_MODER is record
      pin : t_pins_mode;
   end record
      with pack, size => 32, volatile_full_access;
   -- Note: 'volatile_full_access aspect': the register is volatile and
   -- the full 32-bits needs to be written at once. 

   MODE_IN     : constant t_pin_mode := 2#00#; -- Input (reset state)
   MODE_OUT    : constant t_pin_mode := 2#01#; -- Output
   MODE_AF     : constant t_pin_mode := 2#10#; -- Alternate function
   MODE_ANALOG : constant t_pin_mode := 2#11#; -- Analog

   ---------------------------------------------------
   -- GPIO port output type register (GPIOx_OTYPER) --
   ---------------------------------------------------

   type t_pin_output_type is new bit;

   type t_pins_output_type is array (t_GPIO_pin_index) of t_pin_output_type
      with pack, size => 16;

   type t_GPIOx_OTYPER is record
      pin      : t_pins_output_type;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   PUSH_PULL    : constant t_pin_output_type := 0; 
   OPEN_DRAIN   : constant t_pin_output_type := 1;

   -----------------------------------------------------
   -- GPIO port output speed register (GPIOx_OSPEEDR) --
   -----------------------------------------------------

   type t_pin_speed is new uint2;

   type t_pins_speed is array (t_GPIO_pin_index) of t_pin_speed
      with pack, size => 32;

   type t_GPIOx_OSPEEDR is record
      pin : t_pins_speed;
   end record
      with pack, size => 32, volatile_full_access;

   SPEED_LOW         : constant t_pin_speed := 2#00#;
   SPEED_MEDIUM      : constant t_pin_speed := 2#01#;
   SPEED_HIGH        : constant t_pin_speed := 2#10#;
   SPEED_VERY_HIGH   : constant t_pin_speed := 2#11#;

   --------------------------------------------------------
   -- GPIO port pull-up/pull-down register (GPIOx_PUPDR) --
   --------------------------------------------------------

   type t_pin_pupd is new uint2;

   type t_pins_pupd is array (t_GPIO_pin_index) of t_pin_pupd
      with pack, size => 32;

   type t_GPIOx_PUPDR is record
      pin : t_pins_pupd;
   end record
      with pack, size => 32, volatile_full_access;

   FLOATING  : constant t_pin_pupd := 2#00#;
   PULL_UP   : constant t_pin_pupd := 2#01#;
   PULL_DOWN : constant t_pin_pupd := 2#10#;

   -----------------------------------------------
   -- GPIO port input data register (GPIOx_IDR) --
   -----------------------------------------------

   type t_pins_idr is array (t_GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_IDR is record
      pin      : t_pins_idr;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   ------------------------------------------------
   -- GPIO port output data register (GPIOx_ODR) --
   ------------------------------------------------

   type t_pins_odr is array (t_GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_ODR is record
      pin      : t_pins_odr;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   ---------------------------------------------------
   -- GPIO port bit set/reset register (GPIOx_BSRR) --
   ---------------------------------------------------

   type t_pins is array (t_GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_BSRR is record
      BS : t_pins;
      BR : t_pins;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------------------
   -- GPIO alternate function --
   -----------------------------

   type t_AF is new uint4; -- Alternate functions (0 .. 15)

   -- See RM0090, p. 274
   GPIO_AF_USART1 : constant t_AF := 7;
   GPIO_AF_USART2 : constant t_AF := 7;
   GPIO_AF_USART3 : constant t_AF := 7;
   GPIO_AF_UART4  : constant t_AF := 8;
   GPIO_AF_UART5  : constant t_AF := 8;
   GPIO_AF_USART6 : constant t_AF := 8;
   GPIO_AF_SDIO   : constant t_AF := 12;

   --
   -- GPIOx_AFRL - pins 0 .. 7
   --
   type t_AF_0_7 is array (0 .. 7) of t_AF
      with pack;

   type t_GPIOx_AFRL is record
      pin  : t_AF_0_7;
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- GPIOx_AFRH - pins 8 .. 15
   --

   type t_AF_8_15 is array (8 .. 15) of t_AF
      with pack;

   type t_GPIOx_AFRH is record
      pin  : t_AF_8_15;
   end record
      with pack, size => 32, volatile_full_access;

   --------------------------
   -- GPIO port definition --
   --------------------------

   type t_GPIO_port is record
      MODER       : t_GPIOx_MODER;
      OTYPER      : t_GPIOx_OTYPER;
      OSPEEDR     : t_GPIOx_OSPEEDR;
      PUPDR       : t_GPIOx_PUPDR;
      IDR         : t_GPIOx_IDR;
      ODR         : t_GPIOx_ODR;
      BSRR        : t_GPIOx_BSRR;
      GPIOx_LCKR  : word;
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
      GPIOx_LCKR  at 16#1C# range 0 .. 31;
      AFRL        at 16#20# range 0 .. 31;
      AFRH        at 16#24# range 0 .. 31;
   end record;

   type t_GPIO_port_access is access all t_GPIO_port;

   --------------
   -- GPIO pin --
   --------------

   type t_GPIO_pin is record
      gpio        : t_GPIO_port_access;
      pin_number  : t_GPIO_pin_index;
   end record;

   ---------------
   -- Utilities --
   ---------------

   procedure configure
     (pin      : t_GPIO_pin;
      mode     : t_pin_mode;
      otype    : t_pin_output_type;
      ospeed   : t_pin_speed;
      pupd     : t_pin_pupd);

   procedure configure
     (pin      : t_GPIO_pin;
      mode     : t_pin_mode;
      pupd     : t_pin_pupd);

   procedure set_alternate_function
     (pin      : t_GPIO_pin;
      af       : t_AF);
   pragma inline (set_alternate_function);

   procedure output
     (pin      : t_GPIO_pin;
      value    : bit);
   pragma inline (output);

   function input
     (pin      : t_GPIO_pin)
      return bit;
   pragma inline (input);

   procedure turn_on (pin : t_GPIO_pin);
   pragma inline (turn_on);

   procedure turn_off (pin : t_GPIO_pin);
   pragma inline (turn_off);

   procedure toggle (pin : t_GPIO_pin);
   pragma inline (toggle);

end stm32f4.gpio;
