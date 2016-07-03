with Ada.Interrupts.Names;
with Interfaces.STM32.RCC;
with Interfaces.STM32.SYSCFG;
with Interfaces.STM32.GPIO; 
with System.STM32;

with registers;

package body buttons is

   user_button    : constant := 0;

   procedure initialize is
   begin
      -- Enable GPIOA periph clock
      Interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIOAEN := 1;
   
      -- Set GPIOA pin to input mode
      Interfaces.STM32.GPIO.GPIOA_Periph.MODER.Arr (user_button)
         := System.STM32.Mode_IN;
   
      -- Push-pull mode 
      Interfaces.STM32.GPIO.GPIOA_Periph.OTYPER.OT.Arr (user_button)
         := System.STM32.Push_Pull;
   
      -- Pull-down
      Interfaces.STM32.GPIO.GPIOA_Periph.PUPDR.Arr (user_button)
         := System.STM32.Pull_Down;
   
      -- High speed
      Interfaces.STM32.GPIO.GPIOA_Periph.OSPEEDR.Arr (user_button)
         := System.STM32.Speed_100MHz;

      -- Select PA for EXTI0
      Interfaces.STM32.SYSCFG.SYSCFG_Periph.EXTICR1.EXTI.Arr (user_button)
         := 2#0000#;

      -- Unmask interrupts 
      registers.EXTI.IMR (0) := 1;

      -- Falling edge trigerring (when button is released)
      registers.EXTI.RTSR (0) := 0;
      registers.EXTI.FTSR (0) := 1;
   end initialize;


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
         registers.EXTI.PR (0)       := 1; --  Clear interrupt
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
