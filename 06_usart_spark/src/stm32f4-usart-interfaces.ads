
package stm32f4.usart.interfaces
   with spark_mode => on
is
   ----------------
   -- Interfaces --
   ----------------

   type t_usart_id is
     (ID_USART1, ID_USART3, ID_USART6);

   procedure configure
     (usart_id : in  t_usart_id;
      baudrate : in  unsigned_32;
      data     : in  t_data_len;
      parity   : in  t_parity_select;
      stop     : in  t_stop_bits;
      success  : out boolean)
   with
      pre => (baudrate >= 2400 and baudrate <= 115_200);

   procedure transmit
     (usart_id : in  t_usart_id;
      data     : in  uint9);

end stm32f4.usart.interfaces;
