----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    02:37:23 12/30/2013 
-- Module Name:    uint2cfp_conv_stage - Behavioral 
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

entity uint2cfp_conv_stage is
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
end uint2cfp_conv_stage;

architecture Behavioral of uint2cfp_conv_stage is

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

	component uint2cfp_conv_grain is
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
	end component;
	
	-- Output from uint2cfp_conv_grain for the next stage (recursive instantiations)
	signal nxt_stg_unprocessed_part : std_logic_vector(C_DIN_UNPROCESSED_PART_WIDTH/2-1 downto 0);
	signal nxt_stg_exponent : std_logic_vector(C_EXPONENT_WIDTH-1 downto 0);
	signal nxt_stg_fraction : std_logic_vector(C_FRACTION_WIDTH-1 downto 0);

begin

	-- Instantiate the grain
	uint2cfp : uint2cfp_conv_grain
		generic map(		
			C_DIN_UNPROCESSED_PART_WIDTH => C_DIN_UNPROCESSED_PART_WIDTH,
			C_EXPONENT_WIDTH => C_EXPONENT_WIDTH,
			C_FRACTION_WIDTH => C_FRACTION_WIDTH
		)
		port map(
			din_unprocessed_part => din_unprocessed_part,
			din_exponent => din_exponent,
			din_fraction => din_fraction,
			
			dout_unprocessed_part => nxt_stg_unprocessed_part,
			dout_exponent => nxt_stg_exponent,
			dout_fraction => nxt_stg_fraction,
			
			ce => ce,
			clk => clk
		);
	
	-- We have to instantiate more stages
	gen_next_stage : if C_DIN_UNPROCESSED_PART_WIDTH > 2 generate
	begin
		next_stage : uint2cfp_conv_stage
			generic map(		
				C_DIN_UNPROCESSED_PART_WIDTH => C_DIN_UNPROCESSED_PART_WIDTH/2,
				C_EXPONENT_WIDTH => C_EXPONENT_WIDTH,
				C_FRACTION_WIDTH => C_FRACTION_WIDTH
			)
			port map(
				din_unprocessed_part => nxt_stg_unprocessed_part,
				din_exponent => nxt_stg_exponent,
				din_fraction => nxt_stg_fraction,
				
				dout_zeron => dout_zeron,
				dout_exponent => dout_exponent,
				dout_fraction => dout_fraction,
				
				ce => ce,
				clk => clk
			);		
	end generate;
	
	-- This was the last stage, so just connect the nxt_stg_* signals to the dout_* signals
	gen_wires : if C_DIN_UNPROCESSED_PART_WIDTH = 2 generate
	begin
		dout_zeron <= nxt_stg_unprocessed_part(0);
		dout_exponent <= nxt_stg_exponent;
		dout_fraction <= nxt_stg_fraction;
	end generate;


end Behavioral;

