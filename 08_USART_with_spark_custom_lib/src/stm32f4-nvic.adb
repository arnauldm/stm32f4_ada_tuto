with stm32f4.periphs;

package body stm32f4.nvic
   with spark_mode => on
is


   procedure set_priority (irq : interrupt; priority : uint4) is
   begin
      periphs.NVIC.IPR(irq).priority := priority;
   end set_priority;


   procedure enable_irq (irq : interrupt) is
   begin
      case irq is
         when iser0_range =>
            -- NOTE: Cumbersome but implied by SPARK verifications
            declare
               iser : t_irq_states (iser0_range) := periphs.NVIC.ISER0.irq;
            begin
               iser (irq) := IRQ_ENABLED;
               periphs.NVIC.ISER0.irq := iser;
            end;

         when iser1_range =>
            declare
               iser : t_irq_states (iser1_range) := periphs.NVIC.ISER1.irq;
            begin
               iser (irq) := IRQ_ENABLED;
               periphs.NVIC.ISER1.irq := iser;
            end;

         when iser2_range =>
            declare
               iser : t_irq_states (iser2_range) := periphs.NVIC.ISER2.irq;
            begin
               iser (irq) := IRQ_ENABLED;
               periphs.NVIC.ISER2.irq := iser;
            end;
      end case;
   end enable_irq;


end stm32f4.nvic;
