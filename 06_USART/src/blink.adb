
with stm32.board;
with ada.real_time; use ada.real_time;

package body blink is

   task body blinking_leds is
   begin
      stm32.board.initialize_leds;
      loop
         stm32.board.turn_on (stm32.board.red_led);
         delay until clock + milliseconds (500);
         stm32.board.turn_off (stm32.board.red_led);
         delay until clock + milliseconds (500);
      end loop;
   end blinking_leds;

end blink;
