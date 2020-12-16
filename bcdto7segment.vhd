library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY bcdto7segment IS
PORT(
    bcd : IN unsigned (3 DOWNTO 0);
    dot7segment : OUT std_logic_vector (7 DOWNTO 0));
END bcdto7segment;

ARCHITECTURE ARCH OF bcdto7segment IS
BEGIN

PROCESS (bcd) BEGIN
    CASE bcd is
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
        WHEN OTHERS => dot7segment <= "11111111";
    END CASE;
END PROCESS;

END ARCH;