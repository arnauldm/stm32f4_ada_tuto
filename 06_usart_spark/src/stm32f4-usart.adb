with interfaces.stm32; use interfaces.stm32;

package body stm32f4.usart
   with spark_mode => on
is

   procedure transmit
     (usart : in out t_USART_peripheral;
      data  : in     uint9)
   is
      exit_cond : bit;
   begin
      loop
         exit_cond := usart.SR.TXE;
         exit when exit_cond = 1;
      end loop;
      usart.DR := t_USART_DR (data);
   end transmit;


   procedure receive
     (usart : in out t_USART_peripheral;
      data  : out    uint9)
   is
      pragma unmodified (usart);
      exit_cond : bit;
   begin
      loop
         exit_cond := usart.SR.RXNE;
         exit when exit_cond = 1;
      end loop;
      data := uint9 (usart.DR);
   end receive;


   procedure configure
     (usartx   : in out t_USART_peripheral;
      clock    : in     unsigned_32;
      baudrate : in     unsigned_32;
      data     : in     t_data_len;
      parity   : in     t_parity_select;
      stop     : in     t_stop_bits;
      success  : out    boolean)
   is
      mantissa : unsigned_32;
      fraction : unsigned_32;
   begin
      usartx.CR1.UE     := 1; -- USART enable
      usartx.CR1.TE     := 1; -- Transmitter enable
      usartx.CR1.RE     := 1; -- Receiver enable

      -- Configuring the baud rate
      mantissa    := clock / (16 * baudrate);
      fraction    := ((clock * 25) / (4 * baudrate)) - mantissa * 100;
      fraction    := (fraction * 16) / 100;

      if fraction > 16#F# or mantissa > 16#FFF# then
         success := false;
         return;
      end if;

      usartx.BRR.DIV_Mantissa   := uint12 (mantissa);
      usartx.BRR.DIV_Fraction   := uint4  (fraction);

      -- Data length, stops bits
      usartx.CR1.M      := data;
      usartx.CR2.STOP   := stop;

      -- Parity
      case parity is
         when PARITY_NONE =>
            usartx.CR1.PCE := 0; -- Parity control disable
         when PARITY_EVEN =>
            usartx.CR1.PCE := 1; -- Parity control enable
            usartx.CR1.PS  := EVEN;
         when PARITY_ODD  =>
            usartx.CR1.PCE := 1; -- Parity control enable
            usartx.CR1.PS  := ODD;
      end case;

      -- No flow control
      usartx.CR3.RTSE := 0;
      usartx.CR3.CTSE := 0;

      success := true;
   end configure;


end stm32f4.usart;
