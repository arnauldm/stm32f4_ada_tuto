with interfaces.stm32; use type interfaces.stm32.uint32;
with stm32f4.layout;

package stm32f4.usart
   with spark_mode => on
is

   --------------------------------
   -- Status register (USART_SR) --
   --------------------------------

   type t_USART_SR is record
      PE    : bit;   -- Parity error
      FE    : bit;   -- Framing error
      NF    : bit;   -- Noise detected flag
      ORE   : bit;   -- Overrun error
      IDLE  : bit;   -- IDLE line detected
      RXNE  : bit;   -- Read data register not empty
      TC    : bit;   -- Transmission complete
      TXE   : bit;   -- Transmit data register empty
      LBD   : bit;   -- LIN break detection flag
      CTS   : bit;   -- CTS flag
   end record
      with size => 32, volatile_full_access;

   for t_USART_SR use record
      PE    at 0 range 0 .. 0;
      FE    at 0 range 1 .. 1;
      NF    at 0 range 2 .. 2;
      ORE   at 0 range 3 .. 3;
      IDLE  at 0 range 4 .. 4;
      RXNE  at 0 range 5 .. 5;
      TC    at 0 range 6 .. 6;
      TXE   at 0 range 7 .. 7;
      LBD   at 0 range 8 .. 8;
      CTS   at 0 range 9 .. 9;
   end record;

   ------------------------------
   -- Data register (USART_DR) --
   ------------------------------

   type t_USART_DR is new uint9
      with volatile_full_access, size => 32;

   ------------------------------------
   -- Baud rate register (USART_BRR) --
   ------------------------------------

   type t_USART_BRR is record
      DIV_FRACTION   : uint4;
      DIV_MANTISSA   : uint12;
   end record
      with size => 32, volatile_full_access;

   for t_USART_BRR use record
      DIV_FRACTION   at 0 range 0 .. 3;
      DIV_MANTISSA   at 0 range 4 .. 15;
   end record;

   ------------------------------------
   -- Control register 1 (USART_CR1) --
   ------------------------------------

   type t_parity is (EVEN, ODD) with size => 1;
   for t_parity use
     (EVEN => 0,
      ODD  => 1);

   type t_data_len is (DATA_8BITS, DATA_9BITS) with size => 1;
   for t_data_len use
     (DATA_8BITS => 0,
      DATA_9BITS => 1);

   type t_USART_CR1 is record
      SBK            : bit;         -- Send break
      RWU            : bit;         -- Receiver wakeup
      RE             : bit;         -- Receiver enable
      TE             : bit;         -- Transmitter enable
      IDLEIE         : bit;         -- IDLE interrupt enable
      RXNEIE         : bit;         -- RXNE interrupt enable
      TCIE           : bit;         -- Transmission complete interrupt enable
      TXEIE          : bit;         -- TXE interrupt enable
      PEIE           : bit;         -- PE interrupt enable
      PS             : t_parity;    -- Parity selection
      PCE            : bit;         -- Parity control enable
      WAKE           : bit;         -- Wakeup method
      M              : t_data_len;  -- Word length
      UE             : bit;         -- USART enable
      reserved_14_14 : bit;
      OVER8          : bit;         -- Oversampling mode
   end record
      with size => 32, volatile_full_access;

   for t_USART_CR1 use record
      SBK            at 0 range 0 .. 0;
      RWU            at 0 range 1 .. 1;
      RE             at 0 range 2 .. 2;
      TE             at 0 range 3 .. 3;
      IDLEIE         at 0 range 4 .. 4;
      RXNEIE         at 0 range 5 .. 5;
      TCIE           at 0 range 6 .. 6;
      TXEIE          at 0 range 7 .. 7;
      PEIE           at 0 range 8 .. 8;
      PS             at 0 range 9 .. 9;
      PCE            at 0 range 10 .. 10;
      WAKE           at 0 range 11 .. 11;
      M              at 0 range 12 .. 12;
      UE             at 0 range 13 .. 13;
      Reserved_14_14 at 0 range 14 .. 14;
      OVER8          at 0 range 15 .. 15;
   end record;

   ------------------------------------
   -- Control register 2 (USART_CR2) --
   ------------------------------------

   type t_stop_bits is (STOP_1, STOP_0_dot_5, STOP_2, STOP_1_dot_5)
      with size => 2;
   for t_stop_bits use
     (STOP_1         => 2#00#,
      STOP_0_dot_5   => 2#01#,
      STOP_2         => 2#10#,
      STOP_1_dot_5   => 2#11#);

   type t_USART_CR2 is record
      ADD            : uint4;
         -- Address of the USART node (used in multiprocessor communication
         -- during mute mode, for wake up with address mark detection).
      reserved_4_4   : bit;
      LBDL           : bit;   -- LIN break detection length
      LBDIE          : bit;   -- LIN break detection interrupt enable
      reserved_7_7   : bit;
      LBCL           : bit;   -- Last bit clock pulse
      CPHA           : bit;   -- Clock phase
      CPOL           : bit;   -- Clock polarity
      CLKEN          : bit;   -- Clock enable
      STOP           : t_stop_bits;
      LINEN          : bit;   -- LIN mode enable
   end record
      with size => 32, volatile_full_access;

   for t_USART_CR2 use record
      ADD            at 0 range 0 .. 3;
      reserved_4_4   at 0 range 4 .. 4;
      LBDL           at 0 range 5 .. 5;
      LBDIE          at 0 range 6 .. 6;
      reserved_7_7   at 0 range 7 .. 7;
      LBCL           at 0 range 8 .. 8;
      CPHA           at 0 range 9 .. 9;
      CPOL           at 0 range 10 .. 10;
      CLKEN          at 0 range 11 .. 11;
      STOP           at 0 range 12 .. 13;
      LINEN          at 0 range 14 .. 14;
   end record;

   ------------------------------------
   -- Control register 3 (USART_CR3) --
   ------------------------------------

   type t_USART_CR3 is record
      EIE            : bit;   -- Error interrupt enable
      IREN           : bit;   -- IrDA mode enable
      IRLP           : bit;   -- IrDA low-power
      HDSEL          : bit;   -- Half-duplex selection
      NACK           : bit;   -- Smartcard NACK enable
      SCEN           : bit;   -- Smartcard mode enable
      DMAR           : bit;   -- DMA enable receiver
      DMAT           : bit;   -- DMA enable transmitter
      RTSE           : bit;   -- RTS enable
      CTSE           : bit;   -- CTS enable
      CTSIE          : bit;   -- CTS interrupt enable
      ONEBIT         : bit;   -- One sample bit method enable
   end record
      with size => 32, volatile_full_access;

   for t_USART_CR3 use record
      EIE            at 0 range 0 .. 0;
      IREN           at 0 range 1 .. 1;
      IRLP           at 0 range 2 .. 2;
      HDSEL          at 0 range 3 .. 3;
      NACK           at 0 range 4 .. 4;
      SCEN           at 0 range 5 .. 5;
      DMAR           at 0 range 6 .. 6;
      DMAT           at 0 range 7 .. 7;
      RTSE           at 0 range 8 .. 8;
      CTSE           at 0 range 9 .. 9;
      CTSIE          at 0 range 10 .. 10;
      ONEBIT         at 0 range 11 .. 11;
   end record;

   ----------------------------------------------------
   -- Guard time and prescaler register (USART_GTPR) --
   ----------------------------------------------------

   type t_USART_GTPR is record
      PSC   : unsigned_8; -- Prescaler value
      GT    : unsigned_8; -- Guard time value
   end record
     with volatile_full_access, size => 32;

   for t_USART_GTPR use record
      PSC   at 0 range 0 .. 7;
      GT    at 0 range 8 .. 15;
   end record;

   ----------------------
   -- USART Peripheral --
   ----------------------

   type t_USART_peripheral is record
      SR    : t_USART_SR;
      DR    : t_USART_DR;
      BRR   : t_USART_BRR;
      CR1   : t_USART_CR1;
      CR2   : t_USART_CR2;
      CR3   : t_USART_CR3;
      GTPR  : t_USART_GTPR;
   end record
      with volatile;

   for t_USART_peripheral use record
      SR    at 16#00# range 0 .. 31;
      DR    at 16#04# range 0 .. 31;
      BRR   at 16#08# range 0 .. 31;
      CR1   at 16#0C# range 0 .. 31;
      CR2   at 16#10# range 0 .. 31;
      CR3   at 16#14# range 0 .. 31;
      GTPR  at 16#18# range 0 .. 31;
   end record;

   USART1   : t_USART_peripheral
      with
         import, volatile, address => stm32f4.layout.USART1_BASE;

   USART3   : t_USART_peripheral
      with
         import, volatile, address => stm32f4.layout.USART3_BASE;

   USART6   : t_USART_peripheral
      with
         import, volatile, address => stm32f4.layout.USART6_BASE;

   ---------------
   -- Utilities --
   ---------------

   type t_parity_select is (PARITY_EVEN, PARITY_ODD, PARITY_NONE);

   procedure configure
     (usartx   : in out t_USART_peripheral;
      clock    : in     unsigned_32;
      baudrate : in     unsigned_32;
      data     : in     t_data_len;
      parity   : in     t_parity_select;
      stop     : in     t_stop_bits;
      success  : out    boolean)
   with
      pre => (baudrate >= 2400 and baudrate <= 115_200);

   procedure transmit
     (usart : in out t_USART_peripheral;
      data  : in     uint9);

   procedure receive
     (usart : in out t_USART_peripheral;
      data  : out    uint9);

end stm32f4.usart;
