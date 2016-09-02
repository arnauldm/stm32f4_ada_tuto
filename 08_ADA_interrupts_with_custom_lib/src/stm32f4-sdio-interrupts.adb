with ada.unchecked_conversion;
with stm32f4;
with stm32f4.periphs;
with serial;

package body stm32f4.sdio.interrupts is

   ------------------------------
   -- SDIO interrupts handling --
   ------------------------------

   protected body handler is

      --
      -- Return true if a SDIO interrupt occured
      --

      procedure has_been_interrupted (ret : out boolean)
      is
      begin
         ret   := interrupted;
         interrupted := false;
      end has_been_interrupted;


      function get_saved_status return t_SDIO_STA
      is
      begin
         return saved_status;
      end get_saved_status;


      --
      -- Interrupt handler
      --

      procedure interrupt_handler is 
      begin
         interrupted    := true;
         saved_status   := periphs.SDIO_CARD.STATUS;
         periphs.SDIO_CARD.ICR := (others => CLEAR);

         -- DEBUG, TO REMOVE
         declare
            function to_word is new ada.unchecked_conversion
              (sdio.t_SDIO_STA, word);
         begin
            serial.put_line
              ("SDIO interrupt:" & word'image (to_word (saved_status)));
         end;
      end interrupt_handler;

   end handler;

end stm32f4.sdio.interrupts;
