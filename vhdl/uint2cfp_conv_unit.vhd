----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    17:51:55 12/29/2013 
-- Module Name:    uint2cfp_conv_unit - rtl_recursive 
-- Target Devices: 
-- Tool versions: 14.7
-- Description: 
--
-- Revision: 0.01
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity uint2cfp_conv_unit is
	generic(
		C_USE_INPUT_REGISTER : boolean := true;
		C_UINT_WIDTH : natural := 32;
		C_EXPONENT_WIDTH : natural := 10;
		C_FRACTION_WIDTH : natural := 16
	);
	port(
		uint : in std_logic_vector(C_UINT_WIDTH-1 downto 0);
		exponent : out std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
		fraction : out std_logic_vector(C_FRACTION_WIDTH-1 downto 0);
		zeron : out std_logic;
		ce : in std_logic;
		clk : in std_logic
	);
end uint2cfp_conv_unit;

architecture rtl_recursive of uint2cfp_conv_unit is
	
	component uint2cfp_conv_stage is
		generic(		
			C_DIN_UNPROCESSED_PART_WIDTH : natural := 32;
			C_EXPONENT_WIDTH : natural := 10;
			C_FRACTION_WIDTH : natural := 16
		);
		port(
			din_unprocessed_part : in std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH-1 downto 0);
			din_exponent : in std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
			din_fraction : in std_logic_vector(C_FRACTION_WIDTH-1 downto 0);
			
			dout_zeron : out std_logic;
			dout_exponent : out std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
			dout_fraction : out std_logic_vector(C_FRACTION_WIDTH-1 downto 0);
			
			ce : in std_logic;
			clk : in std_logic
		);
	end component;

	signal uint_r : std_logic_vector(C_UINT_WIDTH-1 downto 0);

	constant zero_exponent : std_logic_vector(C_EXPONENT_WIDTH-1 downto 0) := (others => '0');
	constant zero_fraction : std_logic_vector(C_FRACTION_WIDTH-1 downto 0) := (others => '0');

begin

	-- Generate the input register
	gen_input_reg_true : if C_USE_INPUT_REGISTER generate
	begin
		-- Generate a register
		process(clk)
		begin
			if rising_edge(clk) then
				if ce = '1' then
					uint_r <= uint;
				end if;
			end if;
		end process;
	end generate;
	
	gen_input_reg_false : if not C_USE_INPUT_REGISTER generate
	begin
		uint_r <= uint; -- use a simple wire instead of a register
	end generate;
	
	uint2cfp : uint2cfp_conv_stage
		generic map(		
			C_DIN_UNPROCESSED_PART_WIDTH => C_UINT_WIDTH,
			C_EXPONENT_WIDTH => C_EXPONENT_WIDTH,
			C_FRACTION_WIDTH => C_FRACTION_WIDTH
		)
		port map(
			din_unprocessed_part => uint_r,
			din_exponent => zero_exponent,
			din_fraction => zero_fraction,
			
			dout_zeron => zeron,
			dout_exponent => exponent,
			dout_fraction => fraction,
			
			ce => ce,
			clk => clk
		);

end rtl_recursive;

