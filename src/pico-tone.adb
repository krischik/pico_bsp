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

package body Pico.Tone is

   procedure Output
      (This             : in RP.PWM.PWM_Point;
       Target_Frequency : in RP.Hertz;
       Duty_Cycle       : in Pico.Analog.Percentage := 50.0)
   is
      use type Pico.Analog.Percentage;

      Reload  : RP.PWM.Period;
      Divider : RP.PWM.Divider;
   begin
      Frequency_To_PWM (Target_Frequency, Divider, Reload);

      --  Note that the slice is not disabled which you would normally do when PWM is used for data transfer. However
      --  the human ear is works differently and diabling creates a short break in the wave the human ear can hear as
      --  a tiny click.
      This.Slice.Set_Divider (Divider);
      This.Slice.Set_Interval (Reload);
      This.Slice.Set_Duty_Cycle (Channel => This.Channel, Duty_Cycle => Reload * Duty_Cycle);
      This.Slice.Enable;
      return;
   end Output;

   procedure Output
      (This             : in RP.PWM.PWM_Point;
       Target_Frequency : in RP.Hertz;
       Duty_Cycle       : in Pico.Analog.Analog_Level)
   is
      use Pico.Analog;

      Reload  : RP.PWM.Period;
      Divider : RP.PWM.Divider;
   begin
      Frequency_To_PWM (Target_Frequency, Divider, Reload);

      This.Slice.Set_Divider (Divider);
      This.Slice.Set_Interval (Reload);
      This.Slice.Set_Duty_Cycle (Channel => This.Channel, Duty_Cycle => Reload * Duty_Cycle);
      This.Slice.Enable;
      return;
   end Output;

   procedure Frequency_To_PWM
      (Target_Frequency : in     RP.Hertz;
       Divider          :    out RP.PWM.Divider;
       Period           :    out RP.PWM.Period)
   is
      Sys_Freq  : constant RP.Hertz := RP.Clock.Frequency (RP.Clock.SYS);
      --  Aim for a period close to 65535 for maximum resolution.
      Total_Div : Float             := Float (Sys_Freq) / (Float (Target_Frequency) * 65_536.0);
   begin
      --  Clamp divider to hardware limits (8.4 fixed-point)
      Total_Div := (if Total_Div < 1.0 then 1.0 elsif Total_Div > 255.937_5 then 255.937_5 else Total_Div);

      Divider := RP.PWM.Divider (Total_Div);

      --  Period = (Sys_Freq / (Divider * Target_Frequency)) - 1
      Period := RP.PWM.Period ((Float (Sys_Freq) / (Total_Div * Float (Target_Frequency))) - 1.0);

      return;
   end Frequency_To_PWM;

end Pico.Tone;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
