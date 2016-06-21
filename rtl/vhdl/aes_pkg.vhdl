----------------------------------------------------------------------
----                                                              ----
---- Pipelined Aes IP Core                                        ----
----                                                              ----
---- This file is part of the Pipelined AES project               ----
---- http://www.opencores.org/cores/aes_pipe/                     ----
----                                                              ----
---- Description                                                  ----
---- Implementation of AES IP core according to                   ----
---- FIPS PUB 197 specification document.                         ----
----                                                              ----
---- To Do:                                                       ----
----   -                                                          ----
----                                                              ----
---- Author:                                                      ----
----      - Subhasis Das, subhasis256@gmail.com                   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 25/03/10
-- Email: subhasis256@gmail.com
------------------------------------------------------
-- Common library file containing common data path definitions
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package aes_pkg is
  -- A column of 4 bytes
  type blockcol is array(3 downto 0) of std_logic_vector(7 downto 0);
  constant zero_col   : blockcol  := (others => (others => '0'));
  -- A datablock of 16 bytes
  type datablock is array(3 downto 0, 3 downto 0) of std_logic_vector(7 downto 0);
  constant zero_data  : datablock := (others => (others => (others => '0')));
  -- Vector of columns
  type colnet is array(natural range<>) of blockcol;
  -- Vector of blocks
  type datanet is array(natural range<>) of datablock;
  -- the 10 rcon bytes
  type rconarr is array(9 downto 0) of std_logic_vector(7 downto 0);
  constant rcon_const : rconarr   := (X"36", X"1b", X"80", X"40", X"20", X"10", X"08", X"04", X"02", X"01");
  component sboxshr is
    port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      blockin  : in  datablock;
      fc3      : in  blockcol;
      c0       : in  blockcol;
      c1       : in  blockcol;
      c2       : in  blockcol;
      c3       : in  blockcol;
      nextkey  : out datablock;
      blockout : out datablock
      );
  end component;
  component colmix is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      datain  : in  datablock;
      inrkey  : in  datablock;
      outrkey : out datablock;
      dataout : out datablock
      );
  end component;
  component addkey is
    generic (
      rcon : in std_logic_vector(7 downto 0)
      ); port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        roundkey : in  datablock;
        datain   : in  datablock;
        dataout  : out datablock;
        fc3      : out blockcol;
        c0       : out blockcol;
        c1       : out blockcol;
        c2       : out blockcol;
        c3       : out blockcol
        );
  end component;
  component keysched1 is
    generic (
      rcon : in std_logic_vector(7 downto 0)
      ); port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        roundkey : in  datablock;
        fc3      : out blockcol;
        c0       : out blockcol;
        c1       : out blockcol;
        c2       : out blockcol;
        c3       : out blockcol
        );
  end component;
  component mixcol is
    port(
      clk  : in  std_logic;
      rst  : in  std_logic;
      in0  : in  std_logic_vector(7 downto 0);
      in1  : in  std_logic_vector(7 downto 0);
      in2  : in  std_logic_vector(7 downto 0);
      in3  : in  std_logic_vector(7 downto 0);
      out0 : out std_logic_vector(7 downto 0);
      out1 : out std_logic_vector(7 downto 0);
      out2 : out std_logic_vector(7 downto 0);
      out3 : out std_logic_vector(7 downto 0)
      );
  end component;
  component sbox is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      bytein  : in  std_logic_vector(7 downto 0);
      byteout : out std_logic_vector(7 downto 0)
      );
  end component;
end package aes_pkg;
