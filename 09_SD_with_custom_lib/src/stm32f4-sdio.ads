with ada.unchecked_conversion;
with stm32f4.dma;

--
-- Ref. : RM0090, p. 1022-1078
--

package stm32f4.sdio is

   ----------------------------------------------
   -- SDIO power control register (SDIO_POWER) --
   ----------------------------------------------

   type t_pwrctrl is (POWER_OFF, POWER_ON) with size => 2;
   for t_pwrctrl use
     (POWER_OFF   => 2#00#,
      POWER_ON    => 2#11#);

   type t_SDIO_POWER is record
      PWRCTRL  : t_pwrctrl;
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_POWER use record
      PWRCTRL at 0 range 0 .. 1;
   end record;

   ---------------------------------------------
   -- SDI clock control register (SDIO_CLKCR) --
   ---------------------------------------------

   -- The SDIO_CLKCR register controls the SDIO_CK output clock.

   type t_widbus is
     (WIDBUS_1WIDE_MODE, WIDBUS_4WIDE_MODE, WIDBUS_8WIDE_MODE)
      with size => 2;
   for t_widbus use
     (WIDBUS_1WIDE_MODE => 2#00#,
      WIDBUS_4WIDE_MODE => 2#01#,
      WIDBUS_8WIDE_MODE => 2#10#);

   type t_negedge is (RISING_EDGE, FALLING_EDGE) with size => 1;
   for t_negedge use
     (RISING_EDGE    => 0,
      FALLING_EDGE   => 1);

   type t_SDIO_CLKCR is record
      CLKDIV   : byte;        -- Clock divide factor
      CLKEN    : boolean;     -- Clock enable bit
      PWRSAV   : boolean;     -- Power saving configuration bit
      BYPASS   : boolean;     -- Clock divider bypass enable bit
      WIDBUS   : t_widbus;    -- Wide bus mode enable bit
      NEGEDGE  : t_negedge;   -- SDIO_CK dephasing selection bit
      HWFC_EN  : boolean;     -- HW Flow Control enable
      -- reserved_15_31
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_CLKCR use record
      CLKDIV   at 0 range 0 .. 7;
      CLKEN    at 0 range 8 .. 8;
      PWRSAV   at 0 range 9 .. 9;
      BYPASS   at 0 range 10 .. 10;
      WIDBUS   at 0 range 11 .. 12;
      NEGEDGE  at 0 range 13 .. 13;
      HWFC_EN  at 0 range 14 .. 14;
   end record;

   ---------------------------------------
   -- SDIO argument register (SDIO_ARG) --
   ---------------------------------------

   -- Command argument sent to a card as part of a command message.
   subtype t_SDIO_ARG is word;

   --------------------------------------
   -- SDIO command register (SDIO_CMD) --
   --------------------------------------

   subtype t_cmd_index is uint6;

   type t_waitresp is
     (NO_RESPONSE, SHORT_RESPONSE, NO_RESPONSE2, LONG_RESPONSE)
      with size => 2;
   for t_waitresp use
     (NO_RESPONSE    => 2#00#,
      SHORT_RESPONSE => 2#01#,
      NO_RESPONSE2   => 2#10#, 
      LONG_RESPONSE  => 2#11#);

   type t_SDIO_CMD is record
      CMDINDEX    : t_cmd_index; -- Command index
      WAITRESP    : t_waitresp;  -- Wait for response bits
      WAITINT     : bit;
         -- If this bit is set, the CPSM disables command timeout and waits for
         -- an interrupt request.
      WAITPEND    : bit;
         -- If this bit is set, the CPSM waits for the end of data transfer
         -- before it starts sending a command.
      CPSMEN      : bit;         -- Command path state machine (CPSM) Enable bit
      SDIOSUSPEND : bit;         -- SD I/O suspend command
      ENCMDCOMPL  : bit;         -- Enable CMD completion
      NIEN        : bit;         -- not Interrupt Enable
      ATACMD      : bit;         -- CE-ATA command
      reserved_15 : bit;
      reserved_16_31 : short;
   end record
      with pack, size => 32, volatile_full_access;
      -- (*) CPSM: Command path state machine

   ---------------------------------------------------
   -- SDIO command response register (SDIO_RESPCMD) --
   ---------------------------------------------------

   type t_SDIO_RESPCMD is record
      CMD  : t_cmd_index; -- Response command index
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_RESPCMD use record
      CMD at 0 range 0 .. 5;
   end record;

   ----------------------------------------------
   -- SDIO response 1..4 register (SDIO_RESPx) --
   ----------------------------------------------

   subtype t_SDIO_RESPx is word;

   --------------------------------------------
   -- SDIO data timer register (SDIO_DTIMER) --
   --------------------------------------------

   subtype t_SDIO_DTIMER is word;

   -------------------------------------------
   -- SDIO data length register (SDIO_DLEN) --
   -------------------------------------------

   type t_SDIO_DLEN is record
      DATALENGTH  : uint25; -- Data length value
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_DLEN use record
      DATALENGTH at 0 range 0 .. 24;
   end record;

   ---------------------------------------------
   -- SDIO data control register (SDIO_DCTRL) --
   ---------------------------------------------

   type t_dtdir is
     (TO_CARD, TO_HOST) with size => 1;
   for t_dtdir use
     (TO_CARD  => 0,
      TO_HOST  => 1);

   type t_dtmode is
     (MODE_BLOCK, MODE_STREAM) with size => 1;
   for t_dtmode use
     (MODE_BLOCK  => 0,
      MODE_STREAM => 1);

   type t_blsize is
     (BLOCK_1BYTE, BLOCK_2BYTES, BLOCK_4BYTES, BLOCK_8BYTES, BLOCK_16BYTES,
      BLOCK_32BYTES, BLOCK_64BYTES, BLOCK_128BYTES, BLOCK_256BYTES,
      BLOCK_512BYTES, BLOCK_1KBYTE, BLOCK_2KBYTES, BLOCK_4KBYTES,
      BLOCK_8KBYTES, BLOCK_16KBYTES)
      with size => 4;

   for t_blsize use
     (BLOCK_1BYTE    => 0,
      BLOCK_2BYTES   => 1,
      BLOCK_4BYTES   => 2,
      BLOCK_8BYTES   => 3,
      BLOCK_16BYTES  => 4,
      BLOCK_32BYTES  => 5,
      BLOCK_64BYTES  => 6,
      BLOCK_128BYTES => 7,
      BLOCK_256BYTES => 8,
      BLOCK_512BYTES => 9,
      BLOCK_1KBYTE   => 10,
      BLOCK_2KBYTES  => 11,
      BLOCK_4KBYTES  => 12,
      BLOCK_8KBYTES  => 13,
      BLOCK_16KBYTES => 14);

   type t_rwmode is
     (RWMOD_SDIO_D2, RWMOD_SDIO_CK) with size => 1;
   for t_rwmode use
     (RWMOD_SDIO_D2  => 0,
      RWMOD_SDIO_CK  => 1);

   type t_SDIO_DCTRL is record
      DTEN        : bit       := 0;          -- Data transfer enabled bit
      DTDIR       : t_dtdir   := TO_CARD;    -- Data transfer direction 
      DTMODE      : t_dtmode  := MODE_BLOCK; -- Data transfer mode 
      DMAEN       : bit       := 0;          -- DMA enable bit
      DBLOCKSIZE  : t_blsize  := BLOCK_1BYTE;-- Data block size (2^n)
      RWSTART     : bit       := 0;          -- Read wait start
      RWSTOP      : bit       := 0;          -- Read wait stop
      RWMOD       : t_rwmode  := RWMOD_SDIO_D2; -- Read wait mode
      SDIOEN      : bit       := 0;          -- SD I/O-card-specific operation
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_DCTRL use record
      DTEN        at 0 range 0 .. 0;
      DTDIR       at 0 range 1 .. 1;
      DTMODE      at 0 range 2 .. 2;
      DMAEN       at 0 range 3 .. 3;
      DBLOCKSIZE  at 0 range 4 .. 7;
      RWSTART     at 0 range 8 .. 8;
      RWSTOP      at 0 range 9 .. 9;
      RWMOD       at 0 range 10 .. 10;
      SDIOEN      at 0 range 11 .. 11;
   end record;

   ----------------------------------------------
   -- SDIO data counter register (SDIO_DCOUNT) --
   ----------------------------------------------

   type t_SDIO_DCOUNT is record
      DATACOUNT   : uint25;   -- Data count value
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_DCOUNT use record
      DATACOUNT at 0 range 0 .. 24;
   end record;

   -------------------------------------
   -- SDIO status register (SDIO_STA) --
   -------------------------------------

   type t_SDIO_STA is record
      CCRCFAIL : boolean;  -- Command response received (CRC check failed)
      DCRCFAIL : boolean;  -- Data block sent/received (CRC check failed)
      CTIMEOUT : boolean;  -- Command response timeout
      DTIMEOUT : boolean;  -- Data timeout
      TXUNDERR : boolean;  -- Transmit FIFO underrun error
      RXOVERR  : boolean;  -- Received FIFO overrun error
      CMDREND  : boolean;  -- Command response received (CRC check passed)
      CMDSENT  : boolean;  -- Command sent (no response required)
      DATAEND  : boolean;  -- Data end (data counter, SDIDCOUNT, is zero)
      STBITERR : boolean;  -- Start bit not detected on all data signals in
                           -- wide bus mode
      DBCKEND  : boolean;  -- Data block sent/received (CRC check passed)
      CMDACT   : boolean;  -- Command transfer in progress
      TXACT    : boolean;  -- Data transmit in progress
      RXACT    : boolean;  -- Data receive in progress
      TXFIFOHE : boolean;  -- Transmit FIFO half empty
      RXFIFOHF : boolean;  -- Receive FIFO half full
      TXFIFOF  : boolean;  -- Transmit FIFO full
      RXFIFOF  : boolean;  -- Receive FIFO full
      TXFIFOE  : boolean;  -- Transmit FIFO empty
      RXFIFOE  : boolean;  -- Receive FIFO empty
      TXDAVL   : boolean;  -- Data available in transmit FIFO
      RXDAVL   : boolean;  -- Data available in receive FIFO
      SDIOIT   : boolean;  -- SDIO interrupt received
      CEATAEND : boolean;  -- CE-ATA command completion signal received for CMD61
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   ----------------------------------------------
   -- SDIO interrupt clear register (SDIO_ICR) --
   ----------------------------------------------
   -- As its name doesn't say: it clear the *status* flags!

   type t_clear_bit is (DONT_CLEAR, CLEAR) with size => 1;
   for t_clear_bit use
     (DONT_CLEAR => 0,
      CLEAR     => 1);

   type t_SDIO_ICR is record
      CCRCFAILC   : t_clear_bit := CLEAR;
      DCRCFAILC   : t_clear_bit := CLEAR;
      CTIMEOUTC   : t_clear_bit := CLEAR;
      DTIMEOUTC   : t_clear_bit := CLEAR;
      TXUNDERRC   : t_clear_bit := CLEAR;
      RXOVERRC    : t_clear_bit := CLEAR;
      CMDRENDC    : t_clear_bit := CLEAR;
      CMDSENTC    : t_clear_bit := CLEAR;
      DATAENDC    : t_clear_bit := CLEAR;
      STBITERRC   : t_clear_bit := CLEAR;
      DBCKENDC    : t_clear_bit := CLEAR;
      --reserved_11_15
      --reserved_16_21
      SDIOITC     : t_clear_bit := CLEAR;
      CEATAENDC   : t_clear_bit := CLEAR;
      --reserved_24_31 
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_ICR use record
      CCRCFAILC   at 0 range 0 .. 0;
      DCRCFAILC   at 0 range 1 .. 1;
      CTIMEOUTC   at 0 range 2 .. 2;
      DTIMEOUTC   at 0 range 3 .. 3;
      TXUNDERRC   at 0 range 4 .. 4;
      RXOVERRC    at 0 range 5 .. 5;
      CMDRENDC    at 0 range 6 .. 6;
      CMDSENTC    at 0 range 7 .. 7;
      DATAENDC    at 0 range 8 .. 8;
      STBITERRC   at 0 range 9 .. 9;
      DBCKENDC    at 0 range 10 .. 10;
      SDIOITC     at 0 range 22 .. 22;
      CEATAENDC   at 0 range 23 .. 23;
   end record;

   ------------------------------------
   -- SDIO mask register (SDIO_MASK) --
   ------------------------------------

   type t_SDIO_MASK is record
      CCRCFAIL   : boolean; -- Command CRC fail interrupt enable
      DCRCFAIL   : boolean; -- Data CRC fail interrupt enable
      CTIMEOUT   : boolean; -- Command timeout interrupt enable
      DTIMEOUT   : boolean; -- Data timeout interrupt enable
      TXUNDERR   : boolean; -- Tx FIFO underrun error interrupt enable
      RXOVERR    : boolean; -- Rx FIFO overrun error interrupt enable
      CMDREND    : boolean; -- Command response received interrupt enable
      CMDSENT    : boolean; -- Command sent interrupt enable
      DATAEND    : boolean; -- Data end interrupt enable
      STBITERR   : boolean; -- Start bit error interrupt enable
      DBCKEND    : boolean; -- Data block end interrupt enable
      CMDACT     : boolean; -- Command acting interrupt enable
      TXACT      : boolean; -- Data transmit acting interrupt enable
      RXACT      : boolean; -- Data receive acting interrupt enable
      TXFIFOHE   : boolean; -- Tx FIFO half empty interrupt enable
      RXFIFOHF   : boolean; -- Rx FIFO half empty interrupt enable
      TXFIFOF    : boolean; -- Tx FIFO full interrupt enable
      RXFIFOF    : boolean; -- Rx FIFO full interrupt enable
      TXFIFOE    : boolean; -- Tx FIFO empty interrupt enable
      RXFIFOE    : boolean; -- Rx FIFO empty interrupt enable
      TXDAVL     : boolean; -- Data available in Tx FIFO interrupt enable
      RXDAVL     : boolean; -- Data available in Rx FIFO interrupt enable
      SDIOIT     : boolean; -- SDIO mode interrupt received interrupt enable
      CEATAEND   : boolean; -- CE-ATA command completion signal received
                            -- interrupt enable
      -- reserved_24_31 
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_MASK use record
      CCRCFAIL   at 0 range 0 .. 0;
      DCRCFAIL   at 0 range 1 .. 1;
      CTIMEOUT   at 0 range 2 .. 2;
      DTIMEOUT   at 0 range 3 .. 3;
      TXUNDERR   at 0 range 4 .. 4;
      RXOVERR    at 0 range 5 .. 5;
      CMDREND    at 0 range 6 .. 6;
      CMDSENT    at 0 range 7 .. 7;
      DATAEND    at 0 range 8 .. 8;
      STBITERR   at 0 range 9 .. 9;
      DBCKEND    at 0 range 10 .. 10;
      CMDACT     at 0 range 11 .. 11;
      TXACT      at 0 range 12 .. 12;
      RXACT      at 0 range 13 .. 13;
      TXFIFOHE   at 0 range 14 .. 14;
      RXFIFOHF   at 0 range 15 .. 15;
      TXFIFOF    at 0 range 16 .. 16;
      RXFIFOF    at 0 range 17 .. 17;
      TXFIFOE    at 0 range 18 .. 18;
      RXFIFOE    at 0 range 19 .. 19;
      TXDAVL     at 0 range 20 .. 20;
      RXDAVL     at 0 range 21 .. 21;
      SDIOIT     at 0 range 22 .. 22;
      CEATAEND   at 0 range 23 .. 23;
   end record;

   -----------------------------------------------
   -- SDIO FIFO counter register (SDIO_FIFOCNT) --
   -----------------------------------------------

   type t_SDIO_FIFOCNT is record
      FIFOCOUNT      : uint24;
         -- Remaining number of words to be written to or read from the FIFO
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   function to_word is new ada.unchecked_conversion
     (t_SDIO_FIFOCNT, word);

   -----------------------------------------
   -- SDIO data FIFO register (SDIO_FIFO) --
   -----------------------------------------

   subtype t_SDIO_FIFO is word;

   ---------------------
   -- SDIO Peripheral --
   ---------------------

   type t_SDIO_periph is record
      POWER    : t_SDIO_POWER;
      CLKCR    : t_SDIO_CLKCR;
      ARG      : t_SDIO_ARG;
      CMD      : t_SDIO_CMD;
      RESPCMD  : t_SDIO_RESPCMD;
      RESP1    : t_SDIO_RESPx;
      RESP2    : t_SDIO_RESPx;
      RESP3    : t_SDIO_RESPx;
      RESP4    : t_SDIO_RESPx;
      DTIMER   : t_SDIO_DTIMER;
      DLEN     : t_SDIO_DLEN;
      DCTRL    : t_SDIO_DCTRL;
      DCOUNT   : t_SDIO_DCOUNT;
      STATUS   : t_SDIO_STA;
      ICR      : t_SDIO_ICR;
      MASK     : t_SDIO_MASK;
      FIFOCNT  : t_SDIO_FIFOCNT;
      FIFO     : t_SDIO_FIFO;
   end record;

   for t_SDIO_periph use record
      POWER    at 16#00# range 0 .. 31;
      CLKCR    at 16#04# range 0 .. 31;
      ARG      at 16#08# range 0 .. 31;
      CMD      at 16#0C# range 0 .. 31;
      RESPCMD  at 16#10# range 0 .. 31;
      RESP1    at 16#14# range 0 .. 31;
      RESP2    at 16#18# range 0 .. 31;
      RESP3    at 16#1C# range 0 .. 31;
      RESP4    at 16#20# range 0 .. 31;
      DTIMER   at 16#24# range 0 .. 31;
      DLEN     at 16#28# range 0 .. 31;
      DCTRL    at 16#2C# range 0 .. 31;
      DCOUNT   at 16#30# range 0 .. 31;
      STATUS   at 16#34# range 0 .. 31;
      ICR      at 16#38# range 0 .. 31;
      MASK     at 16#3C# range 0 .. 31;
      FIFOCNT  at 16#48# range 0 .. 31;
      FIFO     at 16#80# range 0 .. 32;
   end record;

   ---------------
   -- Utilities --
   ---------------
   
   -- Set up GPIO pins, SDIO clock and also set up interrupt handler
   procedure initialize;

   -- Enable DMA
   procedure set_dma_transfer
     (dma_controller : in out dma.t_dma_controller;
      stream         : in dma.t_dma_stream_index;
      direction      : in dma.t_transfer_dir;
      memory         : in byte_array);

end stm32f4.sdio;
