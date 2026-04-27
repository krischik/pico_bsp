--------------------------------------------------------------- {{{1 ----------
--: Copyright © 2026 … 2026 Martin Krischik «krischik@users.sourceforge.net»
------------------------------------------------------------------------------
--: This library is free software; you can redistribute it and/or modify it
--: under the terms of the GNU Library General Public License as published by
--: the Free Software Foundation; either version 2 of the License, or (at your
--: option) any later version.
--:
--: This library is distributed in the hope that it will be useful, but
--: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
--: or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public
--: License for more details.
--:
--: You should have received a copy of the GNU Library General Public License
--: along with this library; if not, write to the Free Software Foundation,
--: Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--------------------------------------------------------------- }}}1 ----------
pragma License (Modified_Gpl);
pragma Ada_2022;
pragma Extensions_Allowed (On);

package body Pico.Analog.RGB_LED is

   procedure Set_Color
      (LED         : in Color_Array;
       Red_Value   : in Analog_Level;
       Green_Value : in Analog_Level;
       Blue_Value  : in Analog_Level)
   is
   begin
      LED (Red).Write_Analog (Analog_Level'Last - Red_Value);
      LED (Green).Write_Analog (Analog_Level'Last - Green_Value);
      LED (Blue).Write_Analog (Analog_Level'Last - Blue_Value);
      return;
   end Set_Color;

   procedure Set_Color (LED : in Color_Array; Color : in RGB_Color) is
   begin
      LED (Red).Write_Analog (Analog_Level'Last - Analog_Level ((Color / 2**16) and 16#FF#));
      LED (Green).Write_Analog (Analog_Level'Last - Analog_Level ((Color / 2**8) and 16#FF#));
      LED (Blue).Write_Analog (Analog_Level'Last - Analog_Level (Color and 16#FF#));
      return;
   end Set_Color;

end Pico.Analog.RGB_LED;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
