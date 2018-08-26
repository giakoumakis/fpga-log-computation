--
-- © 2014 Pavlos Giakoumakis
-- All rights reserved.
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package slv_gates_pkg is

	function slv_or (slv : std_logic_vector) return std_logic;
	function slv_and (slv : std_logic_vector) return std_logic;

end slv_gates_pkg;

package body slv_gates_pkg is

	function slv_or (slv : std_logic_vector) return std_logic is
		variable res : std_logic_vector(slv'range);
	begin
		-- res has the same range as slv
		res(slv'low) := slv(slv'low);
		
		-- I placed this check to hide an xst null range warning
		-- at the loop
		if slv'high = slv'low then
			return res(slv'high);
		end if;
		
		for i in slv'low+1 to slv'high loop
			res(i) := res(i-1) or slv(i);
		end loop;
		return res(slv'high);
	end function;
	
	function slv_and (slv : std_logic_vector) return std_logic is
		variable res : std_logic_vector(slv'range);
	begin
		-- res has the same range as slv
		res(slv'low) := slv(slv'low);
		
		-- I placed this check to hide an xst null range warning
		-- at the loop
		if slv'high = slv'low then
			return res(slv'high);
		end if;
			
		for i in slv'low+1 to slv'high loop
			res(i) := res(i-1) and slv(i);
		end loop;
		return res(slv'high);
	end function;
 
end slv_gates_pkg;
