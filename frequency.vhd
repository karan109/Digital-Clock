library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY frequency IS
PORT(
	clk_in : IN bit;
	number : IN integer;
	new_clk : OUT bit);
END frequency;

ARCHITECTURE ARCH OF frequency IS
SIGNAL counter : integer := 0;
BEGIN

PROCESS (clk_in) BEGIN
	IF number = 1 THEN new_clk <= clk_in;
	ELSE
		IF clk_in = '1' AND clk_in'EVENT THEN
			IF counter + 1 = number THEN
				counter <= 0; new_clk <= '1';
			ELSE counter <= counter + 1; new_clk <= '0';
			END IF;
		END IF;
	END IF;
END PROCESS;

END ARCH;
