
with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with STM32.Device;
with STM32.Board;
with STM32.Button;
with STM32.GPIO;
with Ada.Real_Time; use Ada.Real_Time;

procedure Blink is
   Period         : constant Time_Span := Milliseconds (150);
   Next_Release   : Time := Clock;

   type Index is mod 4;
   Blinking_Leds  : array (Index) of STM32.Board.User_LED := (STM32.Board.Blue, STM32.Board.Green, STM32.Board.Orange, STM32.Board.Red);

   Current_Led    : Index   := Blinking_Leds'first;
   CounterWise    : Boolean := True;

   procedure Initialize_LEDs is
      Configuration : STM32.GPIO.GPIO_Port_Configuration;
   begin
      STM32.Device.Enable_Clock (STM32.Board.All_LEDs);
      Configuration.Mode        := STM32.GPIO.Mode_Out;
      Configuration.Output_Type := STM32.GPIO.Push_Pull;
      Configuration.Speed       := STM32.GPIO.Speed_100MHz;
      Configuration.Resistors   := STM32.GPIO.Floating;
      STM32.GPIO.Configure_IO (STM32.Board.All_LEDs, Configuration);
   end Initialize_LEDs;

begin

   Initialize_LEDs;
   STM32.Button.Initialize;

   STM32.Board.All_LEDs_Off;
   STM32.Board.Turn_On (Blinking_Leds(Current_Led));

   loop
      if STM32.Button.Has_Been_Pressed then
         CounterWise := not CounterWise;
      end if;

      STM32.Board.Turn_Off (Blinking_leds(Current_Led));
      Current_Led := (if CounterWise then Current_Led + 1 else Current_Led - 1);
      STM32.Board.Turn_On (Blinking_leds(Current_Led));

      Next_Release := Next_Release + Period;
      delay until Next_Release;
   end loop;
end Blink;
