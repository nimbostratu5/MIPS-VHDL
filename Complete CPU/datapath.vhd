library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use ieee.numeric_std.all;

entity datapath is

port(
reset : in std_logic;
clk : in std_logic;
rs_out, rt_out : out std_logic_vector(3 downto 0);
-- output ports from register file
pc_out : out std_logic_vector(3 downto 0); -- pc reg
overflow, zero : out std_logic);

end datapath ;

architecture arc of datapath is
--control signals
signal reg_write: std_logic;
signal reg_dst : std_logic;
signal reg_in_src : std_logic;
signal alu_src : std_logic;
signal add_sub : std_logic;
signal data_write : std_logic;

signal logic_func : std_logic_vector(1 downto 0);
signal func  : std_logic_vector(1 downto 0);
signal branch_type :std_logic_vector(1 downto 0);
signal pc_sel : std_logic_vector(1 downto 0);

--data signals
signal opcode : std_logic_vector(5 downto 0);
signal pc_1: std_logic_vector(31 downto 0);
signal instruction_fetch : std_logic_vector(31 downto 0);
signal alu_out: std_logic_vector(31 downto 0);
signal din : std_logic_vector(31 downto 0); -- out_b which is register rt
type RAM is array (0 to 31) of std_logic_vector(31 downto 0);
signal data_cache_memory : RAM;
signal data_access_check : std_logic; -- for data_cache_memory

signal reg1_address : std_logic_vector(4 downto 0); --rs
signal reg2_address : std_logic_vector(4 downto 0); --rt
signal reg3_address : std_logic_vector(4 downto 0); --rd

signal reg1_data : std_logic_vector(31 downto 0);
signal reg2_data : std_logic_vector(31 downto 0);
signal reg3_data : std_logic_vector(31 downto 0);

signal reg_dest : std_logic_vector(4 downto 0);

signal aluin2 : std_logic_vector(31 downto 0);

signal dout : std_logic_vector(31 downto 0);

signal instr_func : std_logic_vector(5 downto 0);
signal sign_extended : std_logic_vector(31 downto 0);
signal jump_adr : std_logic_vector(25 downto 0);

signal zero_flag : std_logic;
signal overflow_flag : std_logic;

signal next_pc : std_logic_vector(31 downto 0);

begin


-- PC Register
process(reset,clk) is
begin

	if reset = '1' then	
		pc_1 <= (others => '0');	
	elsif (clk'event and clk='1') then 
		pc_1 <= next_pc;
	end if;

end process;

-- Instruction Cache
Instruction_Cache : entity work.Instruction_Cache
port map(
	pc => pc_1(4 downto 0),
	instruction => instruction_fetch
);

opcode <= instruction_fetch(31 downto 26); -- opcode
reg1_address <= instruction_fetch(25 downto 21); --rs
reg2_address <= instruction_fetch(20 downto 16); --rt
reg3_address <= instruction_fetch(15 downto 11); --rd
instr_func <= instruction_fetch(5 downto 0); --for alu
sign_extended <= std_logic_vector(resize(signed(instruction_fetch(15 downto 0)), sign_extended'length));
jump_adr <= instruction_fetch(25 downto 0); 

-- mux for register destination between rt (2) and rd (3)
reg_dest <= reg2_address when reg_dst = '0' else reg3_address;

-- Register File
regfile : entity work.regfile
port map(
	din => din,
    clk => clk,
    reset => reset,
    writesig => reg_write,
	read_b => reg2_address,
	read_a => reg1_address,
    write_address => reg_dest,
    out_a => reg1_data,
    out_b => reg2_data
);

--(mux) y input for alu
aluin2 <= reg2_data when alu_src = '0' else sign_extended;

-- ALU
alu : entity work.alu
port map(
x => reg1_data,
y => aluin2,
add_sub => add_sub, -- 0 = add , 1 = sub
logic_func => logic_func, -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
func => func,-- 00 = lui, 01 = setless , 10 = arith , 11 = logic
output => alu_out,
overflow => overflow_flag,
zero => zero_flag
);


-- Data Cache
process(reset,clk,data_write) is
begin
	--alu_out(4 downto 0) to get the address 
	dout <= data_cache_memory(to_integer(unsigned(alu_out(4 downto 0))))(31 downto 0);
	if reset = '1' then	
	
		for j in 0 to 4 loop	
	      	data_cache_memory(j)(31 downto 0) <= (others => '0');
		end loop;
		dout <= (others => '0');
	elsif (clk'event and clk='1') then 
	
		if(data_write = '1') then --write into data cache mem
		
			data_cache_memory(to_integer(unsigned(alu_out(4 downto 0))))(31 downto 0) <= din; 
		
		end if;
			
	end if;

end process;

--(mux) din from alu or from data_cache_memory
din <= dout when reg_in_src = '0' else alu_out;

-- Control Unit 
process(reset, opcode) is 
begin

if(reset = '1') then

	reg_write <= '0';
	reg_dst  <= '0';
	reg_in_src <= '0';
	alu_src  <= '0';
	add_sub  <= '0';
	data_write  <= '0';

	logic_func  <= "00";
	func   <= "00";
	branch_type <= "00";
	pc_sel  <= "00";
	
 else 
 
	case opcode is
	
		when "001111" => -- lui
		
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "000000" => -- check func of instruction 
		
			case instr_func is
			
				when "100000" => -- add
				
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '0';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "10";
					branch_type <= "00";
					pc_sel  <= "00";
				
				
				when "100010" => -- sub
				
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "10";
					branch_type <= "00";
					pc_sel  <= "00";
				
				when "101010" => -- slt
				
								
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "01";
					branch_type <= "00";
					pc_sel  <= "00";
				
				when "100100" => -- and
				
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "11";
					branch_type <= "00";
					pc_sel  <= "00";
				
				when "100101" => -- or
								
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "01";
					func   <= "11";
					branch_type <= "00";
					pc_sel  <= "00";
				
				when "100110" => -- xor
								
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "10";
					func   <= "11";
					branch_type <= "00";
					pc_sel  <= "00";
				
				when "100111" => -- xnor
				
								
					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '1';
					alu_src  <= '0';
					add_sub  <= '1';
					data_write  <= '0';

					logic_func  <= "11";
					func   <= "11";
					branch_type <= "00";
					pc_sel  <= "00";
					
				when "001000" => -- jr
								
					reg_write <= '0';
					reg_dst  <= '0';
					reg_in_src <= '0';
					alu_src  <= '0';
					add_sub  <= '0';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "00";
					branch_type <= "00";
					pc_sel  <= "01";
					
				when others =>   

					reg_write <= '1';
					reg_dst  <= '1';
					reg_in_src <= '0';
					alu_src  <= '0';
					add_sub  <= '0';
					data_write  <= '0';

					logic_func  <= "00";
					func   <= "00";
					branch_type <= "11";
					pc_sel  <= "00";
				
			end case;
				
		when "001000" => -- addi
								
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "10";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "001010" => --slti
										
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '1';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "01";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "001100" => --andi
								
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "11";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "001101" => --ori
								
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "01";
			func   <= "11";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "001110" => --xori
										
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '1';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "10";
			func   <= "11";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "100011" => --lw
										
			reg_write <= '1';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "10";
			func   <= "10";
			branch_type <= "00";
			pc_sel  <= "00";
		
	    when "101011" => --sw
										
			reg_write <= '0';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '1';
			add_sub  <= '0';
			data_write  <= '1';

			logic_func  <= "10";
			func   <= "10";
			branch_type <= "00";
			pc_sel  <= "00";
		
		when "000010" => --j
										
			reg_write <= '0';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '0';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "00";
			pc_sel  <= "01";
		
		when "000001" => --bltz
		
			reg_write <= '0';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '0';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "11";
			pc_sel  <= "00";
		
		when "000100" => --beq
		
			reg_write <= '0';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '0';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "01";
			pc_sel  <= "00";
		
		when "000101" => --bne
				
			reg_write <= '0';
			reg_dst  <= '0';
			reg_in_src <= '0';
			alu_src  <= '0';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "10";
			pc_sel  <= "00";
	
		when others =>   

			reg_write <= '1';
			reg_dst  <= '1';
			reg_in_src <= '0';
			alu_src  <= '0';
			add_sub  <= '0';
			data_write  <= '0';

			logic_func  <= "00";
			func   <= "00";
			branch_type <= "11";
			pc_sel  <= "00";
			
	 end case;
 end if;
end process;

next_address : entity work.next_address
port map(
rt => reg2_data,
rs => reg1_data,
pc => pc_1,
target_address => jump_adr,
branch_type => branch_type,
pc_sel => pc_sel,
next_pc => next_pc
);

pc_out <= pc_1(3 downto 0);
rs_out <= reg1_data(3 downto 0);
rt_out <= reg2_data(3 downto 0);

end architecture;