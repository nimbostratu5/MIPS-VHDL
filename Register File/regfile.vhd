library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
 
entity regfile is
port(

    din: in std_logic_vector(31 downto 0);
    clk: in std_logic;
    reset: in std_logic; 
    writesig : in std_logic;
	read_b : in std_logic_vector(4 downto 0);
	read_a : in std_logic_vector(4 downto 0);
    write_address : in std_logic_vector(4 downto 0);
    out_a: out std_logic_vector(31 downto 0);
    out_b: out std_logic_vector(31 downto 0));

end regfile;
 
architecture rtl of regfile is

	type memory is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal memory_reg : memory;
	--signal index_a, index_b : integer;
begin

--Register File Process
process(clk, reset) is
variable index_w : integer;
begin

	if reset = '1' then
		
		for j in 0 to 31 loop	
		
	      	memory_reg(31 downto 0)(j) <= (others => '0');
			
		end loop;
		  	  
	elsif (clk'event and clk='1') then 
	
		if(writesig = '1') then
		
			index_w := to_integer(unsigned(write_address));
			memory_reg(31 downto 0)(index_w) <= din; 
			
		end if; 
	end if;
	
end process;

--index_a <= to_integer(unsigned(read_a));
--index_b <= to_integer(unsigned(read_b));

out_a <= memory_reg(31 downto 0)(to_integer(unsigned(read_a)));
out_b <= memory_reg(31 downto 0)(to_integer(unsigned(read_b)));

 
end architecture;


