`timescale 1ns/1ps

//tb for use in vivado
module z80_top_tb_program #() ();
    // display driving outputs
    /* verilator lint_off UNUSEDSIGNAL */
    logic hsync;            //! horizontal sync (active LOW)
    logic vsync;            //! vertical sync (active LOW)
    logic [3:0] red;        //! red channel (4-bit)
    logic [3:0] green;      //! green channel (4-bit)
    logic [3:0] blue;        //! blue channel (4-bit)

    logic[3:0] buttons = 0;
    logic[3:0] switches = 0;
    logic[3:0] LEDs;
    logic [3:0] je;
    logic [3:0] ja;
    logic led6_r, led6_g;
    // clock
    logic clk;
    /* verilator lint_on UNUSEDSIGNAL */
    
    task reset_tb;
        begin
            buttons[0] = 1;
            repeat(2) @(posedge clk);
            buttons[0] = 0;
            @(posedge clk);
        end
    endtask
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset_tb();
    end

    z80_top #() z80_top (
        //.hsync(hsync),
        //.vsync(vsync),
        //.red(red),
        //.green(green),
        //.blue(blue),
        .buttons(buttons),
        .switches(switches),
        .je(je),
        .ja(ja),
        .LEDs(LEDs),
        .led6_g(led6_g),
        .led6_r(led6_r),
        .clk(clk)
    );

endmodule
