
--
-- Ref. : RM0090, p. 224-268
--

package stm32f4.rcc is

   -----------------
   -- RCC_AHB1ENR --
   -----------------

   -- RCC AHB1 peripheral clock enable register 
   -- Ref. : RM0090, p. 242

   type t_RCC_AHB1ENR is record
      GPIOAEN        : bit;
      GPIOBEN        : bit;
      GPIOCEN        : bit;
      GPIODEN        : bit;
      GPIOEEN        : bit;
      GPIOFEN        : bit;
      GPIOGEN        : bit;
      GPIOHEN        : bit;
      GPIOIEN        : bit;
      reserved_9_11  : uint3;
      CRCEN          : bit;
      reserved_13_17 : uint5;
      BKPSRAMEN      : bit;
      reserved_19    : bit;
      CCMDATARAMEN   : bit;
      DMA1EN         : bit;
      DMA2EN         : bit;
      reserved_23_24 : bit;
      ETHMACEN       : bit;
      ETHMACTXEN     : bit;
      ETHMACRXEN     : bit;
      ETHMACPTPEN    : bit;
      OTGHSEN        : bit;
      OTGHSULPIEN    : bit;
      reserved_31    : bit;
   end record
      with pack, size => 32, volatile_full_access;

   type t_RCC_periph is record
      AHB1ENR  : t_RCC_AHB1ENR;
   end record;

   for t_RCC_periph use record
      AHB1ENR  at 16#30# range 0 .. 31;
   end record;

end stm32f4.rcc;
