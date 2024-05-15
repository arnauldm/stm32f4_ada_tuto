with system; use system;
with System.STM32; -- System package
with stm32f4.layout;
with interfaces.stm32; use interfaces.stm32;

package body stm32f4.usart
   with spark_mode => off
is

   procedure set_baud
     (USARTx   : stm32f4.usart.t_USART_periph_access;
      baudrate : interfaces.stm32.uint32)
   is
      APB_clock   : interfaces.stm32.uint32;
      mantissa    : interfaces.stm32.uint32;
      fraction    : interfaces.stm32.uint32;
   begin
      -- Configuring the baud rate is a tricky part. See RM0090 p. 982-983
      -- for further informations
      if USARTx.all'address = layout.USART1_BASE or
         USARTx.all'address = layout.USART6_BASE
      then
         APB_clock   := System.STM32.System_Clocks.PCLK2;
      else
         APB_clock   := System.STM32.System_Clocks.PCLK1;
      end if;

      mantissa    := APB_clock / (16 * baudrate);
      fraction    := ((APB_clock * 25) / (4 * baudrate)) - mantissa * 100;
      fraction    := (fraction * 16) / 100;

      USARTx.BRR.DIV_Mantissa   := uint12 (mantissa);
      USARTx.BRR.DIV_Fraction   := uint4  (fraction);
   end set_baud;


   procedure configure
     (USARTx   : stm32f4.usart.t_USART_periph_access;
      baudrate : interfaces.stm32.uint32;
      data     : t_data_len;
      parity   : t_parity_select;
      stop     : t_stop_bits)
   is
   begin
      USARTx.CR1.UE     := 1;  -- USART enable
      USARTx.CR1.TE     := 1; -- Transmitter enable
      USARTx.CR1.RE     := 1; -- Transmitter enable

      usart.set_baud (USARTx, baudrate);

      -- Data length, stops bits
      USARTx.CR1.M      := data;
      USARTx.CR2.STOP   := stop;

      -- Parity
      case parity is
         when usart.PARITY_NONE =>
            USARTx.CR1.PCE := 0; -- Parity control disable
         when usart.PARITY_EVEN =>
            USARTx.CR1.PCE := 1; -- Parity control enable
            USARTx.CR1.PS  := EVEN;
         when usart.PARITY_ODD  =>
            USARTx.CR1.PCE := 1; -- Parity control enable
            USARTx.CR1.PS  := ODD;
      end case;

      -- No flow control
      USARTx.CR3.RTSE := 0;
      USARTx.CR3.CTSE := 0;
   end configure;

end stm32f4.usart;
