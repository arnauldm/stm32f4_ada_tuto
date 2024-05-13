with stm32f4;
with stm32f4.periphs;

package body stm32f4.nvic is


   procedure set_priority (irq : interrupt; priority : uint4) is
   begin
      periphs.NVIC.IPR(irq).priority := priority;
   end set_priority;


   procedure enable_irq (irq : interrupt) is
   begin
      if irq in periphs.NVIC.ISER0.irq'range then
         periphs.NVIC.ISER0.irq (irq) := IRQ_ENABLED;
      elsif irq in periphs.NVIC.ISER1.irq'range then
         periphs.NVIC.ISER1.irq (irq) := IRQ_ENABLED;
      elsif irq in periphs.NVIC.ISER2.irq'range then
         periphs.NVIC.ISER2.irq (irq) := IRQ_ENABLED;
      else
         raise program_error;
      end if;
   end enable_irq;


end stm32f4.nvic;
