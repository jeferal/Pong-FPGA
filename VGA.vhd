library ieee;
use ieee.std_logic_1164.all;

entity VGA is

	generic(
	
		div:integer := 2;
		div_paddle : integer := 415000;
		
		div_ball1 : integer := 415000;
		div_ball2 : integer := 370000;
		div_ball3 : integer := 310000;
		div_ball4 : integer := 250000;
	
		Ha: integer := 96;
		Hb: integer := 144;
		Hc: integer := 784;
		Hd: integer := 800;
		Va: integer := 2;
		Vb: integer := 35;
		Vc: integer := 515;
		Vd: integer := 525;
		paddlesizeH: integer := 2;
		paddlesizeV: integer := 30);

	port(
			clk : in std_logic;
			reset: in std_logic;
			
			Hsync, Vsync : buffer std_logic;
			direction_switch: in std_logic_vector(3 downto 0);
			start_game		: in std_logic;
			seg1 	: out std_logic_vector(6 downto 0);
			seg2		: out std_logic_vector(6 downto 0);
			bar		: out std_logic;
			
			ball_speed : in std_logic_vector(1 downto 0);
			
			R, G, B 		 : out std_logic_vector(3 downto 0));

end VGA;



architecture VGA_arch of VGA is

	signal pixel_clk: std_logic;
	signal Hactive, Vactive, dena : std_logic;
	signal paddle_clk, ball_clk, ball_clk1, ball_clk2, ball_clk3, ball_clk4: std_logic;
	signal score1  : integer;
	signal score2  : integer;
	component div_gen is
		
		generic( div 	 : integer:= 2);
		
		port( 	clk_in, reset : in std_logic;
				clk_out: out std_logic);
	
	end component div_gen;
	
	component sync_generator is
	
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
		
	end component sync_generator;
	
	component image_generator is
	
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
		BallSize: integer := 3);
	
	port(
		pixel_clk		: in std_logic;
		paddle_clk		: in std_logic;
		ball_clk     	        : in std_logic;
		reset	     	        : in std_logic;
		Hactive, Vactive 	: in std_logic;
		Hsync, Vsync      	: in std_logic;
		dena		 	: in std_logic;
		direction_switch        : in std_logic_vector(3 downto 0);
		start_game		: in std_logic;
		score1			: out integer;
		score2			: out integer;
		R,G,B		        : out std_logic_vector(3 downto 0));
		
	end component image_generator;
	
	component score_display is
		port(
			score1   : in integer;
			score2   : in integer;
			seg1	 : out std_logic_vector(6 downto 0);
			seg2	 : out std_logic_vector(6 downto 0);
			bar	 : out std_logic);
	end component;
	
	--Pin assignments
	attribute chip_pin : string;
	
	attribute chip_pin of clk	       : signal is "N14";
	attribute chip_pin of reset	       : signal is "F15";
	
	attribute chip_pin of direction_switch : signal is "C10,C11,C12,A12";
	attribute chip_pin of start_game       : signal is "B8";
	
	
	attribute chip_pin of Hsync	       : signal is "N3";
	attribute chip_pin of Vsync	       : signal is "n1";
	
	attribute chip_pin of R		       : signal is "AA1, V1, Y2, Y1";
	attribute chip_pin of G		       : signal is "W1, T2, R2, R1";
	attribute chip_pin of B		       : signal is "P1, T1, P4, N2";
	
	attribute chip_pin of seg1	       : signal is "B22,C22,B21,A21,B19,A20,B20";
 	attribute chip_pin of seg2	       : signal is "C17,D17,E16,C16,C15,E15,C14";
	attribute chip_pin of bar	       : signal is "B17";
	
	attribute chip_pin of ball_speed       : signal is "B14,A14";
			

begin

	U0: div_gen
	 
		generic map (div => div)
		port map		(clk_in => clk, reset => reset, clk_out => pixel_clk);
		
	u1: sync_generator
	
		generic map(Ha => Ha,
						Hb => Hb,
						Hc => Hc,
						Hd => Hd,
						Va => Va,
						Vb => Vb,
						Vc => Vc,
						Vd => Vd)
						
		port map(pixel_clk => pixel_clk,
					reset	=> reset,
					Hsync	=> Hsync,
					Vsync	=> Vsync,
					Hactive	=> Hactive,
					Vactive	=> Vactive,
					dena 	=> dena);
					
	u2: image_generator
	
		generic map(Ha => Ha,
						Hb => Hb,
						Hc => Hc,
						Hd => Hd,
						Va => Va,
						Vb => Vb,
						Vc => Vc,
						Vd => Vd,
						PVsize => paddlesizeV,
						PHsize => paddlesizeH)
		
		port map(		pixel_clk	=> pixel_clk,
					paddle_clk	=> paddle_clk,
					ball_clk	=> ball_clk,
					reset		=> reset,
					Hactive		=> Hactive,
					Vactive 	=> Vactive,
					Hsync		=> Hsync,
					Vsync		=> Vsync,
					dena		=> dena,
					direction_switch=> direction_switch,
					start_game	=> start_game,
					score1		=> score1,
					score2		=> score2,
					R		=> R,
					G		=> G,
					B		=> B);
					
	u3: div_gen
		generic map (div => div_paddle)
		port map		(clk_in => clk, reset => reset, clk_out => paddle_clk);
	
	u5: div_gen
		generic map (div => div_ball1)
		port map		(clk_in => clk, reset => reset, clk_out => ball_clk1);
	
	u6: div_gen
		generic map (div => div_ball2)
		port map		(clk_in => clk, reset => reset, clk_out => ball_clk2);
		
	u7: div_gen
		generic map (div => div_ball3)
		port map		(clk_in => clk, reset => reset, clk_out => ball_clk3);
		
	u8: div_gen
		generic map (div => div_ball4)
		port map		(clk_in => clk, reset => reset, clk_out => ball_clk4);
	
	u4: score_display
		port map		(score1 => score1, score2 => score2, seg1 => seg1, seg2 => seg2, bar => bar);
		
	
	--Multiplexor to choose the speed of the ball
	process(ball_speed)
	begin
		
		case ball_speed is
			when "00" => ball_clk <= ball_clk1;
			when "01" => ball_clk <= ball_clk2;
			when "10" => ball_clk <= ball_clk3;
			when others => ball_clk <= ball_clk4;
		end case;
	end process;
					
					
end VGA_arch;
