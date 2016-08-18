--with serial;

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


      function get_flags return t_interrupt_flags
      is
      begin
         return flags;
      end get_flags;


      --
      -- Interrupt handler
      --

      procedure interrupt_handler is 
      begin
         -- Clear interrupts flags
         if stream_interrupt_is_set
               (controller.all, stream, FIFO_ERROR)
         then
            clear_stream_interrupt (controller.all, stream, FIFO_ERROR);
            flags.FIFO_ERROR := true;
         else
            flags.FIFO_ERROR := false;
         end if;

         if stream_interrupt_is_set
              (controller.all, stream, DIRECT_MODE_ERROR)
         then
            clear_stream_interrupt
              (controller.all, stream, DIRECT_MODE_ERROR);
            flags.DIRECT_MODE_ERROR := true;
         else
            flags.DIRECT_MODE_ERROR := false;
         end if;

         if stream_interrupt_is_set
              (controller.all, stream, TRANSFER_ERROR)
         then
            clear_stream_interrupt
              (controller.all, stream, TRANSFER_ERROR);
            flags.TRANSFER_ERROR := true;
         else
            flags.TRANSFER_ERROR := false;
         end if;

         if stream_interrupt_is_set
              (controller.all, stream, HALF_TRANSFER_COMPLETE) 
         then
            clear_stream_interrupt
              (controller.all, stream, HALF_TRANSFER_COMPLETE);
            flags.HALF_TRANSFER_COMPLETE := true;
         else
            flags.HALF_TRANSFER_COMPLETE := false;
         end if;

         if stream_interrupt_is_set
              (controller.all, stream, TRANSFER_COMPLETE) 
         then
            clear_stream_interrupt
              (controller.all, stream, TRANSFER_COMPLETE);
            flags.TRANSFER_COMPLETE := true;
         else
            flags.TRANSFER_COMPLETE := false;
         end if;

         interrupted := true;

      end interrupt_handler;

   end handler;


end stm32f4.dma.interrupts;
