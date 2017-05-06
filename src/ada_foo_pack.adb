--  with Ada.Characters.Latin_1;

package body Ada_Foo_Pack is

   type Color_Type is (RED, BLACK, PURPLE_BLUE);
   type Fixed_Point_Type is delta 0.1 range -100.0 .. 100.0;
   type Unsigned_Type is mod 2**32;
   type Float_Type is digits 6;

   T1 : S_Record_P;

   procedure Ada_Foo is
      S1 : String := Integer'Image (42) & Character'Val (0);
      S2 : String := Color_Type'Image (PURPLE_BLUE) & Character'Val (0);
      S3 : String := Boolean'Image(True)    & Character'Val (0);
      S4 : String := Fixed_Point_Type'Image(4.2) & Character'Val (0);
      S5 : String := Integer'Image(-42) & Character'Val (0);
      S6 : String := Unsigned_Type'Image(42) & Character'Val (0);
      S7 : String := Float_Type'Image(424.242) & Character'Val (0);
      S8 : String := Get_Label (T1);
   begin
      --
      Print_Kernel (S8);
      --
      Print_Kernel (S1);
      Print_Kernel (S2);
      Print_Kernel (S3);
      Print_Kernel (S4);
      Print_Kernel (S5);
      Print_Kernel (S6);
      Print_Kernel (S7);
   end Ada_Foo;

   function Init_S_Record
     (The_Label : String := "01234567";
      The_Int_V : Integer := 42)
      return S_Record_P
   is
      Result : S_Record_P;
   begin
      Result := new S_Record;
      Result.Label := (others => ' ');
      if The_Label'Last - The_Label'First > 7 then
         Result.Label := The_Label (The_Label'First .. The_Label'First + 7);
      else
         Result.Label := The_Label (The_Label'First .. The_Label'Last);
      end if;
      Result.IntV := The_Int_V;
      return Result;
   end Init_S_Record;


   function Get_Label (TSR : S_Record_P) return String
   is
      Result : String (1 .. 8) := (others => ' ');
   begin
      if (TSR /= Null) then
         Result := TSR.Label;
      end if;
      return Result;
   end Get_Label;


begin
   --
   T1 := Init_S_Record;
   --
end Ada_Foo_Pack;
