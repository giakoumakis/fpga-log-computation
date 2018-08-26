----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    18:00:32 12/29/2013 
-- Module Name:    uint2cfp_conv_grain - Behavioral 
-- Target Devices: 
-- Tool versions: 14.7
-- Description: 
--
-- Revision: 0.01
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

--library common;
--use common.slv_gates_pkg.all;

use work.slv_gates_pkg.all;

entity uint2cfp_conv_grain is
	generic(		
		C_DIN_UNPROCESSED_PART_WIDTH : natural := 32;
		C_EXPONENT_WIDTH : natural := 10;
		C_FRACTION_WIDTH : natural := 16
	);
	port(
		din_unprocessed_part : in std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH-1 downto 0);
		din_exponent : in std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
		din_fraction : in std_logic_vector(C_FRACTION_WIDTH-1 downto 0);
		
		dout_unprocessed_part : out std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH/2-1 downto 0);
		dout_exponent : out std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
		dout_fraction : out std_logic_vector(C_FRACTION_WIDTH-1 downto 0);
		
		ce : in std_logic;
		clk : in std_logic
	);
end uint2cfp_conv_grain;

architecture Behavioral of uint2cfp_conv_grain is

	signal or_input : std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH/2-1 downto 0);
	signal upper_part_not_zero : std_logic;
	
	-- The lower half of the din_unprocessed_part concatenated with the din_fraction
	signal din_up_expo_concat : std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH/2+C_FRACTION_WIDTH-1 downto 0);

begin

	-- assert we can safely divide the width by 2
	assert (C_DIN_UNPROCESSED_PART_WIDTH mod 2 = 0) report "C_DIN_UPROCESSED_PART_WIDTH must be a multiple of 2" severity failure;

	-- assign the most significant part of din_unprocessed_part
	or_input <= din_unprocessed_part(C_DIN_UNPROCESSED_PART_WIDTH-1 downto C_DIN_UNPROCESSED_PART_WIDTH/2);
	
	-- custom synthesizable function to compute the OR of all std_logic_vector bits
	upper_part_not_zero <= slv_or(or_input);
	
	-- concatenate din_unprocessed_part with din_fraction (to use it in the process below)
	din_up_expo_concat <= din_unprocessed_part(C_DIN_UNPROCESSED_PART_WIDTH/2-1 downto 0) & din_fraction;
	
	registered_mux : process(clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				-- give some priority to the long path (contains an adder)
				if upper_part_not_zero = '1' then
						-- at least one non-zero exists in the most significant part
						-- so make the left half of the unprocessed_part as the unprocessed_part
						-- of the next level
						dout_unprocessed_part <=
							din_unprocessed_part(C_DIN_UNPROCESSED_PART_WIDTH-1 downto C_DIN_UNPROCESSED_PART_WIDTH/2);
						-- increment the exponent
						dout_exponent <= std_logic_vector(unsigned(din_exponent) + C_DIN_UNPROCESSED_PART_WIDTH/2);
						-- and shift the right half of the unprocessed_part into the fraction
						dout_fraction <= din_up_expo_concat(C_DIN_UNPROCESSED_PART_WIDTH/2+C_FRACTION_WIDTH-1 downto C_DIN_UNPROCESSED_PART_WIDTH/2);	
				else
						-- no '1' in the most significant part
						-- so just ignore the upper part;
						dout_unprocessed_part <= din_unprocessed_part(C_DIN_UNPROCESSED_PART_WIDTH/2-1 downto 0);
						dout_exponent <= din_exponent;
						dout_fraction <= din_fraction;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

