library ieee;
use ieee.std_logic_1164.all;

entity clock_tb is
end entity;

architecture Behavioural of clock_tb is

    constant c_WAIT : time := 1 fs;

    signal r_input_b1 : bit := '0';
    signal r_input_b2 : bit := '0';
    signal r_input_b3 : bit := '0';
    signal r_input_b4 : bit := '0';
    signal r_input_b5 : bit := '0';
    signal r_anode : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_display : std_logic_vector ( 7 DOWNTO 0) := "00000000";
    signal r_clk : bit := '0';

    component clock is
        port(
        clk : in bit;
        b1 : IN bit;
        b2 : IN bit;
        b3 : IN bit;
        b4 : IN bit;
        b5 : IN bit;
        anode : OUT std_logic_vector (3 DOWNTO 0);
        display: OUT std_logic_vector (7 DOWNTO 0)
        );

    end component clock;

    begin
        UUT : clock
        port map (
        clk => r_clk,
        b1 => r_input_b1,
        b2 => r_input_b2,
        b3 => r_input_b3,
        b4 => r_input_b4,
        b5 => r_input_b5,
        anode => r_anode,
        display => r_output_display
        );

        p_comb : process is
            begin
                wait for c_WAIT;
                r_clk <= '0';
                
                wait for c_WAIT;
                r_clk <= '1';

                wait for c_WAIT;
                r_clk <= '0';

                wait for c_WAIT;
                r_clk <= '1';

            end process;

        end Behavioural;
