--  with Interfaces.C;

package Ada_Foo_Pack is

   type S_Record is private;
   type S_Record_P is access all S_Record;

   procedure Ada_Foo;

   --  Later, we will use Interfaces.C properly
   --  type String2 is array (Positive range <>) of aliased Character;
   --  for String2'Component_Size use 8; -- 8 bits

   procedure Print_Kernel (S : in out String);

   function Init_S_Record
     (The_Label : String := "01234567";
      The_Int_V : Integer := 42)
      return S_Record_P;

   function Get_Label (TSR : S_Record_P) return String;

private

   type S_Record is
      record
         Label : String (1 .. 8);
         IntV  : Integer;
      end record;


   pragma Export
      (Convention    => C,
       Entity        => Ada_Foo,
       External_Name => "ada_foo");

   pragma Import
     (Convention    => C,
      Entity        => Print_Kernel,
      External_Name => "print_kernel");

end Ada_Foo_Pack;
