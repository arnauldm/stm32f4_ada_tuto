with stm32f4.gpio;

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
      GPIOAEN        : bit;   -- IO port A clock enable
      GPIOBEN        : bit;   -- IO port B clock enable
      GPIOCEN        : bit;   -- IO port C clock enable
      GPIODEN        : bit;   -- IO port D clock enable
      GPIOEEN        : bit;   -- IO port E clock enable
      GPIOFEN        : bit;   -- IO port F clock enable
      GPIOGEN        : bit;   -- IO port G clock enable
      GPIOHEN        : bit;   -- IO port H clock enable
      GPIOIEN        : bit;   -- IO port I clock enable
      reserved_9_11  : uint3;
      CRCEN          : bit;   -- CRC clock enable
      reserved_13_17 : uint5;
      BKPSRAMEN      : bit;   -- Backup SRAM interface clock enable
      reserved_19    : bit;
      CCMDATARAMEN   : bit;   -- CCM data RAM clock enable
      DMA1EN         : bit;   -- DMA1 clock enable
      DMA2EN         : bit;   -- DMA2 clock enable
      reserved_23_24 : bit;
      ETHMACEN       : bit;   -- Ethernet MAC clock enable
      ETHMACTXEN     : bit;   -- Ethernet Transmission clock enable
      ETHMACRXEN     : bit;   -- Ethernet Reception clock enable
      ETHMACPTPEN    : bit;   -- Ethernet PTP clock enable
      OTGHSEN        : bit;   -- USB OTG HS clock enable
      OTGHSULPIEN    : bit;   -- USB OTG HSULPI clock enable
      reserved_31    : bit;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------
   -- RCC_APB2ENR --
   -----------------

   -- RCC APB2 peripheral clock enable register 
   -- Ref. : RM0090, p. 248

   type t_RCC_APB2ENR is record
      TIM1EN         : bit;   -- TIM1 clock enable
      TIM8EN         : bit;   -- TIM8 clock enable
      reserved_2_3   : uint2;
      USART1EN       : bit;   -- USART1 clock enable
      USART6EN       : bit;   -- USART6 clock enable
      reserved_6_7   : uint2;
      ADC1EN         : bit;   -- ADC1 clock enable
      ADC2EN         : bit;   -- ADC2 clock enable
      ADC3EN         : bit;   -- ADC3 clock enable
      SDIOEN         : bit;   -- SDIO clock enable
      SPI1EN         : bit;   -- SPI1 clock enable
      reserved_13    : bit;
      SYSCFGEN       : bit;
         -- System configuration controller clock enable
      reserved_15    : bit;
      TIM9EN         : bit;   -- TIM9 clock enable
      TIM10EN        : bit;   -- TIM10 clock enable
      TIM11EN        : bit;   -- TIM11 clock enable
      reserved_19_23 : uint5;
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;
   
   --------------------
   -- RCC peripheral --
   --------------------

   type t_RCC_periph is record
      AHB1ENR  : t_RCC_AHB1ENR;
      APB2ENR  : t_RCC_APB2ENR;
   end record;

   for t_RCC_periph use record
      AHB1ENR  at 16#30# range 0 .. 31;
      APB2ENR  at 16#44# range 0 .. 31;
   end record;


   procedure enable_gpio_clock
     (GPIOx : aliased in gpio.t_GPIO_port);

end stm32f4.rcc;
