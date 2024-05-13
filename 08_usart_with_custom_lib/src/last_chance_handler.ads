
--  This version is for use with the ravenscar-sfp runtime.

with System;

package Last_Chance_Handler
   with spark_mode => off
is

   procedure Last_Chance_Handler (File : System.Address; Line : Integer);
   pragma Export (C, Last_Chance_Handler, "__gnat_last_chance_handler");
   pragma No_Return (Last_Chance_Handler);

end Last_Chance_Handler;
