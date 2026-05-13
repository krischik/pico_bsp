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

package body Pico.Utils with
   Spark_Mode => On
is

   function Map
      (In_Value : in Integer;
       In_Min   : in Integer;
       In_Max   : in Integer;
       Out_Min  : in Integer;
       Out_Max  : in Integer)
       return Integer
   is
      --  We compute the scaling in steps so GNATprove can prove every intermediate result stays within Integer'Range.
      Range_In  : constant Long_Long_Integer := Long_Long_Integer (In_Max) - Long_Long_Integer (In_Min);
      Range_Out : constant Long_Long_Integer := Long_Long_Integer (Out_Max) - Long_Long_Integer (Out_Min);
      Offset    : constant Long_Long_Integer := Long_Long_Integer (In_Value) - Long_Long_Integer (In_Min);
   begin
      if Range_In = 0 then
         --  Degenerate case: input range has zero width → return lower output
         return Out_Min;
      else
         return Integer (Long_Long_Integer (Out_Min) + (Offset * Range_Out) / Range_In);
      end if;
   end Map;

end Pico.Utils;

--------------------------------------------------------------- {{{ ----------
--: vim: set textwidth=120 nowrap tabstop=8 shiftwidth=3 softtabstop=3 expandtab :
--: vim: set filetype=ada fileencoding=utf-8 fileformat=unix foldmethod=marker :
--: vim: set spell spelllang=en_gb :
