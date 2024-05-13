with system;
with last_chance_handler;  pragma unreferenced (last_chance_handler);
with ada.real_time;  use ada.real_time;

with stm32.device;
with stm32.usarts;
with stm32.board;
with lis3dsh;        use lis3dsh;
with hal;            use hal;

with serial;

-- Task blinking the RED led
--with blink; pragma unreferenced (blink);

procedure main is
   pragma priority (system.priority'first);
begin

   serial.initialize_gpio
     (tx_pin => stm32.device.PB6,
      rx_pin => stm32.device.PB7,
      af     => stm32.device.gpio_af_usart1_7);

   serial.configure
     (device      => stm32.device.USART_1'access,
      baud_rate   => 9600,
      mode        => stm32.usarts.TX_MODE,
      parity      => stm32.usarts.NO_PARITY,
      data_bits   => stm32.usarts.WORD_LENGTH_8,
      end_bits    => stm32.usarts.STOPBITS_1,
      control     => stm32.usarts.NO_FLOW_CONTROL);

   stm32.board.initialize_leds;

   serial.put (stm32.device.usart_1, "Hello, world!" & ascii.cr);

   stm32.board.initialize_accelerometer;

   stm32.board.accelerometer.configure
     (output_datarate => data_rate_100hz,
      axes_enable     => xyz_enabled,
      spi_wire        => serial_interface_4wire,
      self_test       => self_test_normal,
      full_scale      => fullscale_2g,
      filter_bw       => filter_800hz);

   if stm32.board.accelerometer.device_id /= lis3dsh.i_am_lis3dsh then
      serial.put (stm32.device.usart_1, "error>>> no lis3dsh chip!" & ascii.cr);
   end if;

   loop
      declare
         values : lis3dsh.axes_accelerations;
      begin
         stm32.board.accelerometer.get_accelerations (values);
         serial.put (stm32.device.usart_1,
            "x: " & lis3dsh.axis_acceleration'image (values.x) &
            ", y: " & lis3dsh.axis_acceleration'image (values.y) &
            "          " & ascii.lf & ascii.cr);
      end;
      delay until clock + milliseconds (250);
   end loop;

end main;
