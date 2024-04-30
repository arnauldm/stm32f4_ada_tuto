
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32.board;
with stm32.user_button;
with ada.real_time; use ada.real_time;

procedure blink is

   period         : constant time_span := milliseconds (150);
   next_release   : time := clock;

   type index is mod 4;

   blinking_leds  : array (index) of stm32.board.user_led :=
     (stm32.board.blue_led,
      stm32.board.green_led,
      stm32.board.orange_led,
      stm32.board.red_led);

   current_led    : index   := blinking_leds'first;
   counterwise    : boolean := true;

begin

   stm32.board.initialize_leds;
   stm32.user_button.initialize;

   stm32.board.all_leds_off;
   stm32.board.turn_on (blinking_leds(current_led));

   loop
      if stm32.user_button.has_been_pressed then
         counterwise := not counterwise;
      end if;

      stm32.board.turn_off (blinking_leds(current_led));

      if counterwise then
         current_led := current_led + 1;
      else
         current_led := current_led - 1;
      end if;

      stm32.board.turn_on (blinking_leds(current_led));

      next_release := next_release + period;
      delay until next_release;
   end loop;
end Blink;
