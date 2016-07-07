
with stm32; use stm32;
with stm32.gpio;
with stm32.device;
with stm32.board;
with ada.real_time; use ada.real_time;

package body leds is

   procedure init is
      config : stm32.gpio.gpio_port_configuration;
   begin
      stm32.device.enable_clock (stm32.board.all_leds);
      config.mode        := stm32.gpio.mode_out;
      config.output_type := stm32.gpio.push_pull;
      config.speed       := stm32.gpio.speed_100mhz;
      config.resistors   := stm32.gpio.floating;
      stm32.gpio.configure_io (stm32.board.all_leds, config);
   end init;

   task body blinking_leds is
      leds : array (1..4) of board.user_led :=
        (board.blue, board.green, board.orange, board.red);
      current : integer := 1;
   begin
      init;
      board.all_leds_off;
      board.turn_on (leds(current));
      loop
         board.turn_off (leds(current));
         current := (if current = leds'last then leds'first else current + 1);
         delay until clock + milliseconds (200);
         board.turn_on (leds(current));
         delay until clock + milliseconds (200);
      end loop;
   end blinking_leds;

end leds;
