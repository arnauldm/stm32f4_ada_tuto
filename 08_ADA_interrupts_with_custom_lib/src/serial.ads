
package serial is
   enabled : boolean := false;

   procedure initialize;
   procedure put (c : character);
   procedure put (s : string);
   procedure new_line;

end serial;
