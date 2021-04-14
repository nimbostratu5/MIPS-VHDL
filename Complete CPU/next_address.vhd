library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity next_address is

port(rt, rs : in std_logic_vector(31 downto 0);
-- two register inputs
pc : in std_logic_vector(31 downto 0);
target_address : in std_logic_vector(25 downto 0);
branch_type : in std_logic_vector(1 downto 0);
pc_sel : in std_logic_vector(1 downto 0);
next_pc : out std_logic_vector(31 downto 0));

end next_address ;

architecture arc of next_address is

	signal rs_in, rt_in : unsigned(31 downto 0);
	signal branch_address : std_logic_vector(31 downto 0); --
	signal branch_flag : std_logic;
	signal extended_rs : std_logic_vector(31 downto 0);
	signal extended_taddress : std_logic_vector(31 downto 0);
	signal p_counter : std_logic_vector(31 downto 0);
	signal jumpadr : std_logic_vector(31 downto 0);
	signal jumpadr2 : std_logic_vector(31 downto 0);
	--signal next_pc_out : std_logic_vector(31 downto 0);
	--signal pc_in: std_logic_vector(31 downto 0);
	
begin

--Process
process(pc) is

begin
	
	p_counter <= (others => '0');
		
	jumpadr <= (others => '0');
	
	branch_address <= (others => '0');
	branch_address(15 downto 0) <= target_address(15 downto 0);
	
	extended_rs <= (others => '0');
	extended_rs <= rs;
	
	extended_taddress <= (others => '0');
	extended_taddress(25 downto 0) <= target_address;
	
	rs_in <= unsigned(rs);
	rt_in <= unsigned(rt);
	jumpadr(31 downto 0) <= extended_taddress(31 downto 0);
	jumpadr2 <= std_logic_vector(resize(signed(target_address(25 downto 0)), jumpadr2'length));
	if branch_type = "00" then 
	
		p_counter <= pc + "00000000000000000000000000000001";
		
	elsif branch_type = "01" then -- beq
	
		if  (rs_in = rt_in) then
			p_counter <= branch_address + pc + "00000000000000000000000000000001";
		end if;
	
	elsif branch_type = "10" then -- bne
	
		if (rt /= rs) then
			p_counter <= branch_address + pc + "00000000000000000000000000000001";
		end if;
	
	elsif branch_type = "11" then -- bltz
	
		if rs(31) = '1' then
			p_counter <= branch_address + pc + "00000000000000000000000000000001";
		end if;
		
	end if;

end process;

--OUTPUT SELECTOR

with pc_sel select
	
	next_pc <=	p_counter when "00",
				jumpadr2 when "01",
				extended_rs when "10",
				(pc+"1") when others;	
				

end architecture;
