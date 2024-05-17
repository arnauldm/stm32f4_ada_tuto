with ada.real_time;  use ada.real_time;

package body timer
   with spark_mode => off
is
   procedure wait (time : integer)
   is
   begin
      delay until clock + milliseconds (time);
   end wait;
end timer;
