with system;
with ada.real_time;  use ada.real_time;
with interfaces; use interfaces;

with stm32.device;
with stm32.board;
with stm32.gpio;
with stm32.usarts; 
with lis3dsh;       use lis3dsh;

with last_chance_handler;  pragma unreferenced (last_chance_handler);
with leds; pragma unreferenced (leds); -- task blinking_leds
with serial;

procedure main is
   pragma priority (system.priority'first);

begin

   serial.initialize_gpio
     (tx_pin => stm32.device.PB6,
      rx_pin => stm32.device.PB7,
      af     => stm32.gpio.GPIO_AF_USART1);

   serial.configure
     (device      => stm32.device.usart_1'access,
      baud_rate   => 9600,
      mode        => stm32.usarts.tx_mode,
      parity      => stm32.usarts.no_parity,
      data_bits   => stm32.usarts.word_length_8,
      end_bits    => stm32.usarts.stopbits_1,
      control     => stm32.usarts.no_flow_control);

   serial.put (stm32.device.usart_1, "hello, world!" & ascii.cr);

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
            ", z: " & lis3dsh.axis_acceleration'image (values.z) &
            ascii.cr);
      end;
      delay until clock + milliseconds (250);
   end loop;

end main;
