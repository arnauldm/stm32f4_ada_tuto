
package body stm32f4.dma.interrupts is

   -----------------------------
   -- DMA interrupts handling --
   -----------------------------

   protected body handler is

      --
      -- Return true if a DMA interrupt occured
      --

      procedure has_been_interrupted (ret : out boolean)
      is
      begin
         ret   := interrupted;
         interrupted := false;
      end has_been_interrupted;


      function get_saved_ISR return t_dma_stream_ISR
      is
      begin
         return saved_ISR;
      end get_saved_ISR;


      --
      -- Interrupt handler
      --

      procedure interrupt_handler is 
         -- Interrupt Status Register
         ISR : constant t_dma_stream_ISR :=
            get_stream_ISR (controller.all, stream);
      begin
         interrupted := true;
         saved_ISR   := ISR;
         clear_interrupt_flags (controller.all, stream);
      end interrupt_handler;

   end handler;


end stm32f4.dma.interrupts;
