LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mycpu IS
END mycpu;
 
ARCHITECTURE arc OF mycpu IS 
    
    COMPONENT datapath
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         pc_out : OUT  std_logic_vector(3 downto 0);
         rs_out : OUT  std_logic_vector(3 downto 0);
		 rt_out : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal pc_out : std_logic_vector(3 downto 0);
   signal rs_out : std_logic_vector(3 downto 0);
   signal rt_out : std_logic_vector(3 downto 0);

   constant clk_period : time := 10 ns;
BEGIN

   uut: datapath PORT MAP (
          clk => clk,
          reset => reset,
          pc_out => pc_out,
		  rs_out => rs_out,
		  rt_out => rt_out
        );

   -- Clock process 
   clk_process :process
   begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
   end process;

   stim_proc: process
   begin  
    reset <= '1';
    wait for clk_period*10;
	reset <= '0';
    
    wait;
   end process;

END;