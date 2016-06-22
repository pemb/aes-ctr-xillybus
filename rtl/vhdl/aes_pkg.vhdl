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
  type datablock is array(3 downto 0) of blockcol;
  constant zero_data  : datablock := (others => (others => (others => '0')));
  -- Vector of columns
  type colnet is array(natural range<>) of std_logic_vector(31 downto 0);
  -- Vector of blocks
  type datanet is array(natural range<>) of std_logic_vector(127 downto 0);
  -- the 10 rcon bytes
  type rconarr is array(9 downto 0) of std_logic_vector(7 downto 0);
  constant rcon_const : rconarr   := (X"36", X"1b", X"80", X"40", X"20", X"10", X"08", X"04", X"02", X"01");

  function db2slv(db : datablock) return std_logic_vector;

  function slv2db(slv : std_logic_vector(127 downto 0)) return datablock;

  function bc2slv(bc : blockcol) return std_logic_vector;

  function slv2bc(slv : std_logic_vector(31 downto 0)) return blockcol;

  component sboxshr is
    port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      blockin  : in  std_logic_vector(127 downto 0);
      fc3      : in  std_logic_vector(31 downto 0);
      c        : in  std_logic_vector(127 downto 0);
      nextkey  : out std_logic_vector(127 downto 0);
      blockout : out std_logic_vector(127 downto 0)
      );
  end component;
  component colmix is
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;
      datain  : in  std_logic_vector(127 downto 0);
      inrkey  : in  std_logic_vector(127 downto 0);
      outrkey : out std_logic_vector(127 downto 0);
      dataout : out std_logic_vector(127 downto 0));
  end component colmix;
  component addkey is
    generic (
      rcon : std_logic_vector(7 downto 0));
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      roundkey : in  std_logic_vector(127 downto 0);
      datain   : in  std_logic_vector(127 downto 0);
      dataout  : out std_logic_vector(127 downto 0);
      fc3      : out std_logic_vector(31 downto 0);
      c        : out std_logic_vector(127 downto 0)
      );
  end component addkey;
  component keysched1 is
    generic (
      rcon : in std_logic_vector(7 downto 0)
      ); port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        roundkey : in  std_logic_vector(127 downto 0);
        fc3      : out std_logic_vector(31 downto 0);
        c        : out std_logic_vector(127 downto 0));
  end component;
  component mixcol is
    port (
      clk  : in  std_logic;
      rst  : in  std_logic;
      din  : in  std_logic_vector(31 downto 0);
      dout : out std_logic_vector(31 downto 0));
  end component mixcol;
  component sbox is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      bytein  : in  std_logic_vector(7 downto 0);
      byteout : out std_logic_vector(7 downto 0)
      );
  end component;

  component aes_top is
    port(
      clk_i        : in  std_logic;
      rst_i        : in  std_logic;
      plaintext_i  : in  std_logic_vector(127 downto 0);
      keyblock_i   : in  std_logic_vector(127 downto 0);
      ciphertext_o : out std_logic_vector(127 downto 0)
      );
  end component;

end package aes_pkg;

package body aes_pkg is

  function db2slv(db : datablock) return std_logic_vector is
    variable temp  : std_logic_vector(127 downto 0);
    variable index : integer := 0;
  begin
    l0 : for i in 0 to 3 loop
      l1 : for j in 0 to 3 loop
        temp(index+7 downto index) := db(3-i)(3-j);
        index                      := index + 8;
      end loop;
    end loop;
    return temp;
  end db2slv;

  function slv2db(slv : std_logic_vector(127 downto 0)) return datablock is
    variable temp  : datablock;
    variable index : integer := 0;
  begin
    l0 : for i in 0 to 3 loop
      l1 : for j in 0 to 3 loop
        temp(3-i)(3-j) := slv(index+7 downto index);
        index          := index + 8;
      end loop;
    end loop;
    return temp;
  end slv2db;

  function bc2slv(bc : blockcol) return std_logic_vector is
    variable temp : std_logic_vector(31 downto 0);
  begin
    l0 : for i in 0 to 3 loop
      temp(8*i+7 downto 8*i) := bc(i);
    end loop;
    return temp;
  end bc2slv;

  function slv2bc(slv : std_logic_vector(31 downto 0)) return blockcol is
    variable temp : blockcol;
  begin
    l0 : for i in 0 to 3 loop
      temp(i) := slv((8*i+7) downto (8*i));
    end loop;
    return temp;
  end slv2bc;

end aes_pkg;

