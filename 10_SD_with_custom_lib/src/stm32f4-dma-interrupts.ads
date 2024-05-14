with ada.interrupts;

package stm32f4.dma.interrupts is

   protected type handler
     (controller  : t_dma_controller_access;
      stream      : t_dma_stream_index;
      IRQ         : ada.interrupts.interrupt_id)
   is
      procedure has_been_interrupted (ret : out boolean);
      function get_saved_ISR return t_dma_stream_ISR;
   private
      interrupted : boolean := false;
      saved_ISR   : t_dma_stream_ISR := (others => false);
      procedure interrupt_handler;
         pragma attach_handler (interrupt_handler, IRQ);
   end handler;


end stm32f4.dma.interrupts;
