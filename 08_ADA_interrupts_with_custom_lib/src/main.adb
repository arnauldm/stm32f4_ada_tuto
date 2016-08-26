with ada.real_time; use ada.real_time;
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;

with serial;
with leds; pragma unreferenced (leds); -- task blinking_leds

with stm32f4.sdio.sd_card;
-- with tests.dma;

procedure main is
   counter  : integer         := 0;
   period   : constant ada.real_time.time_span := 
      ada.real_time.milliseconds (1000);
begin

   -- Initialize USART 
   serial.initialize;

   -- -- Testing the DMA
   -- tests.dma.transfer_memory_to_memory;

   stm32f4.sdio.sd_card.initialize;

   -- Endless loop
   loop
      serial.put ('.');
      counter := counter + 1;
      delay until ada.real_time.clock + period;
   end loop;

end main;
