library ieee;
use ieee.std_logic_1164.all;

entity sync_generator is

	generic(
	
		Ha: integer := 96;
		Hb: integer := 144;
		Hc: integer := 784;
		Hd: integer := 800;
		Va: integer := 2;
		Vb: integer := 35;
		Vc: integer := 515;
		Vd: integer := 525);
		
	port(
		pixel_clk: in std_logic;
		reset		: in std_logic;
		Hsync, Vsync: buffer std_logic;
		Hactive, Vactive: buffer std_logic;
		dena : out std_logic);
		
end sync_generator;


architecture sync_generator_arch of sync_generator is


begin


	-- Horizontal signal generator
	
	process(pixel_clk, reset)
		variable Hcount: integer range 0 to Hd;
	begin
	
		if(reset = '0') then
			Hcount := 0;
			
		elsif(pixel_clk'event and pixel_clk = '1') then
			Hcount := Hcount + 1;
			
			if(Hcount = Ha) then
				Hsync <= '1';
				
			elsif(Hcount = Hb) then
				Hactive <= '1';
			
			elsif(Hcount = Hc) then
				Hactive <= '0';
				
			elsif(Hcount = Hd) then
				Hsync <= '0';
				Hcount := 0;
			end if;
		end if;
	end process;
	
	-- Vertical signal generator
	
	process(Hsync, reset)
		variable Vcount: integer range 0 to Vd;
	begin
	
		if(reset = '0') then
			Vcount := 0;
		
		elsif(Hsync'event and Hsync = '1') then
			Vcount := Vcount + 1;
			
			if(Vcount = Va) then
				Vsync <= '1';
			elsif(Vcount = Vb) then
				Vactive <= '1';
			elsif(Vcount = Vc) then
				Vactive <= '0';
			elsif(Vcount = Vd) then
				Vsync <= '0';
				Vcount := 0;
			end if;
		end if;
	end process;
	
	-- Dena generator (enables to diplay on the screen)
	
	dena <= Hactive and Vactive;
	
end sync_generator_arch;
