with stm32f4.gpio;

--
-- Ref. : RM0090, p. 224-268
--

package stm32f4.rcc is

   type t_RCC_CR is record
      HSION          : boolean;  -- Internal high-speed clock enable
      HSIRDY         : boolean;  -- Internal high-speed clock ready flag
      Reserved_2_2   : bit;
      HSITRIM        : uint5;    -- Internal high-speed clock trimming
      HSICAL         : byte;     -- Internal high-speed clock calibration
      HSEON          : boolean;  -- HSE clock enable
      HSERDY         : boolean;  -- HSE clock ready flag
      HSEBYP         : boolean;  -- HSE clock bypassed (with an ext. clock)
      CSSON          : boolean;  -- Clock security system enable
      Reserved_20_23 : uint4;
      PLLON          : boolean;  -- Main PLL enable
      PLLRDY         : boolean;  -- Main PLL clock ready flag
      PLLI2SON       : boolean;  -- PLLI2S enable
      PLLI2SRDY      : boolean;  -- PLLI2S clock ready flag
      Reserved_28_31 : uint4;
   end record
     with volatile_full_access, size => 32;

   for t_RCC_CR use record
      HSION          at 0 range 0 .. 0;
      HSIRDY         at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      HSITRIM        at 0 range 3 .. 7;
      HSICAL         at 0 range 8 .. 15;
      HSEON          at 0 range 16 .. 16;
      HSERDY         at 0 range 17 .. 17;
      HSEBYP         at 0 range 18 .. 18;
      CSSON          at 0 range 19 .. 19;
      Reserved_20_23 at 0 range 20 .. 23;
      PLLON          at 0 range 24 .. 24;
      PLLRDY         at 0 range 25 .. 25;
      PLLI2SON       at 0 range 26 .. 26;
      PLLI2SRDY      at 0 range 27 .. 27;
      Reserved_28_31 at 0 range 28 .. 31;
   end record;

   -----------------
   -- RCC_AHB1ENR --
   -----------------

   -- RCC AHB1 peripheral clock enable register 
   -- Ref. : RM0090, p. 242

   type t_RCC_AHB1ENR is record
      GPIOAEN        : boolean;   -- IO port A clock enable
      GPIOBEN        : boolean;   -- IO port B clock enable
      GPIOCEN        : boolean;   -- IO port C clock enable
      GPIODEN        : boolean;   -- IO port D clock enable
      GPIOEEN        : boolean;   -- IO port E clock enable
      GPIOFEN        : boolean;   -- IO port F clock enable
      GPIOGEN        : boolean;   -- IO port G clock enable
      GPIOHEN        : boolean;   -- IO port H clock enable
      GPIOIEN        : boolean;   -- IO port I clock enable
      reserved_9_11  : uint3;
      CRCEN          : boolean;   -- CRC clock enable
      reserved_13_17 : uint5;
      BKPSRAMEN      : boolean;   -- Backup SRAM interface clock enable
      reserved_19    : bit;
      CCMDATARAMEN   : boolean;   -- CCM data RAM clock enable
      DMA1EN         : boolean;   -- DMA1 clock enable
      DMA2EN         : boolean;   -- DMA2 clock enable
      reserved_23_24 : bit;
      ETHMACEN       : boolean;   -- Ethernet MAC clock enable
      ETHMACTXEN     : boolean;   -- Ethernet Transmission clock enable
      ETHMACRXEN     : boolean;   -- Ethernet Reception clock enable
      ETHMACPTPEN    : boolean;   -- Ethernet PTP clock enable
      OTGHSEN        : boolean;   -- USB OTG HS clock enable
      OTGHSULPIEN    : boolean;   -- USB OTG HSULPI clock enable
      reserved_31    : bit;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------
   -- RCC_APB1ENR --
   -----------------

   type t_RCC_APB1ENR is record
      TIM2EN         : boolean;  -- TIM2 clock enable
      TIM3EN         : boolean;  -- TIM3 clock enable
      TIM4EN         : boolean;  -- TIM4 clock enable
      TIM5EN         : boolean;  -- TIM5 clock enable
      TIM6EN         : boolean;  -- TIM6 clock enable
      TIM7EN         : boolean;  -- TIM7 clock enable
      TIM12EN        : boolean;  -- TIM12 clock enable
      TIM13EN        : boolean;  -- TIM13 clock enable
      TIM14EN        : boolean;  -- TIM14 clock enable
      reserved_9_10  : uint2;
      WWDGEN         : boolean;  -- Window watchdog clock enable
      reserved_12_13 : uint2;
      SPI2EN         : boolean;  -- SPI2 clock enable
      SPI3EN         : boolean;  -- SPI3 clock enable
      reserved_16    : boolean;
      USART2EN       : boolean;  -- USART2 clock enable
      USART3EN       : boolean;  -- USART3 clock enable
      UART4EN        : boolean;  -- UART4 clock enable
      UART5EN        : boolean;  -- UART5 clock enable
      I2C1EN         : boolean;  -- I2C1 clock enable
      I2C2EN         : boolean;  -- I2C2 clock enable
      I2C3EN         : boolean;  -- I2C3 clock enable
      reserved_24    : bit;
      CAN1EN         : boolean;  -- CAN 1 clock enable
      CAN2EN         : boolean;  -- CAN 2 clock enable
      reserved_27    : bit;
      PWREN          : boolean;  -- Power interface clock enable
      DACEN          : boolean;  -- DAC interface clock enable
      UART7EN        : boolean;  -- UART7 clock enable
      UART8EN        : boolean;  -- UART8 clock enable   
   end record
      with pack, size => 32, volatile_full_access;

   -----------------
   -- RCC_APB2ENR --
   -----------------

   -- RCC APB2 peripheral clock enable register 
   -- Ref. : RM0090, p. 248

   type t_RCC_APB2ENR is record
      TIM1EN         : boolean;  -- TIM1 clock enable
      TIM8EN         : boolean;  -- TIM8 clock enable
      reserved_2_3   : uint2;
      USART1EN       : boolean;  -- USART1 clock enable
      USART6EN       : boolean;  -- USART6 clock enable
      reserved_6_7   : uint2;
      ADC1EN         : boolean;  -- ADC1 clock enable
      ADC2EN         : boolean;  -- ADC2 clock enable
      ADC3EN         : boolean;  -- ADC3 clock enable
      SDIOEN         : boolean;  -- SDIO clock enable
      SPI1EN         : boolean;  -- SPI1 clock enable
      reserved_13    : bit;
      SYSCFGEN       : boolean;
         -- System configuration controller clock enable
      reserved_15    : bit;
      TIM9EN         : boolean;  -- TIM9 clock enable
      TIM10EN        : boolean;  -- TIM10 clock enable
      TIM11EN        : boolean;  -- TIM11 clock enable
      reserved_19_23 : uint5;
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;
   
   --------------------
   -- RCC peripheral --
   --------------------

   type t_RCC_periph is record
      CR       : t_RCC_CR;
      AHB1ENR  : t_RCC_AHB1ENR;
      APB1ENR  : t_RCC_APB1ENR;
      APB2ENR  : t_RCC_APB2ENR;
   end record;

   for t_RCC_periph use record
      CR       at 16#00# range 0 .. 31;
      AHB1ENR  at 16#30# range 0 .. 31;
      APB1ENR  at 16#40# range 0 .. 31;
      APB2ENR  at 16#44# range 0 .. 31;
   end record;


   procedure enable_gpio_clock
     (GPIOx : aliased in gpio.t_GPIO_port);

   procedure enable_gpio_clock
     (pin   : gpio.t_GPIO_pin);

end stm32f4.rcc;
