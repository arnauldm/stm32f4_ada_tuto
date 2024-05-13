with ada.interrupts.names;

package stm32f4.sdio.interrupts is

   protected handler
   is
      procedure has_been_interrupted (ret : out boolean);
      function get_saved_status return t_SDIO_STA;
   private
      interrupted    : boolean := false;
      saved_status   : t_SDIO_STA;
      procedure interrupt_handler;
      pragma attach_handler
        (interrupt_handler, Ada.Interrupts.Names.SDIO_Interrupt);

   end handler;

end stm32f4.sdio.interrupts;
