library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity alu is
port(

x, y : in std_logic_vector(31 downto 0); -- two input operands

add_sub : in std_logic; -- 0 = add , 1 = sub

logic_func : in std_logic_vector(1 downto 0 ); -- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR

func : in std_logic_vector(1 downto 0 );-- 00 = lui, 01 = setless , 10 = arith , 11 = logic

output : out std_logic_vector(31 downto 0);

overflow : out std_logic ;

zero : out std_logic);


end alu;


architecture rtl of alu is

	signal addsub_out : std_logic_vector(31 downto 0);
	signal MSB : std_logic_vector(31 downto 0);
	signal logic_out : std_logic_vector(31 downto 0);
	signal y_in : std_logic_vector(31 downto 0);
	signal y_in2 : std_logic_vector(31 downto 0);
	signal x_in2 : std_logic_vector(31 downto 0);

begin
	--ADDER_SUBSTRACT UNIT
	process(add_sub,x,y) is
	   begin

	    y_in <= y;
	    
	    if (add_sub = '0') then
		
			addsub_out <= x + y_in;
			
		elsif (add_sub = '1') then
		    
		    --if(y(3) = '1') then
		    	y_in <= not(y) + '1';	      
		      addsub_out <= x + y_in;
		      
		   -- else
		      
		      --addsub_out <= x - y;
		      
		    --end if; 		    
		    
		end if;
		
		MSB <= (others => '0');
		if( (x(31) ='1') AND (y(31) = '0')) then
		  MSB(0) <= '1';
		elsif((x(31) ='0') AND (y(31) = '1')) then
		  MSB(0) <= '0';
		elsif((x(31) ='0') AND (y(31) = '0')) then
		  if(x < y) then
		      MSB(0) <= '1';
		  else
		      MSB(0) <= '0';
		  end if;
		elsif((x(31) ='1') AND (y(31) = '1')) then
		  y_in2 <= not(y) + '1';
          x_in2 <= not(x) + '1';
          
          if(x > y) then
              MSB(0) <= '1';
          else
              MSB(0) <= '0';
          end if;
          
		end if;
					
	end process;
	
	--LOGIC UNIT
	process(logic_func,x,y) is
		begin
		
		if (logic_func = "00") then
			logic_out <= x AND y;
		elsif (logic_func = "01") then
			logic_out <= x OR y;
		elsif (logic_func = "10") then
			logic_out <= x XOR y;
		elsif (logic_func = "11") then
			logic_out <= x NOR y;
		end if;
					
	end process;
	
	--ZERO AND OVERFLOW DETECTION UNIT
	process(addsub_out,add_sub,x,y) is 
		begin
		--ADDING 2 POSITIVE/NEGATIVE NUMBERS OVERFLOW CHECK
		if ( (x(31) = '0') AND (y(31)= '0')) then
		     if( addsub_out(31) = '1') then
		          overflow <= '1';
		     else
		          overflow <= '0';
             end if;
        elsif ((x(31) = '1') AND (y(31) = '1')) then
          
             if( addsub_out(31) = '0') then
                 overflow <= '1';
             else
                 overflow <= '0';
             end if; 
       end if;

		--ZERO DETECTED
		if (addsub_out = "00000000000000000000000000000000") then
		  zero <= '1';
		else
		  zero <= '0';
		end if;
	
	end process;
		
	--OUTPUT SELECTOR
	with func select
	
	output <= y when "00",
		  MSB when "01",
	      addsub_out when "10",
		  logic_out when "11",
	      (others => '0') when others;

end architecture;
