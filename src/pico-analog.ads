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

with RP.GPIO;
with RP.PWM;
with HAL;

---
--   Simplified analogue GPIO using Pulse Width Modulation (PWM).
--
--   Pulse Width Modulation (PWM) allows us to generate analogue-like outputs
--   on digital GPIO pins by varying the duty cycle of a high-frequency square
--   wave. This package provides a simple, reusable interface for PWM-based
--   analogue output on the Raspberry Pi Pico. It is designed to be a universal
--   library component, saving us from repetitive code and helping the community.
--
package Pico.Analog is
   use type RP.PWM.Period;
   use type HAL.UInt8;

   type PWM_Point is private;

   ---
   --  Default values suitable for dimming an LED.
   --
   Default_Frequency : constant RP.Hertz      := 1_000_000;
   Default_Reload    : constant RP.PWM.Period := 1_000;

   ---
   --  Analogue value as fixed point percentage.
   --
   type Percentage is delta 0.1 digits 4 range 0.0 .. 100.0;

   ---
   --  Analogue value as 8-bit value (for compatibility with C code).
   --
   subtype Analog_Level is HAL.UInt8;

   ---
   --  Create a new PWM point from a GPIO point. This configures the PWM
   --  hardware for the given GPIO pin with the specified base frequency and
   --  reload period. Note that the final output frequency will be
   --  approximately Frequency divided by Reload, adjusted to the nearest
   --  divider of the Pico's base frequency.
   --
   --: @param Point     GPIO point to use for the PWM output
   --: @param Frequency Base frequency in Hertz
   --: @param Reload    Reload period (ticks per cycle)
   --: @return          New PWM point configured and ready for use
   function To_PWM
      (Point     : in out RP.GPIO.GPIO_Point;
       Frequency : in     RP.Hertz      := Default_Frequency;
       Reload    : in     RP.PWM.Period := Default_Reload)
       return PWM_Point;

   ---
   --  Set the PWM output level using a percentage duty cycle (0.0 to 100.0).
   --
   procedure Write_Analog (Point : in PWM_Point; Level : in Percentage) with
      Inline;

   ---
   --  Set the PWM output level using an 8-bit value (0 to 255).
   --
   procedure Write_Analog (Point : in PWM_Point; Level : in Analog_Level) with
      Inline;

   ---
   --  Get the underlying PWM point to use with the RP.PWM package if more
   --  advanced control is required.
   --
   function Get_Base (Point : in PWM_Point) return RP.PWM.PWM_Point with
      Inline, Pure_Function;

   ---
   --  Get the frequency set for this PWM point.
   --
   function Get_Frequency (Point : in PWM_Point) return RP.Hertz with
      Inline, Pure_Function;

   ---
   --  Get the reload counter set for this PWM point.
   --
   function Get_Reload (Point : in PWM_Point) return RP.PWM.Period with
      Inline, Pure_Function;

   ---
   --  Calculate the actual reload counter needed for a given analogue output
   --  expressed as a percentage.
   --
   --: @param Left   Base reload counter
   --: @param Right  Desired analogue output as a percentage (0.0 .. 100.0)
   --: @return       Scaled reload counter corresponding to the duty cycle
   function "*"
      (Left  : in RP.PWM.Period;
       Right : in Percentage)
       return RP.PWM.Period is
      (if Right = 0.0 then 0
       elsif Right = 100.0 then Left
       else RP.PWM.Period (Integer (Left) * Integer (Right) / 100)) with
      Inline, Pure_Function;

   ---
   --  Calculate the actual reload counter needed for a given analogue output
   --  expressed as an 8-bit level.
   --
   --: @param Left   Base reload counter
   --: @param Right  Desired analogue output as an 8-bit value (0 .. 255)
   --: @return       Scaled reload counter corresponding to the duty cycle
   function "*"
      (Left  : in RP.PWM.Period;
       Right : in Analog_Level)
       return RP.PWM.Period is
      (if Right = 0 then 0
       elsif Right = 255 then Left
       else RP.PWM.Period (Integer (Left) * Integer (Right) / 255)) with
      Inline, Pure_Function;

private

   type PWM_Point is record
      Base      : RP.PWM.PWM_Point;
      Frequency : RP.Hertz;
      Reload    : RP.PWM.Period;
   end record;

   function Get_Base (Point : in PWM_Point) return RP.PWM.PWM_Point is (Point.Base);
   function Get_Frequency (Point : in PWM_Point) return RP.Hertz is (Point.Frequency);
   function Get_Reload (Point : in PWM_Point) return RP.PWM.Period is (Point.Reload);

end Pico.Analog;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :