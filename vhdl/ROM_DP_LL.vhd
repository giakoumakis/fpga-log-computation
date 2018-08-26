----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    00:12:50 12/29/2013 
-- Module Name:    ROM_DP_LL - Behavioral 
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

entity ROM_DP_LL is
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
end ROM_DP_LL;

architecture Behavioral of ROM_DP_LL is

	type rom_type is array(2**C_ADDRESS_WIDTH-1 downto 0) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
	
	function rom_assign(slv : std_logic_vector) return rom_type is
		variable res : rom_type;
	begin
		for i in 2**C_ADDRESS_WIDTH-1 downto 0 loop
			res(i) := slv(i*C_DATA_WIDTH to (i+1)*C_DATA_WIDTH-1);
		end loop;
		
		return res;
	end function;
	
	constant ROM : rom_type := rom_assign(C_CONTENTS);

begin

	-- ROM (use output register)
	rom_with_output_reg_gen : if C_USE_OUTPUT_REGISTER generate
		signal douta_internal_reg : std_logic_vector(C_DATA_WIDTH-1 downto 0);
		signal doutb_internal_reg : std_logic_vector(C_DATA_WIDTH-1 downto 0);
	begin
		porta : process(clka)
		begin
			if rising_edge(clka) then
				if ena = '1' then
					-- Primitive output register
					douta <= douta_internal_reg;
					-- Primitive internal register
					douta_internal_reg <= ROM(to_integer(unsigned(addra)));
				end if;
			end if;
		end process;
		
		portb : process(clkb)
		begin
			if rising_edge(clkb) then
				if enb = '1' then
					-- Primitive output register
					doutb <= doutb_internal_reg;
					-- Primitive internal register
					doutb_internal_reg <= ROM(to_integer(unsigned(addrb)));
				end if;
			end if;
		end process;
	end generate;
	
	-- ROM (use output register)
	rom_without_output_reg_gen : if not(C_USE_OUTPUT_REGISTER) generate
	begin
		porta : process(clka)
		begin
			if rising_edge(clka) then
				if ena = '1' then
					-- Primitive internal register
					douta <= ROM(to_integer(unsigned(addra)));
				end if;
			end if;
		end process;
		
		portb : process(clkb)
		begin
			if rising_edge(clkb) then
				if enb = '1' then
					-- Primitive internal register
					doutb <= ROM(to_integer(unsigned(addrb)));
				end if;
			end if;
		end process;
	end generate;



end Behavioral;

