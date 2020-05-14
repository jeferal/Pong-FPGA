library ieee;
use ieee.std_logic_1164.all;

--Entity to get a fraction of the fundamental clock frequency

entity div_gen is

	generic( div 	      : integer:= 2);
	port( 	clk_in, reset : in std_logic;
				clk_out: out std_logic);
			
end div_gen;

architecture div_gen_arch of div_gen is

		signal Qt : integer range 0 to ((div/2)-1);
		signal temp: std_logic;

begin

	process(clk_in, reset)
		
	begin
		
		if(reset = '0') then 
			Qt <= 0;
			temp  <= '0';
			
		elsif(clk_in'event and clk_in = '1') then
			
			if(Qt = ((div/2)-1)) then
					  temp<= not temp;
					  Qt <= 0;
			else
					  Qt <= Qt+1;
			end if;
		end if;
	end process;
	
	clk_out <= temp;
	
end div_gen_arch;
