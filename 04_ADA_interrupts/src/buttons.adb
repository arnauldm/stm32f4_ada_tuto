with ada.interrupts.names;
with interfaces.STM32.RCC;
with interfaces.STM32.SYSCFG;
with interfaces.STM32.GPIO; 
with system.STM32;

with registers;

package body buttons is

   user_button    : constant := 0; -- GPIOA, pin 0

   procedure initialize is
   begin
      -- Enable GPIOA periph clock
      interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIOAEN := 1;
   
      -- Set GPIOA pin to input mode
      interfaces.STM32.GPIO.GPIOA_Periph.MODER.arr (user_button)
         := System.STM32.Mode_IN;
   
      -- Push-pull mode 
      interfaces.STM32.GPIO.GPIOA_Periph.OTYPER.OT.arr (user_button)
         := System.STM32.Push_Pull;
   
      -- Pull-down
      interfaces.STM32.GPIO.GPIOA_Periph.PUPDR.arr (user_button)
         := System.STM32.Pull_Down;
   
      -- High speed
      interfaces.STM32.GPIO.GPIOA_Periph.OSPEEDR.arr (user_button)
         := System.STM32.Speed_100MHz;

      -- Select PA for EXTI0
      interfaces.STM32.SYSCFG.SYSCFG_Periph.EXTICR1.EXTI.arr (user_button)
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

      procedure interrupt_handler;
      pragma attach_handler (interrupt_handler, ada.interrupts.names.EXTI0_Interrupt);
   end button;


   protected body button is

      procedure has_been_pressed (ret : out boolean) is
      begin
         ret      := pressed;
         pressed  := false;
      end has_been_pressed;

      procedure interrupt_handler is
      begin
         registers.EXTI.PR (0)   := 1; --  Clear interrupt
         pressed  := true;
      end interrupt_handler;

   end button;


   function has_been_pressed return boolean is
      ret : boolean;
   begin
      button.has_been_pressed (ret);
      return ret;
   end has_been_pressed;


end buttons;
