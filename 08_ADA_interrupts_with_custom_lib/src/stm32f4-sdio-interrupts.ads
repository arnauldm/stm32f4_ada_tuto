with ada.interrupts.names;

package stm32f4.sdio.interrupts is

   protected handler
   is
      procedure has_been_interrupted (ret : out boolean);

   private

      interrupted : boolean := false;
      status      : t_SDIO_STA;

      procedure interrupt_handler;
      pragma attach_handler
        (interrupt_handler, Ada.Interrupts.Names.SDIO_Interrupt);

   end handler;

end stm32f4.sdio.interrupts;
