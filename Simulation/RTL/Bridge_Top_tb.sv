`timescale 1ns/1ps

module Bridge_Top_tb;

// Clock and reset signals
reg Hclk;
reg Hresetn;

// AHB interface signals
reg Hwrite, Hreadyin;
reg [1:0] Htrans;
reg [31:0] Haddr, Hwdata;
wire Hreadyout;
wire [31:0] Hrdata;
wire [1:0] Hresp;

// APB interface signals
reg [31:0] Prdata;
wire Penable, Pwrite;
wire [2:0] Pselx;
wire [31:0] Paddr, Pwdata;

// Instantiate the DUT (Device Under Test)
Bridge_Top uut (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Hreadyout(Hreadyout),
    .Hwdata(Hwdata),
    .Haddr(Haddr),
    .Htrans(Htrans),
    .Prdata(Prdata),
    .Penable(Penable),
    .Pwrite(Pwrite),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Hrdata(Hrdata),
    .Hresp(Hresp)
);

// Clock generation
initial begin
    Hclk = 0;
    forever #5 Hclk = ~Hclk; // 10ns clock period
end

// Reset logic
initial begin
    Hresetn = 0;
    #20 Hresetn = 1; // Release reset after 20ns
end

initial begin
	$monitor("Hresetn = %h,Hreadyin = %h, Hwrite = %h, Htrans = %h, Haddr = %h, Hwdata = %h, Paddr = %h, Pwdata = %h, Prdata = %h, Hrdata = %h", Hresetn, Hreadyin, Hwrite, Htrans, Haddr, Hwdata, Paddr, Pwdata, Prdata, Hrdata);

	end

// Test stimulus
initial begin
    // Initialize inputs

    Hreadyin =0;
#10;
    Hwrite = 0;
    Hreadyin = 1;
    Htrans = 2'b00;
    Haddr = 32'h00000000;
    Hwdata = 32'h00000000;
    Prdata = 32'hA5A5A5A5; // Sample data for read tests

    // Wait for reset
    @(posedge Hresetn);

    // Test Case 1: Idle -> Write Transfer
    #10;
    Hwrite = 1;
    Htrans = 2'b10; // Non-sequential transfer
    Haddr = 32'h80000010; // Valid APB address
    Hwdata = 32'h12345678;

    // Wait for the transaction to complete
    wait(Hreadyout);
    #40;
    
    
    Haddr = 32'h800000a2;
    Hwdata = 32'h55555555;

    wait(Hreadyout);
    #40;

    Hwrite = 0;
    Htrans = 2'b10;
    Haddr = 32'h80000010;
    Prdata = 32'h88888888;

    wait(Hreadyout);
#100;



    // End simulation
    $finish;
end

endmodule
