
--
-- Ref. : RM0090, p. 283-290
-- Note: GPIO registers can be accessed by byte, half-words or words
--

package stm32f4.gpio is

   subtype GPIO_pin_index is natural range 0 .. 15;

   --
   -- GPIO port mode register (GPIOx_MODER) 
   --

   type t_pin_mode is new uint2;

   type t_pins_mode is array (GPIO_pin_index) of t_pin_mode
      with pack, size => 32;

   type t_GPIOx_MODER is record
      pin : t_pins_mode;
   end record
      with pack, size => 32, volatile_full_access;
   -- Note: 'volatile_full_access aspect': the register is volatile and
   -- the full 32-bits needs to be written at once. 

   MODE_IN     : constant t_pin_mode := 2#00#; -- Input (reset state)
   MODE_OUT    : constant t_pin_mode := 2#01#; -- Output
   MODE_ALT    : constant t_pin_mode := 2#10#; -- Alternate function
   MODE_ANALOG : constant t_pin_mode := 2#11#; -- Analog

   --
   -- GPIO port output type register (GPIOx_OTYPER) 
   --

   type t_pin_output_type is new bit;

   type t_pins_output_type is array (GPIO_pin_index) of t_pin_output_type
      with pack, size => 16;

   type t_GPIOx_OTYPER is record
      pin      : t_pins_output_type;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   PUSH_PULL    : constant t_pin_output_type := 0; 
   OPEN_DRAIN   : constant t_pin_output_type := 1;

   --
   -- GPIO port output speed register (GPIOx_OSPEEDR)
   --

   type t_pin_speed is new uint2;

   type t_pins_speed is array (GPIO_pin_index) of t_pin_speed
      with pack, size => 32;

   type t_GPIOx_OSPEEDR is record
      pin : t_pins_speed;
   end record
      with pack, size => 32, volatile_full_access;

   SPEED_LOW         : constant t_pin_speed := 2#00#;
   SPEED_MEDIUM      : constant t_pin_speed := 2#01#;
   SPEED_HIGH        : constant t_pin_speed := 2#10#;
   SPEED_VERY_HIGH   : constant t_pin_speed := 2#11#;

   --
   -- GPIO port pull-up/pull-down register (GPIOx_PUPDR)
   --

   type t_pin_pupd is new uint2;

   type t_pins_pupd is array (GPIO_pin_index) of t_pin_pupd
      with pack, size => 32;

   type t_GPIOx_PUPDR is record
      pin : t_pins_pupd;
   end record
      with pack, size => 32, volatile_full_access;

   FLOATING  : constant t_pin_pupd := 2#00#;
   PULL_UP   : constant t_pin_pupd := 2#01#;
   PULL_DOWN : constant t_pin_pupd := 2#10#;

   --
   -- GPIO port input data register (GPIOx_IDR)
   --

   type t_pins_idr is array (GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_IDR is record
      pin      : t_pins_idr;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- GPIO port output data register (GPIOx_ODR)
   --

   type t_pins_odr is array (GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_ODR is record
      pin      : t_pins_odr;
      reserved : short;
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- GPIO port bit set/reset register (GPIOx_BSRR)
   --

   type t_pins is array (GPIO_pin_index) of bit
      with pack, size => 16;

   type t_GPIOx_BSRR is record
      BS : t_pins;
      BR : t_pins;
   end record
      with pack, size => 32, volatile_full_access;

   --
   -- GPIO port definition
   --

   type t_GPIO_port is record
      MODER    : t_GPIOx_MODER;
      OTYPER   : t_GPIOx_OTYPER;
      OSPEEDR  : t_GPIOx_OSPEEDR;
      PUPDR    : t_GPIOx_PUPDR;
      IDR      : t_GPIOx_IDR;
      ODR      : t_GPIOx_ODR;
      BSRR     : t_GPIOx_BSRR;
   end record
      with volatile;

end stm32f4.gpio;
