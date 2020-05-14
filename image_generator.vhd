library ieee;
use ieee.std_logic_1164.all;

entity image_generator is

	generic(
	
		Ha: integer := 96;
		Hb: integer := 144;
		Hc: integer := 784;
		Hd: integer := 800;
		Va: integer := 2;
		Vb: integer := 35;
		Vc: integer := 515;
		Vd: integer := 525;
		PVsize: integer := 50;
		PHsize: integer := 10;
		BallSize: integer := 50);
	
	port(
		pixel_clk 		  : in std_logic;
		paddle_clk		  : in std_logic;
		ball_clk			  : in std_logic;
		reset				  : in std_logic;
		Hactive, Vactive : in std_logic;
		Hsync, Vsync     : in std_logic;
		dena		 		  : in std_logic;
		direction_switch : in std_logic_vector(3 downto 0);
		start_game		  : in std_logic;
		score1			  : buffer integer;
		score2			  : buffer integer;
		R,G,B				  : out std_logic_vector(3 downto 0));
		
end image_generator;


architecture image_generator_arch of image_generator is

	--Pixel counters

	signal row_counter : integer range 0 to Vc;
	signal col_counter : integer range 0 to Hc;
	
	--Paddle positions
	
	signal paddle1_pos_x	 : integer range 0 to Hc;
	signal paddle2_pos_x	 : integer range 0 to Hc;
	signal paddle1_pos_y	 : integer range 0 to Vc;
	signal paddle2_pos_y	 : integer range 0 to Vc;
	
	--Position and direction of the ball
	
	signal Ball_pos_x		 : integer range 0 to Hc;
	signal Ball_pos_y		 : integer range 0 to Vc;
	signal Ball_direction : integer range 0 to 5;
	
	--States of the game
	type state_type is (S0, S1);
	signal state: state_type;
	signal move: std_logic;
	
	
begin

	--Pixel counters to represent the image-----------
	
	process(pixel_clk, Hactive, Vactive, Hsync, Vsync)
	
	begin
	
		if(reset = '0') then
		
			row_counter <= 0;
			
		elsif(Vsync = '0') then
		
			row_counter <= 0;
			
		elsif(Hsync'event and Hsync = '1') then
					
			if(Vactive = '1') then
			
				row_counter <= row_counter + 1;
				
			end if;
			
		end if;
		
		if(reset = '0') then
			
			col_counter <= 0;
			
		elsif(Hsync = '0') then
			
			col_counter <= 0;
			
		elsif(pixel_clk'event and pixel_clk = '1') then
		
			if(Hactive = '1') then
				
				col_counter <= col_counter + 1;
				
			end if;
			
		end if;
		
	end process;
	
	---Paddle movements--------------------------------
	
	process(paddle_clk, reset, direction_switch)
	
	begin
	
		if(reset = '0') then
			paddle1_pos_X <= 50;
			paddle1_pos_y <= 240;
			
			paddle2_pos_x <= 590;
			paddle2_pos_y <= 240;
			
		elsif(paddle_clk'event and paddle_clk = '1') then
		
			paddle1_pos_x <= 50;
			paddle2_pos_x <= 590;
			
			--Movement paddle 1
			
			if(direction_switch(0) = '1') then
				if(paddle1_pos_y = Vc - Vb) then
					paddle1_pos_y <= 0;
				else paddle1_pos_y <= paddle1_pos_y + 1;
				end if;
			end if;
			
			if(direction_switch(1) = '1') then
				if(paddle1_pos_y = 0) then
					paddle1_pos_y <= Vc - Vb;
				else paddle1_pos_y <= paddle1_pos_y - 1;
				end if;
			end if;
			
			--Movement paddle 2
			
			if(direction_switch(2) = '1') then
				if(paddle2_pos_y = Vc - Vb) then
					paddle2_pos_y <= 0;
				else paddle2_pos_y <= paddle2_pos_y + 1;
				end if;
			end if;
			
			if(direction_switch(3) = '1') then
				if(paddle2_pos_y = 0) then
					paddle2_pos_y <= Vc - Vb;
				else paddle2_pos_y <= paddle2_pos_y - 1;
				end if;
			end if;
			
		end if;
		
	end process;
	
	---Position and direction of the ball-----------
	
	process(ball_clk, reset, Ball_direction, move)
	
	begin
	
		if(reset = '0' or move = '0') then
			Ball_pos_x <= 320;
			Ball_pos_y <= 240;
			
			Ball_direction <= Ball_direction + 1;
					if(Ball_direction > 5) then
						Ball_direction <= 0;
					end if;
		
		elsif(ball_clk'event and ball_clk = '1') then
			
			case Ball_direction is
			
				-- Direcciones, 6 en total, 4 diagonales y 2 horizontales
				
				when 0 => Ball_pos_x <= Ball_pos_x + 1;
							 Ball_pos_y <= Ball_pos_y - 1;
				when 1 => Ball_pos_x <= Ball_pos_x - 1;
							 Ball_pos_y <= Ball_pos_y - 1;
				when 2 => Ball_pos_x <= Ball_pos_x - 1;
							 Ball_pos_y <= Ball_pos_y + 1;
				when 3 => Ball_pos_x <= Ball_pos_x + 1;
						    Ball_pos_y <= Ball_pos_y + 1;
				when 4 => Ball_pos_x <= Ball_pos_x + 1;
				when 5 => Ball_pos_x <= Ball_pos_x - 1;
			end case;
			
			--Bounce with the board edges
			if(Ball_pos_y = 0) then
				
				if(Ball_direction = 0) then
					Ball_direction <= 3;
				elsif(Ball_direction = 1) then
					Ball_direction <= 2;
				end if;
			end if;
			
			if(Ball_pos_y = 480) then
				
				if(Ball_direction = 2) then
					Ball_direction <= 1;
				elsif(Ball_direction = 3) then
					Ball_direction <= 0;
				end if;
			end if;
			
			if(Ball_pos_x = 0) then
				
				if(Ball_direction = 1) then
					Ball_direction <= 0;
				elsif(Ball_direction = 2) then
					Ball_direction <= 3;
				elsif(Ball_direction = 5) then
					Ball_direction <= 4;
				end if;
			end if;
			
			if(Ball_pos_x = 640) then
				
				if(Ball_direction = 0) then
					Ball_direction <= 1;
				elsif(Ball_direction = 3) then
					Ball_direction <= 2;
				elsif(Ball_direction = 4) then
					Ball_direction <= 5;
				end if;
			end if;
			
			--Bounces with the paddles
			
			if(Ball_pos_x + BallSize > paddle2_pos_x - PHsize) then
					if(Ball_pos_y - BallSize <= paddle2_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle2_pos_y - PVsize) then
						
						if(Ball_pos_y >= paddle2_pos_y - 10 and
							Ball_pos_y <= paddle2_pos_y + 10) then
								Ball_direction <= 5;
						else
							
							if(Ball_direction = 0) then
								Ball_direction <= 1;
								
							elsif(Ball_direction = 3) then
								Ball_direction <= 2;
							
							elsif(Ball_direction = 4) then
								if(Ball_pos_y > paddle2_pos_y) then
									Ball_direction <= 2;
								else
									Ball_direction <= 1;
								end if;
							end if;
						end if;
					end if;
			end if;
			
			if(Ball_pos_x - BallSize < paddle1_pos_x + PHsize) then
					if(Ball_pos_y - BallSize <= paddle1_pos_y + PVsize and
						Ball_pos_y + BallSize >= paddle1_pos_y - PVsize) then
						
						if(Ball_pos_y >= paddle1_pos_y - 10 and
							Ball_pos_y <= paddle1_pos_y + 10) then
								Ball_direction <= 4;
						else
							
							if(Ball_direction = 1) then
								Ball_direction <= 0;
								
							elsif(Ball_direction = 2) then
								Ball_direction <= 3;
							
							elsif(Ball_direction = 5) then
								if(Ball_pos_y > paddle1_pos_y) then
									Ball_direction <= 3;
								else
									Ball_direction <= 0;
								end if;
							end if;
						end if;
					end if;
			end if;
			
		
		end if;
		
	end process;
	
	---State Machine of the game-----------------
	process(pixel_clk, reset)
	begin
	
		if(reset = '0') then
			state <= S0;
			score1 <= 0;
			score2 <= 0;
		
		elsif(pixel_clk'event and pixel_clk = '1') then
			case state is
				when S0 =>
					if(start_game = '0') then
						State <= S1;
					end if;
				when S1 =>
					if(Ball_pos_x < 40) then
						State <= S0;
						if(score2 = 4) then
							score2 <= 0;
							score1 <= 0;
						else
							score2 <= score2 + 1;
						end if;
					end if;
					if(Ball_pos_x > 600) then
						State <= S0;
						if(score1 = 4) then
							score1 <= 0;
							score2 <= 0;
						else
							score1 <= score1 + 1;
						end if;
					end if;
					
			end case;
		end if;
	end process;
	
	process(State)
	begin
	case State is
		when S0 => move <= '0';
		when S1 => move <= '1';
	end case;
	end process;
	
	---Image generator--------------------
	
	process(paddle1_pos_x, paddle1_pos_y, paddle2_pos_x, paddle2_pos_y, dena, row_counter, col_counter)
	
	begin
		
		--Signal that enables to display data on the screen
		if(dena = '1') then
		
				 -- Paddle 1 detection
			 if((paddle1_pos_x <= col_counter + PHsize) and
				(paddle1_pos_x + PHsize >= col_counter) and
				(paddle1_pos_y <= row_counter + PVsize) and
				(paddle1_pos_y + PVsize >= row_counter)) or
				
				 -- Paddle 2 detection
				((paddle2_pos_x <= col_counter + PHsize) and
				(paddle2_pos_x + PHsize >= col_counter) and
				(paddle2_pos_y <= row_counter + PVsize) and
				(paddle2_pos_y + PVsize >= row_counter)) or
				
				 -- Ball detection
				((Ball_pos_x <= col_counter + BallSize) and
				(Ball_pos_X + BallSize >= col_counter) and
				(Ball_pos_y <= row_counter + BallSize) and
				(Ball_pos_y + BallSize >= row_counter))	then
				
					-- Paddle and ball color
					
					R <= "1111";
					G <= "1111";
					B <= "1111";
				
			else
				
					-- Background color
			
					R <= "0000";
					G <= "0000";
					B <= "0000";
				
			end if;
			
		else
		
			-- If dena = 0, no color has to be displayed
		
			R <= (others => '0');
			G <= (others => '0');
			B <= (others => '0');
			
		end if;
		
	end process;

end image_generator_arch;
			

	
