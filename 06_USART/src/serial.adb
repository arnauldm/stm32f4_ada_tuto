
package body serial is


   procedure initialize_gpio
     (tx_pin   : gpio_point;
      rx_pin   : gpio_point)
   is
      config : stm32.gpio.gpio_port_configuration;
   begin
      stm32.device.enable_clock (rx_pin & tx_pin);

      config.mode         := stm32.gpio.mode_af;
      config.speed        := stm32.gpio.speed_50mhz;
      config.output_type  := stm32.gpio.push_pull;
      config.resistors    := stm32.gpio.pull_up;

      stm32.gpio.configure_io (rx_pin & tx_pin, config);

      stm32.gpio.configure_alternate_function
        (rx_pin & tx_pin, af => stm32.gpio.GPIO_AF_USART1);
   end initialize_gpio;


   procedure configure
     (device    : access stm32.usarts.usart;
      baud_rate : stm32.usarts.baud_rates;
      mode      : stm32.usarts.UART_Modes   := stm32.usarts.TX_RX_MODE;
      parity    : stm32.usarts.parities     := stm32.usarts.NO_PARITY;
      data_bits : stm32.usarts.word_lengths := stm32.usarts.WORD_LENGTH_8;
      end_bits  : stm32.usarts.stop_bits    := stm32.usarts.STOPBITS_1;
      control   : stm32.usarts.flow_control := stm32.usarts.NO_FLOW_CONTROL)
   is
   begin
      stm32.device.enable_clock (device.all);
      stm32.usarts.disable (device.all);

      stm32.usarts.set_baud_rate (device.all, baud_rate);
      stm32.usarts.set_mode      (device.all, mode);
      stm32.usarts.set_parity    (device.all, parity);
      stm32.usarts.set_word_length  (device.all, data_bits);
      stm32.usarts.set_stop_bits    (device.all, end_bits);
      stm32.usarts.set_flow_control (device.all, control);

      stm32.usarts.enable (device.all);
   end configure;


   procedure await_send_ready (device : stm32.usarts.usart) is
   begin
      loop
         exit when stm32.usarts.tx_ready (device);
      end loop;
   end await_send_ready;


   procedure putc
     (device   : in out stm32.usarts.usart;
      c        : character)
   is
   begin
      await_send_ready (device);
      stm32.usarts.transmit (device, character'pos (c));
   end putc;


   procedure put
     (device   : in out stm32.usarts.usart;
      s        : string)
   is
   begin
      for i in s'range
      loop
         putc (device, s(i));
      end loop;
   end put;

end serial;
