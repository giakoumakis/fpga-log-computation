----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- 
-- Create Date:    23:08:22 10/16/2013 
-- Design Name: 
-- Module Name:    SumCalcShiftReg - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 14.6
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- This shift register inputs and outputs words of data (one word per clock). Useful for pipelining.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WideShiftRegister is
	generic(
		C_DATA_WIDTH : natural := 9;
		C_LATENCY : natural := 4
	);
	port(
		din : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
		dout : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
		en : in  std_logic;
		clk : in  std_logic
	);
end WideShiftRegister;

architecture Behavioral of WideShiftRegister is
	
	type slv_v is array(natural range <>) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
	
	signal sr : slv_v(C_LATENCY-1 downto 0);
	 
begin

	process(clk)
	begin
		if (clk'event and clk='1') then
			if en = '1' then
				for i in 0 to C_LATENCY-2 loop
					sr(i+1) <= sr(i);
				end loop;
				
				sr(0) <= din;
			end if;
		end if;
	end process;

    dout <= sr(C_LATENCY-1);
	 
end Behavioral;

