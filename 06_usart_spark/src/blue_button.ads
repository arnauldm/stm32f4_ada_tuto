
package blue_button
   with spark_mode => on
is
   procedure init;
   function has_been_pressed return boolean
      with Volatile_Function;
end blue_button;
