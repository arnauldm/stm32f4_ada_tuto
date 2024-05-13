with system;
with ada.real_time; use ada.real_time;
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;
with stm32f4.periphs;

with leds;
with serial;
with stm32f4.sdio.sd_card;

with tests.dma;   pragma unreferenced (tests.dma);
with tests.sdio;  pragma unreferenced (tests.sdio);

procedure main is
   pragma priority (system.priority'first);
   ok       : boolean;
   period   : constant ada.real_time.time_span :=
      ada.real_time.milliseconds (250);
begin

   leds.initialize;
   serial.initialize;

   serial.put ("-- Hello, world!");
   serial.new_line;

   stm32f4.sdio.sd_card.initialize (ok);

   if not ok then
      loop
         gpio.toggle (periphs.LED_RED);
         delay until ada.real_time.clock + period;
      end loop;
   else
      tests.sdio.write_with_dma (10, 512*20);
      tests.sdio.read_with_dma (10, 512*20);
      loop
         gpio.toggle (periphs.LED_GREEN);
         delay until ada.real_time.clock + 2*period;
      end loop;
   end if;

end main;
