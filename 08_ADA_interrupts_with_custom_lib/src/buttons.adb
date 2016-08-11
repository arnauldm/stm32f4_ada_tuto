with Ada.Interrupts.Names;

with stm32f4.gpio; 
with stm32f4.periphs;
with stm32f4.syscfg;
with stm32f4.exti;
with stm32f4.nvic;

package body buttons is

   button_pin : stm32f4.gpio.GPIO_pin_index 
      renames stm32f4.periphs.blue_button;

   procedure initialize is
   begin

      ----------------------------
      -- Enable the blue button --
      ----------------------------
   
      -- GPIOA Periph clock enable
      stm32f4.periphs.RCC.AHB1ENR.GPIOAEN := 1;
   
      -- Set button's pin to input mode
      stm32f4.periphs.GPIOA.MODER.pin (button_pin) := stm32f4.gpio.MODE_IN;
   
      -- Default (idle) state is at 0V. Set GPIO pin to pull-down
      stm32f4.periphs.GPIOA.PUPDR.pin (button_pin) := stm32f4.gpio.PULL_DOWN;
      
      -- Set GPIO Speed to high speed
      stm32f4.periphs.GPIOA.OSPEEDR.pin (button_pin) :=
         stm32f4.gpio.SPEED_HIGH;

	   -----------------------
	   -- Enable interrupts --
	   -----------------------
	
	   -- PAx, PBx, PCx (...) are multiplexed on EXTIx (ie. PA0
	   -- interrupts are managed by the EXTI0 line). Note that they are up
	   -- to 23 external interrupts lines.
	   -- The user button, which is on PA0, is managed by EXTI0. 
	   stm32f4.periphs.SYSCFG.EXTICR1.EXTI0 := stm32f4.syscfg.GPIOA;
	
	   -- Set interrupt/event masks
      stm32f4.periphs.EXTI.IMR.line (button_pin) := stm32f4.exti.NOT_MASKED;
      stm32f4.periphs.EXTI.EMR.line (button_pin) := stm32f4.exti.MASKED;
	
	   -- Trigger the selected external interrupt on rising edge
      stm32f4.periphs.EXTI.RTSR.line (button_pin) :=
         stm32f4.exti.TRIGGER_ENABLED;
      stm32f4.periphs.EXTI.FTSR.line (button_pin) :=
         stm32f4.exti.TRIGGER_DISABLED;
	
      -- Set the IRQ priority level (in the range 0-15). The lower the value,
	   -- the greater the priority is. The Reset, Hard fault, and NMI
	   -- exceptions, with fixed negative priority values, always have higher
	   -- priority than any other exception. When the processor is executing
	   -- an exception handler, the exception handler is preempted if a higher
	   -- priority exception occurs. 
	   stm32f4.periphs.NVIC.IPR(stm32f4.nvic.EXTI_line_0).priority := 0;
	
	   -- Enable the Selected IRQ Channels
	   stm32f4.periphs.NVIC.ISER0.irq(stm32f4.nvic.EXTI_line_0)
	      := stm32f4.nvic.IRQ_ENABLED;

   end initialize;


   -----------------------
   -- Interrupt Handler --
   -----------------------

   protected button is
      procedure has_been_pressed (ret : out boolean);
   private
      pressed        : boolean := false;
      procedure Interrupt_Handler;
         pragma Attach_Handler
           (Interrupt_Handler,
            Ada.Interrupts.Names.EXTI0_Interrupt);
   end button;


   protected body button is

      procedure has_been_pressed (ret : out boolean) is
      begin
         ret      := pressed;
         pressed  := false;
      end has_been_pressed;

      procedure Interrupt_Handler is
      begin
         stm32f4.periphs.EXTI.PR.line (button_pin) :=
            stm32f4.exti.CLEAR_REQUEST;
         pressed  := true;
      end Interrupt_Handler;

   end button;


   function has_been_pressed return boolean is
      ret : boolean;
   begin
      button.has_been_pressed (ret);
      return ret;
   end has_been_pressed;


end buttons;
