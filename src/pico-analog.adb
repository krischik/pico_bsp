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

package body Pico.Analog is

   function To_PWM
      (Point     : in out RP.GPIO.GPIO_Point;
       Frequency : in     RP.Hertz      := Default_Frequency;
       Reload    : in     RP.PWM.Period := Default_Reload)
       return PWM_Point
   is
      Retval : constant PWM_Point :=
         (RP.PWM.To_PWM (Point),
          Frequency,
          Reload);
   begin
      RP.PWM.Set_Frequency (Retval.Base.Slice, Frequency);
      RP.PWM.Set_Interval (Retval.Base.Slice, Reload);
      RP.PWM.Enable (Retval.Base.Slice);
      Point.Configure (RP.GPIO.Output, RP.GPIO.Floating, RP.GPIO.PWM);

      return Retval;
   end To_PWM;

   procedure Write_Analog (Point : in PWM_Point; Level : in Percentage) is
      Reload     : constant RP.PWM.Period := Get_Reload (Point);
      Duty_Cycle : constant RP.PWM.Period := Reload * Level;
   begin
      RP.PWM.Set_Duty_Cycle (Point.Base.Slice, Point.Base.Channel, Duty_Cycle);
      return;
   end Write_Analog;

   procedure Write_Analog (Point : in PWM_Point; Level : in Analog_Level) is
      Reload     : constant RP.PWM.Period := Get_Reload (Point);
      Duty_Cycle : constant RP.PWM.Period := Reload * Level;
   begin
      RP.PWM.Set_Duty_Cycle (Point.Base.Slice, Point.Base.Channel, Duty_Cycle);
      return;
   end Write_Analog;

begin
   RP.PWM.Initialize;

end Pico.Analog;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
