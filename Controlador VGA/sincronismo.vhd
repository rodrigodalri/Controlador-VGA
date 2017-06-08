library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;


entity sincronismo is

	Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   port( signal Clock, Resetn : in std_logic;
			signal video_on : out std_logic;
			signal Pixels,Linha : out std_logic_vector(10 downto 0);
			signal Horiz_sync,Vert_sync : out std_logic);
       
end sincronismo;

architecture comportamento of sincronismo is

	signal cont_x,cont_y: std_logic_vector(10 Downto 0);
	signal RESET : std_logic;
	constant H_max : std_logic_vector(10 Downto 0) := CONV_STD_LOGIC_VECTOR(1588,11); 
	--valor maximo da variavel cont_x, valor encontrado a partir da analise dos tempos do sincronismo horizontal
	constant V_max : std_logic_vector(10 Downto 0) := CONV_STD_LOGIC_VECTOR(528,11); 
	--valor maximo da variavel cont_y, valor encontrado a partir da analise dos tempos do sincronismo vertical
	signal video_on_H, video_on_V: std_logic;

begin           

	RESET <= NOT(resetn);
	video_on <= video_on_H and video_on_V;

	--Generate Horizontal and Vertical Timing Signals for Video Signal
	VIDEO_DISPLAY: Process
		Begin

		Wait until(Clock'Event) and (Clock='1');

		If 
			Reset = '1' Then
			cont_x <= CONV_STD_LOGIC_VECTOR(0,11);
			cont_y <= CONV_STD_LOGIC_VECTOR(0,11);
			Video_on_H <= '0';
			Video_on_V <= '0';
		Else

			-- cont_x conta os pixels (espaco utilizado+espaco nao utilizado+tempo extra para o sinal de sincronismo)
			--
			--  Contagem de Pixels:
			--   												  <-H Sync->
			--   ------------------------------------__________
			--   0        511 -espaco nao utilizado-  1400     


			 If (cont_x >= H_max) then
				cont_x <= "00000000000";
			 Else
				cont_x <= cont_x + "00000000001";
			 End if;

			-- O Horiz_Sync deve permanecer em nivel logico alto por 27,06 us
			-- entao em baixo por 3,77 us
			
			
			 If (cont_x <= 1494) and (cont_x >= 1306) Then
					Horiz_Sync <= '0';
			 ELSE
					Horiz_Sync <= '1';
			 End if;
			 
			-- Ajusta o tempo do Video_on_H
			 If (cont_x <= 1258) Then  
				video_on_H <= '1';
			 ELSE
				video_on_H <= '0';
			 End if;

			--  Contagem de linhas...
			--Linha conta as linhas de pixels (127 + tempo extra para sinais de sincronismo)
			--
			--  <--128 linhas utilizadas -->                  ->V Sync<-
			--  -----------------------------------------------_______------------
			--  0                          127           495-494               528
			--

			 If (cont_y >= V_max) and (cont_x >= 736) then
					cont_y <= "00000000000";
			 Elsif (cont_x = H_Max) Then
					  cont_y <= cont_y + "00000000001";
			 End if;

			-- Generate Vertical Sync Signal
			 If (cont_y <= 496) and (cont_y >= 495) Then   
				Vert_Sync <= '0';
			 ELSE
				Vert_Sync <= '1';
			 End if;
			 
			-- Ajusta o tempo do Video_on_V
			If (cont_y <= 479) Then
				video_on_V <= '1';
			ELSE
				video_on_V <= '0';
			End if;
			
		End if; -- Termina o IF do Reset

		Linha 	<= cont_y;
		Pixels 	<= "0" & cont_x(10 downto 1); 
				-- Utilizo cont_x descartandando o ultimo bit para dividir por 2 a frequencia
            -- De forma com que o clock seja semelhante ao do monitor.

		end process VIDEO_DISPLAY;

end comportamento;

