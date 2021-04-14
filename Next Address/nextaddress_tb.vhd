library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
 
entity nextaddress_tb is
end entity;
 
architecture sim of nextaddress_tb is

signal rt, rs :  std_logic_vector(31 downto 0);
-- two register inputs
signal pc :  std_logic_vector(31 downto 0);
signal target_address :  std_logic_vector(25 downto 0);
signal branch_type :  std_logic_vector(1 downto 0);
signal pc_sel :  std_logic_vector(1 downto 0);
signal next_pc : std_logic_vector(31 downto 0);
 


begin
-- The Device Under Test (DUT)
	my_nextaddress : entity work.next_address(arc)
    port map(
	
        rt => rt,
        rs => rs,
        pc => pc,
		target_address => target_address,
		branch_type => branch_type,
		pc_sel => pc_sel,
		next_pc => next_pc);
		
    -- Testbench sequence
    process is
    begin
	
		pc <= "00000000000000000000000000000000";
		rt <= "00000000000000000000100011111100"; -- 2300
		rs <= "00000000000000000000100011111100"; -- 2300
		target_address <= "00000000000000001111101000"; -- 1000
		branch_type <= "01"; -- beq
		pc_sel <= "01";
		wait for 10 ns;
	
		for I in 0 to 3 loop
		
			pc <= next_pc;
			wait for 10 ns;	
			
		end loop;
			
	
    end process;
 
end architecture;