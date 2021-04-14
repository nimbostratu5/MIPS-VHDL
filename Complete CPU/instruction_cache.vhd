library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;  

entity Instruction_Cache is
port (
 pc: in std_logic_vector(4 downto 0);
 instruction: out  std_logic_vector(31 downto 0)
);
end Instruction_Cache;

architecture arc of Instruction_Cache is
signal get_address: std_logic_vector(4 downto 0);

	--change array size when changing assembly code
 type ROM is array (0 to 4) of std_logic_vector(31 downto 0);
 constant program_data: ROM:=(
 
	-- 00000 addi r1, r0, 1 ; r1 = r0 + 1 = 0 + 1
	-- 00001 addi r2, r0, 2 ; r2 = r0 + 2 = 0 + 2
	-- 00010 there: add r2, r2, r1 ; r2 = r2 + r1 = r2 + 1
	-- 00011 j there ; goto label there
	-- 00100 00000000000000000000000000000000 -- don’t care
   "00100000000000010000000000000001",
   "00100000000000100000000000000010",
   "00000000010000010001000000100000",
   "00001000000000000000000000000010",
   "00000000000000000000000000000000"
  );
begin

 instruction <= program_data(to_integer(unsigned(pc)))(31 downto 0);

end architecture;