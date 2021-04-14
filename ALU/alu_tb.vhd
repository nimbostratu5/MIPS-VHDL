library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
 
entity alu_tb is
end entity;
 
architecture sim of alu_tb is
 
	signal	x,y : std_logic_vector(31 downto 0);
	signal	add_sub: std_logic;
	signal	func : std_logic_vector(1 downto 0 );
	signal	output : std_logic_vector(31 downto 0);
	signal	logic_func : std_logic_vector(1 downto 0 );
	signal	overflow : std_logic;
	signal	zero : std_logic;

begin
-- The Device Under Test (DUT)
	my_alu : entity work.alu(rtl)
    port map(
        x    => x,
        y   => y,
        add_sub  => add_sub,
		func => func,
		output => output,
		logic_func => logic_func,
		overflow => overflow,
		zero => zero);

    -- Testbench sequence
    process is
    begin
	
	-- 	2's complement representation
		
	--	Output y	
		func <= "00";
		add_sub <= '0';
		
		x <= "00000000000000000001000000000000"; -- 4096
		y <= "00000000000000010011010000111101"; -- 78909
		wait for 10 ns;	

	--  Check MSB
		func <= "01";
		wait for 10 ns;	
				
	--	Adding a positive integer with a negative integer
		func <= "10";
		x <= "01111101001010110111010100000000"; -- +2 100 000 000
		y <= "10001000110010100110110000010100"; -- -1 999 999 980
		wait for 10 ns;	
		
	--  Check MSB
		func <= "01";
		wait for 10 ns;	
		
	--	Adding 2 positive integers; expecting overflow
		func <= "10";
		x <= "01111101001010110111010100000000"; -- 2 100 000 000
		y <= "01110111001101011001001111111111"; -- 1 999 999 999
		wait for 10 ns;	
        		
		
		add_sub <= '1';
	--  Substracting a positive integer from a positive integer 
		x <= "00000000000000000000111110100000"; -- 4000
		y <= "00000000000000000000100011111100"; -- 2300
		wait for 10 ns;	

	--  Substracting a negative integer from a negative integer;
		x <= "11111111111111111111111111000000"; -- -64
		y <= "11111111111111111111111001101010"; -- -406
		wait for 10 ns;	
		
	--  Substracting a positive integer from a positive integer; expecting zero
		x <= "00000000000000000000111110100000"; -- 4000
		y <= "00000000000000000000111110100000"; -- 4000
		wait for 10 ns;

	--  Substracting a positive integer from a positive integer; expecting underflow
		x <= "00000000000000000000001111101000"; -- 1000
		y <= "00000000000000000001001110001000"; -- 5000
		wait for 10 ns;	
		
	--------------------------------------------------------		
	--------------------------------------------------------	
	
	--	Logic AND
		logic_func <= "00";
		x <= "00000000000000000000000010000000"; -- 128
		y <= "00000000000000000000000010000000"; -- 128
        func <= "11";
		wait for 10 ns;	
		
	--	Logic OR
		logic_func <= "01";
		x <= "00000000000000000000000010000000"; -- +128
		y <= "11111111111111111111100000000000"; -- -2048
		func <= "11";
		wait for 10 ns;	
		
	--	Logic XOR
		logic_func <= "10";
		x <= "00000000000000000000000010000000"; -- 128
		y <= "00000000000000000000000001000000"; -- 64
		func <= "11";
		wait for 10 ns;	
		
	--	Logic NOR
		logic_func <= "11";
		x <= "00000000000000000000001000101011"; -- +555
		y <= "11111111111111111111111111101100"; -- -20
		func <= "11";
		wait for 10 ns;			
		
    end process;
 
end architecture;