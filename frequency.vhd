library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY frequency IS
PORT(
	clk_in : IN bit; -- Master clock
	number : IN integer; -- Time period intended
	new_clk : OUT bit); -- Output clock
END frequency;

-- This takes the master clock, "clk_in" and an integer, "number" as input and generates 
-- a signal with time period = number * (time period of clock)
ARCHITECTURE ARCH2 OF frequency IS
SIGNAL counter : integer := 0; -- Counter
BEGIN

PROCESS (clk_in) BEGIN
	IF number = 1 THEN new_clk <= clk_in; -- If number is 1, just output the master clock
	ELSE
		IF clk_in = '1' AND clk_in'EVENT THEN
			-- A modulo counter is kept
			-- Caution : This is not a traditional clock in which 0s and 1s are alternated equally
			-- This just creates a step of 1 at the intended time period
			-- This works in my application as only rising edges are detected by me
			IF counter + 1 = number THEN
				counter <= 0; new_clk <= '1';
			ELSE counter <= counter + 1; new_clk <= '0';
			END IF;
		END IF;
	END IF;
END PROCESS;

END ARCH2;
