library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY bcdto7segment IS
PORT(
    bcd : IN unsigned (3 DOWNTO 0); -- Input digit to display
    dot7segment : OUT std_logic_vector (7 DOWNTO 0)); -- Output (7 segment with decimal (dp))
    -- In the 8 bits of the output, the 7 most significant ones are for the 7 segments
    -- The least significant bit is for the decimal 
END bcdto7segment;

ARCHITECTURE ARCH1 OF bcdto7segment IS
BEGIN

PROCESS (bcd) BEGIN
    CASE bcd is
        -- Here, 0 in a segment means light the segment, and 1 means do not light
        -- The decimal is by default, turned off
        -- It will be turned on at regular intervals by the clock
        -- These are the corresponding displays for digits 0-9
        WHEN "0000" => dot7segment <= "00000011";
        WHEN "0001" => dot7segment <= "10011111";
        WHEN "0010" => dot7segment <= "00100101";
        WHEN "0011" => dot7segment <= "00001101";
        WHEN "0100" => dot7segment <= "10011001";
        WHEN "0101" => dot7segment <= "01001001";
        WHEN "0110" => dot7segment <= "01000001";
        WHEN "0111" => dot7segment <= "00011111";
        WHEN "1000" => dot7segment <= "00000001";
        WHEN "1001" => dot7segment <= "00001001";

        -- When a trash value is given, turn off all the segments
        WHEN OTHERS => dot7segment <= "11111111";
    END CASE;
END PROCESS;

END ARCH1;