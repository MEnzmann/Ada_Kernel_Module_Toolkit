------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                         S Y S T E M . M E M O R Y                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--          Copyright (C) 2001-2014, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This is a simplified version of this package, for use with a configurable
--  run-time library that does not provide Ada tasking. It does not provide
--  any deallocation routine.

--  This package provides the low level memory allocation/deallocation
--  mechanisms used by GNAT.

package System.Memory is
   pragma Elaborate_Body;

   type size_t is mod 2 ** Standard'Address_Size;
   --  Note: the reason we redefine this here instead of using the
   --  definition in Interfaces.C is that we do not want to drag in
   --  all of Interfaces.C just because System.Memory is used.

   function Alloc (Size : size_t) return System.Address;
   --  This is the low level allocation routine. Given a size in storage
   --  units, it returns the address of a maximally aligned block of
   --  memory.
   --
   --  A first check is performed to discard memory allocations that are
   --  obviously too big, preventing problems of memory wraparound. If Size is
   --  greater than the maximum number of storage elements (taking into account
   --  the maximum alignment) in the machine, then a Storage_Error exception is
   --  raised before trying to perform the memory allocation.
   --
   --  If Size is set to zero on entry, then a minimal (but non-zero)
   --  size block is allocated.
   --
   --  If there is not enough free memory on the heap for the requested
   --  allocation then a Storage_Error exception is raised and the heap remains
   --  unchanged.
   --
   --  Note: this is roughly equivalent to the standard C malloc call
   --  with the additional semantics as described above.

private
   --  This type is needed to provide proper parameters to the
   --  Kernel-Allocation function kmalloc:
   type Gfp_T is mod 2**32;
   --  The following constants replace the defines in gfp.h
   GFP_DMA              : constant Gfp_T := 16#0000_0001#;
   GFP_HIGHMEM          : constant Gfp_T := 16#0000_0002#;
   GFP_DMA32            : constant Gfp_T := 16#0000_0004#;
   GFP_MOVABLE          : constant Gfp_T := 16#0000_0008#;
   GFP_WAIT             : constant Gfp_T := 16#0000_0010#;
   GFP_HIGH             : constant Gfp_T := 16#0000_0020#;
   GFP_IO               : constant Gfp_T := 16#0000_0040#;
   GFP_FS               : constant Gfp_T := 16#0000_0080#;
   GFP_COLD             : constant Gfp_T := 16#0000_0100#;
   GFP_NOWARN           : constant Gfp_T := 16#0000_0200#;
   GFP_REPEAT           : constant Gfp_T := 16#0000_0400#;
   GFP_NOFAIL           : constant Gfp_T := 16#0000_0800#;
   GFP_NORETRY          : constant Gfp_T := 16#0000_1000#;
   GFP_MEMALLOC         : constant Gfp_T := 16#0000_2000#;
   GFP_COMP             : constant Gfp_T := 16#0000_4000#;
   GFP_ZERO             : constant Gfp_T := 16#0000_8000#;
   GFP_NOMEMALLOC       : constant Gfp_T := 16#0001_0000#;
   GFP_HARDWALL         : constant Gfp_T := 16#0002_0000#;
   GFP_THISNODE         : constant Gfp_T := 16#0004_0000#;
   GFP_RECLAIMABLE      : constant Gfp_T := 16#0008_0000#;
   GFP_NOTRACK          : constant Gfp_T := 16#0020_0000#;
   GFP_NO_KSWAPD        : constant Gfp_T := 16#0040_0000#;
   GFP_OTHER_NODE       : constant Gfp_T := 16#0080_0000#;
   GFP_WRITE            : constant Gfp_T := 16#0100_0000#;

   GFP_ATOMIC           : constant Gfp_T := GFP_HIGH;
   GFP_NOIO             : constant Gfp_T := GFP_WAIT;
   GFP_NOFS             : constant Gfp_T := GFP_WAIT or GFP_IO;
   GFP_KERNEL           : constant Gfp_T := GFP_WAIT or GFP_IO or GFP_FS;
   GFP_TEMPORARY        : constant Gfp_T :=
     (GFP_WAIT or GFP_IO or GFP_FS or GFP_RECLAIMABLE);
   GFP_USER             : constant Gfp_T :=
     (GFP_WAIT or GFP_IO or GFP_FS or GFP_HARDWALL);
   GFP_HIGHUSER         : constant Gfp_T :=
     (GFP_WAIT or GFP_IO or GFP_FS or GFP_HARDWALL or GFP_HIGHMEM);
   GFP_HIGHUSER_MOVABLE : constant Gfp_T :=
     (GFP_WAIT or GFP_IO or GFP_FS or GFP_HARDWALL or
      GFP_HIGHMEM or GFP_MOVABLE);
   GFP_IOFS             : constant Gfp_T := (GFP_IO or GFP_FS);
   GFP_TRANSHUGE        : constant Gfp_T :=
     (GFP_HIGHUSER_MOVABLE or GFP_COMP or
      GFP_NOMEMALLOC or GFP_NORETRY or GFP_NOWARN or GFP_NO_KSWAPD);

   --  The following functions are imported from slab.h:
   procedure Kfree (MemAccess : in out System.Address);
   pragma Import (C, Kfree, "kfree");

   function Kmalloc
     (Size  : size_t;
      Flags : Gfp_T)
     return System.Address;
   pragma Import (C, Kmalloc, "__kmalloc");

   --  The following names are used from the generated compiler code

   pragma Export (C, Alloc,   "__gnat_malloc");

end System.Memory;
