----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- 
-- Create Date:    23:58:36 11/17/2013 
-- Design Name: 
-- Module Name:    axis_reset_proc - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_reset_proc is
	port(
		resetn : in  std_logic;
		clk : in  std_logic;
		reset : out  std_logic
	);
end axis_reset_proc;

architecture Behavioral of axis_reset_proc is

begin

	dff : process(clk)
	begin
		if rising_edge(clk) then
			if resetn = '0' then
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;

end Behavioral;

