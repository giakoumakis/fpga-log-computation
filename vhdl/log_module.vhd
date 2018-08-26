----------------------------------------------------------------------------------
-- Company: 
-- Engineer: © 2014 Pavlos Giakoumakis
-- All rights reserved.
--
-- Create Date:    15:24:11 12/30/2013 
-- Module Name:    log_module - Behavioral 
-- Target Devices: 
-- Tool versions: 14.7
-- Description: 
--
-- Revision: 0.01
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity log_module is
	generic(
		C_USE_INPUT_REGISTER : boolean := true;
		C_LOG_ROM_LATENCY : natural := 2;
		C_LOG_ROM_DATA_WIDTH : natural := 18; -- ALSO THE OUTPUT FRACTION WIDTH
		C_LOG_ROM_ADDRESS_WIDTH : natural := 10;
		C_S_AXIS_TDATA_WIDTH : natural := 32;
		C_M_AXIS_INTEGER_PART_WIDTH : natural := 5
	);
	port(
		-- Input I/F
		s_axis_tvalid : in std_logic;
		s_axis_tready : out std_logic;
		s_axis_tdata : in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		s_axis_tlast: in std_logic;
		s_axis_tuser: in std_logic_vector(0 downto 0);
		
		-- Output I/F
		m_axis_tvalid : out std_logic;
		m_axis_tready : in std_logic;
		m_axis_tdata : out std_logic_vector(C_M_AXIS_INTEGER_PART_WIDTH+C_LOG_ROM_DATA_WIDTH-1 downto 0);
		m_axis_tlast : out std_logic;
		-- (C_S_AXIS_TDATA_WIDTH downto 1) is the s_axis_tdata delayed
		m_axis_tuser : out std_logic_vector(C_S_AXIS_TDATA_WIDTH downto 0);
		
		-- LOGROM I/F
		rom_clk : out std_logic;
		rom_en : out std_logic;
		rom_addr : out std_logic_vector(C_LOG_ROM_ADDRESS_WIDTH-1 downto 0);
		rom_dout : in std_logic_vector(C_LOG_ROM_DATA_WIDTH-1 downto 0);
		
		--
		aclk : in std_logic;
		aresetn : in std_logic
	);		
end log_module;

architecture Behavioral of log_module is

	component axis_reset_proc is
		port(
			resetn : in  std_logic;
			clk : in  std_logic;
			reset : out  std_logic
		);
	end component;
	
	component uint2cfp_conv_unit is
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
	end component;
	
	component ShiftRegister is
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
	end component;
	
	component WideShiftRegister is
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
	end component;
	
	-- Convert boolean to integer
	function boolean2int(bool : boolean) return integer is
	begin
		if bool then
			return 1;
		else
			return 0;
		end if;
	end function;
	
	-- Latency Constants
	constant CI_UINT2CFP_LATENCY : natural := integer(ceil(log2(real(C_S_AXIS_TDATA_WIDTH)))) + boolean2int(C_USE_INPUT_REGISTER);
	constant CI_TOTAL_LATENCY : natural := C_LOG_ROM_LATENCY + CI_UINT2CFP_LATENCY;
	
	-- Active high reset signal (internally generated from the active
	-- low input reset aresetn)
	signal areset : std_logic;
	
	-- Custom fp format : x = 2^(exponent) + fraction + 1
	signal exponent : std_logic_vector(C_M_AXIS_INTEGER_PART_WIDTH-1 downto 0);
	signal fraction : std_logic_vector(C_LOG_ROM_ADDRESS_WIDTH-1 downto 0);

begin

	-- Generate active high Reset Signal
	reset_gen : axis_reset_proc
		port map(
			resetn => aresetn,
			clk => aclk,
			reset => areset
		);

	-- Convert to the custom floating point format : x = 2^(exponent) + fraction + 1
	uint2cfp : uint2cfp_conv_unit
		generic map(
			C_USE_INPUT_REGISTER => C_USE_INPUT_REGISTER,
			C_UINT_WIDTH => C_S_AXIS_TDATA_WIDTH,
			C_EXPONENT_WIDTH => C_M_AXIS_INTEGER_PART_WIDTH,
			C_FRACTION_WIDTH => C_LOG_ROM_ADDRESS_WIDTH
		)
		port map(
			uint => s_axis_tdata,
			exponent => exponent,
			fraction => fraction,
			zeron => open,
			ce => m_axis_tready,
			clk => aclk
		);
		
	-- ROM I/F Assignments
	-- This rom will compute the log2(fraction + 1)
	rom_clk <= aclk;
	rom_en <= m_axis_tready;
	rom_addr <= fraction;
	m_axis_tdata(C_LOG_ROM_DATA_WIDTH-1 downto 0) <= rom_dout;
	
	-- log2(2^(exponent)) = exponent
	-- just delay the exponent
	integer_part_sr : WideShiftRegister
		generic map(
			C_DATA_WIDTH => C_M_AXIS_INTEGER_PART_WIDTH,
			C_LATENCY => C_LOG_ROM_LATENCY
		)
		port map(
			din => exponent,
			dout => m_axis_tdata(C_M_AXIS_INTEGER_PART_WIDTH+C_LOG_ROM_DATA_WIDTH-1 downto C_LOG_ROM_DATA_WIDTH),
			en => m_axis_tready,
			clk => aclk
		);
	
	-- Forward s_axis_tdata to m_axis_tuser(32 downto 1)
	s_axis_tdata_sr : WideShiftRegister
		generic map(
			C_DATA_WIDTH => C_S_AXIS_TDATA_WIDTH,
			C_LATENCY => CI_TOTAL_LATENCY
		)
		port map(
			din => s_axis_tdata,
			dout => m_axis_tuser(32 downto 1),
			en => m_axis_tready,
			clk => aclk
		);

	tvalid_sr : ShiftRegister
		generic map(
			C_LATENCY => CI_TOTAL_LATENCY
		)
		port map(
			din => s_axis_tvalid,
			dout => m_axis_tvalid,
			en => m_axis_tready,
			clk => aclk,
			sclr => areset
		);
	
	tlast_sr : ShiftRegister
		generic map(
			C_LATENCY => CI_TOTAL_LATENCY
		)
		port map(
			din => s_axis_tlast,
			dout => m_axis_tlast,
			en => m_axis_tready,
			clk => aclk,
			sclr => areset
		);
		
	tuser_sr : ShiftRegister
		generic map(
			C_LATENCY => CI_TOTAL_LATENCY
		)
		port map(
			din => s_axis_tuser(0),
			dout => m_axis_tuser(0),
			en => m_axis_tready,
			clk => aclk,
			sclr => areset
		);
	
	-- forward the m_axis_tready signal
	s_axis_tready <= m_axis_tready; -- and not areset;

end Behavioral;

