----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- 
-- Create Date:    01:01:59 10/17/2013 
-- Design Name: 
-- Module Name:    ShiftRegister - Behavioral 
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
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftRegister is
	generic(
		C_LATENCY : natural range 1 to natural'high := 4
	);
	port(
		din : in std_logic;
		dout : out std_logic;
		en : in  std_logic;
		clk : in  std_logic;
		sclr : in  std_logic
	);
end ShiftRegister;

architecture Behavioral of ShiftRegister is
	
	signal sr : std_logic_vector(C_LATENCY-1 downto 0);
	 
begin

	process(clk)
	begin
		if (clk'event and clk='1') then
			if sclr = '1' then
				sr <= (others => '0');
			elsif en = '1' then
				for i in 0 to C_LATENCY-2 loop
					sr(i+1) <= sr(i);
				end loop;
				
				sr(0) <= din;
			end if;
		end if;
	end process;

    dout <= sr(C_LATENCY-1);
	 
end Behavioral;

