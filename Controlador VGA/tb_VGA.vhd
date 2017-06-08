library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_VGA is

end entity tb_VGA;

architecture interface of tb_VGA is

signal		clock, resetn		:	std_logic;
signal		red, green, blue	:	std_logic_vector (3 downto 0);
signal		Hsync, Vsync		:	std_logic;
signal		true					:	std_logic;

begin
uut:  entity work.VGA
port map
	(
		 clock, resetn,
		red, green, blue,
		Hsync, Vsync	
	);
	
	
geraclock:
process
begin
	
		clock <= '0';	-- Na partida, zera sinal de clock...
		wait for 10ns;
		
		-- Agora, comeca a oscilar:
		for cont in 0 to 3600000 loop
			clock <= not clock;		
			wait for 10 ns;
		end loop;
		wait;	-- Parando este processo...
	
end process;

comportamento:
process
	begin
		true <= '1';
		
		RESETn <= '0';
			
		wait for 50 ns;

		RESETn <= '1';

		wait for 300 us;

		true <= '0';

		wait;

end process;


end architecture interface;
