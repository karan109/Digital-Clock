library ieee;
use ieee.std_logic_1164.all;

entity clock_tb is
end entity;

architecture Behavioural of clock_tb is

    constant c_WAIT : time := 1 fs; -- Fast, 50MHz change.

    signal r_input_b1 : bit := '0';
    signal r_input_b2 : bit := '0';
    signal r_input_b3 : bit := '0';
    signal r_input_b4 : bit := '0';
    signal r_input_b5 : bit := '0';
    signal r_sig : bit := '0';
    signal r_anode : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_s1 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_m1 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_h1 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_s2 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_m2 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_h2 : std_logic_vector ( 3 DOWNTO 0) := "0000";
    signal r_output_display : std_logic_vector ( 7 DOWNTO 0) := "00000000";
    signal r_output_display2 : std_logic_vector ( 7 DOWNTO 0) := "00000000";
    signal r_clk : bit := '0';

    component clock is
        port(
        clk : in bit;
        b1 : IN bit;
        b2 : IN bit;
        b3 : IN bit;
        b4 : IN bit;
        b5 : IN bit;
        sig : OUT bit;
        anode : OUT std_logic_vector (3 DOWNTO 0);
        s1 : OUT std_logic_vector ( 3 DOWNTO 0);
        m1 : OUT std_logic_vector ( 3 DOWNTO 0);
        h1 : OUT std_logic_vector ( 3 DOWNTO 0);
        s2 : OUT std_logic_vector ( 3 DOWNTO 0);
        m2 : OUT std_logic_vector ( 3 DOWNTO 0);
        h2 : OUT std_logic_vector ( 3 DOWNTO 0);
        display: OUT std_logic_vector (7 DOWNTO 0);
        display2: OUT std_logic_vector (7 DOWNTO 0)
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
        sig => r_sig,
        anode => r_anode,
        s1 => r_output_s1,
        m1 => r_output_m1,
        h1 => r_output_h1,
        s2 => r_output_s2,
        m2 => r_output_m2,
        h2 => r_output_h2,
        display => r_output_display,
        display2 => r_output_display2
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

                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';

                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';


                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';


                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';


                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';


                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';


                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';

                --wait for c_WAIT;
                --r_input_b2 <= '0';
                --wait for c_WAIT;
                --wait for c_WAIT;
                --wait for c_WAIT;
                --wait for c_WAIT;
                --wait for c_WAIT;
                --wait for c_WAIT;
                --r_input_b2 <= '1';
                --wait for c_WAIT;
                --wait for c_WAIT;
                --r_input_b3 <= '0';
                --wait for c_WAIT;
                --r_input_b3 <= '1';
                --wait for c_WAIT;
                --r_input_b4 <= '1';
                --wait for c_WAIT;
                --wait for c_WAIT;
                --r_input_b2 <= '0';


            end process;

        end Behavioural;
