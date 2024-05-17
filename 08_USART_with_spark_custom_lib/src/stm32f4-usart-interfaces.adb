with system.stm32;

package body stm32f4.usart.interfaces
   with spark_mode => on
is

   procedure configure
     (usart_id : in  t_usart_id;
      baudrate : in  unsigned_32;
      data     : in  t_data_len;
      parity   : in  t_parity_select;
      stop     : in  t_stop_bits;
      success  : out boolean)
   is
   begin
      case usart_id is
         when ID_USART1 =>
            stm32f4.usart.configure
              (USART1,
               unsigned_32 (system.stm32.system_clocks.PCLK2), -- APB2
               baudrate, data, parity, stop, success);

         when ID_USART2 =>
            stm32f4.usart.configure
              (USART2,
               unsigned_32 (system.stm32.system_clocks.PCLK1), -- APB1
               baudrate, data, parity, stop, success);

         when ID_USART3 =>
            stm32f4.usart.configure
              (USART3,
               unsigned_32 (system.stm32.system_clocks.PCLK1), -- APB1
               baudrate, data, parity, stop, success);

         when ID_UART4  =>
            stm32f4.usart.configure
              (UART4,
               unsigned_32 (system.stm32.system_clocks.PCLK1), -- APB1
               baudrate, data, parity, stop, success);

         when ID_UART5  =>
            stm32f4.usart.configure
              (UART5,
               unsigned_32 (system.stm32.system_clocks.PCLK1), -- APB1
               baudrate, data, parity, stop, success);

         when ID_USART6 =>
            stm32f4.usart.configure
              (USART6,
               unsigned_32 (system.stm32.system_clocks.PCLK2), -- APB2
               baudrate, data, parity, stop, success);
      end case;

   end configure;


   procedure transmit
     (usart_id : in  t_usart_id;
      data     : in  uint9)
   is
   begin
      case usart_id is
         when ID_USART1 => stm32f4.usart.transmit (USART1, data);
         when ID_USART2 => stm32f4.usart.transmit (USART2, data);
         when ID_USART3 => stm32f4.usart.transmit (USART3, data);
         when ID_UART4  => stm32f4.usart.transmit (UART4, data);
         when ID_UART5  => stm32f4.usart.transmit (UART5, data);
         when ID_USART6 => stm32f4.usart.transmit (USART6, data);
      end case;
   end transmit;

end stm32f4.usart.interfaces;
