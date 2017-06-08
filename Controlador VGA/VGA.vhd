library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;


entity VGA is

   port( 
      clock, resetn		:	in std_logic;
		red, green, blue	:	out std_logic_vector (3 downto 0);
		Hsync, Vsync		:	out std_logic

	);
end entity VGA;

architecture comportamento of VGA is
	signal address: std_logic_vector(14 downto 0);
	signal Pixels,Linha : std_logic_vector(10 downto 0);
	signal RGB, RGB_temp: std_logic_vector(11 downto 0);
	signal video_on: std_logic;

	component memoriavideo
		PORT
		(
			address				: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
			clock					: IN STD_LOGIC;
			q						: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
		);
	end component memoriavideo;

	component sincronismo
		PORT
			( 
					Clock, Resetn				:	in std_logic;
					Video_on						:	out std_logic;		
					Pixels,Linha 				: out std_logic_vector(10 downto 0);
					Horiz_sync,Vert_sync 	: out std_logic       
			);
	end component sincronismo;

	begin
	
		memoriavideo_inst : memoriavideo PORT MAP (
				address	 => address,
				clock	 => clock,
				q	 => RGB_temp
			);
			
		sincronismo_inst : sincronismo port map (
				clock => clock,
				Resetn => resetn,
				Video_on => Video_on,
				Pixels => Pixels,
				Linha => Linha,
				Horiz_sync => Hsync,
				Vert_sync => Vsync
		);
		
	Cores:process (clock,RGB,Video_on)
		begin
			if (Video_on = '0') Then
				red	<=	"0000";
				green	<=	"0000";
				blue <= "0000";				
			
			else
				red 	<=	RGB(11 downto 8);
				green	<=	RGB( 7 downto 4);
				blue	<=	RGB( 3 downto 0);
			end if;			
		end Process Cores;
		
		Enderecamento: process(Linha,Pixels,clock)
			begin
			
				Address <= NOT Linha(6 downto 0) & Pixels(7 downto 0); 
				-- Enviando enderecos para a memoria:
				if (Pixels <= 255) and (Linha <= 127) then
				-- utilizo pixels de 8 ate 1 descartandando o ultimo bit.
				--	isso divide a frequencia por 2 de forma com que o clock seja semelhante ao do monitor.
					RGB <= RGB_temp;
				else
					RGB <= "000000000000";
				end if;
			end Process Enderecamento;

end comportamento;

