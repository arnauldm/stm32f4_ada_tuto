with ada.unchecked_conversion;
with serial;

package body stm32f4.sdio.interrupts is

   protected body handler is

      procedure has_been_interrupted (ret : out boolean)
      is
      begin
         ret   := interrupted;
         interrupted := false;
      end has_been_interrupted;

      procedure interrupt_handler is 
      begin

         declare
            function to_mask is new ada.unchecked_conversion
              (word, t_SDIO_MASK);
         begin
            periphs.SDIO_CARD.MASK := to_mask (0);
         end;

         status      := sdio_card.STATUS;
         serial.put ("<SDIO>");
         interrupted := true;

      end interrupt_handler;

   end handler;

end stm32f4.sdio.interrupts;
