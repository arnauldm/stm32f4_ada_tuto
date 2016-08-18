with ada.interrupts;

package stm32f4.dma.interrupts is

   --type t_interrupt_flags is array (DMA_interrupts) of boolean;
   type t_interrupt_flags is record
      FIFO_ERROR        : boolean;
      DIRECT_MODE_ERROR : boolean; 
      TRANSFER_ERROR    : boolean;
      HALF_TRANSFER_COMPLETE  : boolean; 
      TRANSFER_COMPLETE : boolean;
   end record;

   protected type handler
     (controller  : t_DMA_controller_access;
      stream      : t_DMA_stream_index;
      IRQ         : ada.interrupts.interrupt_id)
   is
      procedure has_been_interrupted (ret : out boolean);
      function get_flags return t_interrupt_flags;
   private
      interrupted : boolean := false;
      flags       : t_interrupt_flags := (others => false);
      procedure interrupt_handler;
         pragma attach_handler (interrupt_handler, IRQ);
   end handler;


end stm32f4.dma.interrupts;
