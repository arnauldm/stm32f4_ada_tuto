
package serial is
   enabled : boolean := false;

   procedure initialize;
   procedure put (c : character);
   procedure put (s : string);
   procedure new_line;
   procedure put_line (s : string);

end serial;
