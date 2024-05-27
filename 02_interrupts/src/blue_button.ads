
package blue_button is

   procedure initialize;
   function has_been_pressed return boolean;
   procedure has_been_pressed (ret : out boolean);

private

   user_button    : constant  := 0; -- GPIOA, pin 0
   pressed        : boolean   := false;

end blue_button;
