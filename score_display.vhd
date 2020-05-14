library ieee;
use ieee.std_logic_1164.all;

--Driver to display the score

entity score_display is

	port(
			score1 : in integer;
			score2 : in integer;
			seg1	 : out std_logic_vector(6 downto 0);
			seg2	 : out std_logic_vector(6 downto 0);
			bar	 : out std_logic);
			
end score_display;

architecture score_display_arch of score_display is

begin

	with score1 select
		seg1 <= "1000000" when 0,
				  "1111001" when 1,
				  "0100100" when 2,
				  "0110000" when 3,
				  "0011001" when 4,
				  "0010010" when others;
	
	with score2 select
		seg2 <= "1000000" when 0,
				  "1111001" when 1,
				  "0100100" when 2,
				  "0110000" when 3,
				  "0011001" when 4,
				  "0010010" when others;
				  
	bar <= '0';
		
end score_display_arch;
