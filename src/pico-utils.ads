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

---
--   General utility functions for the Raspberry Pi Pico.
--
--   This package contains small, reusable helper functions that I find myself
--   using again and again when working with the Pico. It is designed as a
--   universal support library and grows naturally alongside the Pi Ada Tutorial.
--
--   Current content:
--     * Map – linear interpolation (the famous Arduino map() function)
--
package Pico.Utils is

   ---
   --  Map a value from one range into another range using linear interpolation.
   --
   --  This is the well-known Arduino ``map()`` function, re-implemented cleanly in Ada. It performs a linear
   --  interpolation that scales the input value ``x`` from the source range ``[In_Min .. In_Max]`` to the target
   --  range ``[Out_Min .. Out_Max]``.
   --
   --  The function is particularly useful when working with analogue sensors, PWM outputs, servo positions, or any
   --  situation where you need to convert a reading from one scale (e.g. raw ADC value) into a different scale (e.g.
   --  percentage, PWM duty cycle, servo angle in degrees).
   --
   --  Example:
   --    --  Convert an ADC reading (0..4095) to a PWM percentage (0..100)
   --    Duty_Cycle := Map (ADC_Value, 0, 4095, 0, 100);
   --
   --: @param In_Value Value to be mapped
   --: @param In_Min   Lower bound of the input range
   --: @param In_Max   Upper bound of the input range
   --: @param Out_Min  Lower bound of the output range
   --: @param Out_Max  Upper bound of the output range
   --: @return         The mapped value in the new range
   function Map
      (In_Value : in Integer;
       In_Min   : in Integer;
       In_Max   : in Integer;
       Out_Min  : in Integer;
       Out_Max  : in Integer)
       return Integer is ((In_Value - In_Min) * (Out_Max - Out_Min) / (In_Max - In_Min) + Out_Min) with
      Inline, Pure_Function;

end Pico.Utils;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
