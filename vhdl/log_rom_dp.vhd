----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    01:15:32 12/29/2013 
-- Module Name:    log_rom - Behavioral 
-- Target Devices: 
-- Tool versions: 14.7
-- Description: 
--
-- Revision: 0.01
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity log_rom_dp is
	generic(
			C_DATA_WIDTH : natural := 18;
			C_ADDRESS_WIDTH : natural := 10;
			C_USE_OUTPUT_REGISTER : boolean := true
		);
		port(
			clka : in std_logic;
			ena : in std_logic;
			addra : in std_logic_vector(C_ADDRESS_WIDTH-1 downto 0);
			douta : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
			clkb : in std_logic;
			enb : in std_logic;
			addrb : in std_logic_vector(C_ADDRESS_WIDTH-1 downto 0);
			doutb : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
		);
end log_rom_dp;

architecture Behavioral of log_rom_dp is

	component ROM_DP_LL is
		generic(
			C_DATA_WIDTH : natural := 8;
			C_ADDRESS_WIDTH : natural := 4;
			C_USE_OUTPUT_REGISTER : boolean := true;
			C_CONTENTS : std_logic_vector := x"00000000000000000000000000000000"
		);
		port(
			clka : in std_logic;
			ena : in std_logic;
			addra : in std_logic_vector(C_ADDRESS_WIDTH-1 downto 0);
			douta : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
			clkb : in std_logic;
			enb : in std_logic;
			addrb : in std_logic_vector(C_ADDRESS_WIDTH-1 downto 0);
			doutb : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
		);
	end component;
	
	-- This function computes the logarithms (log2) between 1 and 2 (without 2)
	function log_rom_init_slv_gen(data_width : natural; address_width : natural) return std_logic_vector is
		variable res : std_logic_vector(0 to data_width*(2**address_width)-1);
	begin
		res(0 to data_width-1) := (others => '0'); -- log2(1) = 0
		
		for i in 1 to 2**address_width-1 loop
			res(i*data_width to (i+1)*data_width-1) := 
				std_logic_vector( -- convert to std_logic_vector
					to_unsigned( -- convert to unsigned vector
						integer( -- convert to integer (it will also round the results)
							real(2**data_width) * ( -- The 0<log2(x)<1 for 0<x<1, so I shift the results to use all available bits
															-- (otherwise the integer conversion will return allways zero)
								log2(real(i+2**address_width)) - real(address_width) -- this is equal to log2(1+i/2**address_width)
							)
						), data_width
					)
				);
		end loop;
		return res;
	end function;
	
	constant C_ROM_CONTENTS : std_logic_vector(0 to C_DATA_WIDTH*(2**C_ADDRESS_WIDTH)-1)
		:= log_rom_init_slv_gen(C_DATA_WIDTH, C_ADDRESS_WIDTH);

begin

	rom : ROM_DP_LL
		generic map(
			C_DATA_WIDTH => C_DATA_WIDTH,
			C_ADDRESS_WIDTH => C_ADDRESS_WIDTH,
			C_USE_OUTPUT_REGISTER => C_USE_OUTPUT_REGISTER,
			C_CONTENTS => C_ROM_CONTENTS
		)
		port map(
			clka => clka,
			ena => ena,
			addra => addra,
			douta => douta,
			clkb => clkb,
			enb => enb,
			addrb => addrb,
			doutb => doutb
		);


end Behavioral;

