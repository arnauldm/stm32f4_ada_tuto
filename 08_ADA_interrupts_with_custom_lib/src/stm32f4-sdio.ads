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
      CLKEN    : bit;         -- Clock enable bit
      PWRSAV   : bit;         -- Power saving configuration bit
      BYPASS   : bit;         -- Clock divider bypass enable bit
      WIDBUS   : t_widbus;    -- Wide bus mode enable bit
      NEGEDGE  : t_negedge;   -- SDIO_CK dephasing selection bit
      HWFC_EN  : bit;         -- HW Flow Control enable
      reserved_15    : bit;
      reserved_16_31 : short;
   end record
      with pack, size => 32, volatile_full_access;

   ---------------------------------------
   -- SDIO argument register (SDIO_ARG) --
   ---------------------------------------

   -- Command argument sent to a card as part of a command message.
   subtype t_SDIO_ARG is word;

   --------------------------------------
   -- SDIO command register (SDIO_CMD) --
   --------------------------------------

   type t_waitresp is
     (NO_RESPONSE, SHORT_RESPONSE, NO_RESPONSE2, LONG_RESPONSE)
      with size => 2;
   for t_waitresp use
     (NO_RESPONSE    => 2#00#,
      SHORT_RESPONSE => 2#01#,
      NO_RESPONSE2   => 2#10#, 
      LONG_RESPONSE  => 2#11#);

   type t_SDIO_CMD is record
      CMDINDEX    : uint6;       -- Command index
      WAITRESP    : t_waitresp;  -- Wait for response bits
      WAITINT     : bit;         -- CPSM(*) waits for interrupt request
      WAITPEND    : bit;         -- CPSM Waits for ends of data transfer
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
      RESPCMD  : uint6; -- Response command index
   end record
      with size => 32, volatile_full_access;

   for t_SDIO_RESPCMD use record
      RESPCMD at 0 range 0 .. 5;
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
     (TO_CARD, TO_CONTROLLER) with size => 1;
   for t_dtdir use
     (TO_CARD        => 0,
      TO_CONTROLLER  => 1);

   type t_dtmode is
     (MODE_BLOCK, MODE_STREAM) with size => 1;
   for t_dtmode use
     (MODE_BLOCK  => 0,
      MODE_STREAM => 1);

   type t_rwmode is
     (RWMOD_SDIO_D2, RWMOD_SDIO_CK) with size => 1;
   for t_rwmode use
     (RWMOD_SDIO_D2  => 0,
      RWMOD_SDIO_CK  => 1);

   type t_SDIO_DCTRL is record
      DTEN        : bit;      -- Data transfer enabled bit
      DTDIR       : t_dtdir;  -- Data transfer direction selection
      DTMODE      : t_dtmode; -- Data transfer mode selection
      DMAEN       : bit;      -- DMA enable bit
      DBLOCKSIZE  : uint4;    -- Data block size (2^n)
      RWSTART     : bit;      -- Read wait start
      RWSTOP      : bit;      -- Read wait stop
      RWMOD       : t_rwmode; -- Read wait mode
      SDIOEN      : bit;      -- SD I/O enable functions
      reserved_12_15 : uint4;
      reserved_16_31 : short;
   end record
      with pack, size => 32, volatile_full_access;

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
      CCRCFAIL : bit;   -- Command response received (CRC check failed)
      DCRCFAIL : bit;   -- Data block sent/received (CRC check failed)
      CTIMEOUT : bit;   -- Command response timeout
      DTIMEOUT : bit;   -- Data timeout
      TXUNDERR : bit;   -- Transmit FIFO underrun error
      RXOVERR  : bit;   -- Received FIFO overrun error
      CMDREND  : bit;   -- Command response received (CRC check passed)
      CMDSENT  : bit;   -- Command sent (no response required)
      DATAEND  : bit;   -- Data end (data counter, SDIDCOUNT, is zero)
      STBITERR : bit;   -- Start bit not detected on all data signals in
                        -- wide bus mode
      DBCKEND  : bit;   -- Data block sent/received (CRC check passed)
      CMDACT   : bit;   -- Command transfer in progress
      TXACT    : bit;   -- Data transmit in progress
      RXACT    : bit;   -- Data receive in progress
      TXFIFOHE : bit;   -- Transmit FIFO half empty
      RXFIFOHF : bit;   -- Receive FIFO half full
      TXFIFOF  : bit;   -- Transmit FIFO full
      RXFIFOF  : bit;   -- Receive FIFO full
      TXFIFOE  : bit;   -- Transmit FIFO empty
      RXFIFOE  : bit;   -- Receive FIFO empty
      TXDAVL   : bit;   -- Data available in transmit FIFO
      RXDAVL   : bit;   -- Data available in receive FIFO
      SDIOIT   : bit;   -- SDIO interrupt received
      CEATAEND : bit;   -- CE-ATA command completion signal received for CMD61
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   ----------------------------------------------
   -- SDIO interrupt clear register (SDIO_ICR) --
   ----------------------------------------------

   type t_clear_bit is (NOT_CLEARED, CLEARED) with size => 1;
   for t_clear_bit use
     (NOT_CLEARED => 0,
      CLEARED     => 1);

   type t_SDIO_ICR is record
      CCRCFAILC   : t_clear_bit;
      DCRCFAILC   : t_clear_bit;
      CTIMEOUTC   : t_clear_bit;
      DTIMEOUTC   : t_clear_bit;
      TXUNDERRC   : t_clear_bit;
      RXOVERRC    : t_clear_bit;
      CMDRENDC    : t_clear_bit;
      CMDSENTC    : t_clear_bit;
      DATAENDC    : t_clear_bit;
      STBITERRC   : t_clear_bit;
      DBCKENDC    : t_clear_bit;
      reserved_11_15 : uint5;
      reserved_16_21 : uint6;
      SDIOITC     : t_clear_bit;
      CEATAENDC   : t_clear_bit;
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   ------------------------------------
   -- SDIO mask register (SDIO_MASK) --
   ------------------------------------

   type t_SDIO_MASK is record
      CCRCFAILIE : bit; -- Command CRC fail interrupt enable
      DCRCFAILIE : bit; -- Data CRC fail interrupt enable
      CTIMEOUTIE : bit; -- Command timeout interrupt enable
      DTIMEOUTIE : bit; -- Data timeout interrupt enable
      TXUNDERRIE : bit; -- Tx FIFO underrun error interrupt enable
      RXOVERRIE  : bit; -- Rx FIFO overrun error interrupt enable
      CMDRENDIE  : bit; -- Command response received interrupt enable
      CMDSENTIE  : bit; -- Command sent interrupt enable
      DATAENDIE  : bit; -- Data end interrupt enable
      STBITERRIE : bit; -- Start bit error interrupt enable
      DBCKENDIE  : bit; -- Data block end interrupt enable
      CMDACTIE   : bit; -- Command acting interrupt enable
      TXACTIE    : bit; -- Data transmit acting interrupt enable
      RXACTIE    : bit; -- Data receive acting interrupt enable
      TXFIFOHEIE : bit; -- Tx FIFO half empty interrupt enable
      RXFIFOHFIE : bit; -- Rx FIFO half empty interrupt enable
      TXFIFOFIE  : bit; -- Tx FIFO full interrupt enable
      RXFIFOFIE  : bit; -- Rx FIFO full interrupt enable
      TXFIFOEIE  : bit; -- Tx FIFO empty interrupt enable
      RXFIFOEIE  : bit; -- Rx FIFO empty interrupt enable
      TXDAVLIE   : bit; -- Data available in Tx FIFO interrupt enable
      RXDAVLIE   : bit; -- Data available in Rx FIFO interrupt enable
      SDIOITIE   : bit; -- SDIO mode interrupt received interrupt enable
      CEATAENDIE : bit; -- CE-ATA command completion signal received
                        -- interrupt enable
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------------------------------------
   -- SDIO FIFO counter register (SDIO_FIFOCNT) --
   -----------------------------------------------

   type t_SDIO_FIFOCNT is record
      FIFOCOUNT      : uint24;
         -- Remaining number of words to be written to or read from the FIFO
      reserved_24_31 : byte;
   end record
      with pack, size => 32, volatile_full_access;

   -----------------------------------------
   -- SDIO data FIFO register (SDIO_FIFO) --
   -----------------------------------------

   -- Receive and transmit FIFO data
   subtype t_SDIO_FIFO_DATA is word;

   -- The FIFO data occupies 32 entries of 32-bit words, from address:
   -- SDIO base + 0x080 to SDIO base + 0xFC
   type t_SDIO_FIFO is array (1 .. 32) of t_SDIO_FIFO_DATA
      with pack, size => 32 * 32;

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
      FIFO     at 16#80# range 0 .. 32*32 - 1;
   end record;

   ---------------
   -- Utilities --
   ---------------

   procedure initialize;

end stm32f4.sdio;
