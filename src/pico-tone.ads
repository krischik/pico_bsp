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

with RP.PWM;
with Pico.Analog;

---
--  Simple square-wave tone generation using the RP2040 PWM hardware.
--
--  Ideal for driving buzzers, small speakers, or producing audible feedback.
--
package Pico.Tone is

   ---
   --  Output a square wave on the given PWM point at the requested frequency.
   --
   --:  @param This             The PWM point (slice + channel) to use.
   --:  @param Target_Frequency Desired frequency in Hertz.
   --:  @param Duty_Cycle       Duty cycle as a percentage (50.0 gives a perfect square wave).
   procedure Output
      (This             : in RP.PWM.PWM_Point;
       Target_Frequency : in RP.Hertz;
       Duty_Cycle       : in Pico.Analog.Percentage := 50.0) with
      Pre => Target_Frequency in 8 .. 62_500_000;

   ---
   --  Same as above but using the 0..255 analog level for the duty cycle.
   --
   procedure Output
      (This             : in RP.PWM.PWM_Point;
       Target_Frequency : in RP.Hertz;
       Duty_Cycle       : in Pico.Analog.Analog_Level) with
      Pre => Target_Frequency in 8 .. 62_500_000;

   ---
   --  Calculate PWM divider and period for a target frequency.
   --
   --  This is the core routine used by `Output`. You can call it directly if you need the raw values for custom PWM
   --  setups.
   --
   --: @param Target_Frequency The desired output frequency in Hertz.
   --: @param Divider          Calculated PWM divider value.
   --: @param Period           Calculated PWM period value.
   procedure Frequency_To_PWM
      (Target_Frequency : in     RP.Hertz;
       Divider          :    out RP.PWM.Divider;
       Period           :    out RP.PWM.Period) with
      Pre => Target_Frequency in 8 .. 62_500_000;

end Pico.Tone;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
