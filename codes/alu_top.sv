import uvm_pkg::*;
`include "uvm_macros.svh"
`include "alu_interface.sv"
`include "alu_pkg.sv"
`include "alu_design.sv"


module top();
 import uvm_pkg::*;
 import alu_pkg::*;

bit clk,reset;

 initial
    begin
     forever #10 clk=~clk;
    end

initial
    begin
      @(posedge clk);
      reset=1;
      repeat(1)@(negedge clk);
      reset=0;
    end

alu_intrf intrf(clk,reset);  //interface instantiation

ALU_DESIGN DUT(.OPA(intrf.opa),
.OPB(intrf.opb),
.CIN(intrf.cin),
.CE(intrf.ce),
.MODE(intrf.mode),
.CMD(intrf.cmd),
.INP_VALID(intrf.inp_valid),
.CLK(clk),
.RST(reset),
.RES(intrf.res),
.COUT(intrf.cout),
.OFLOW(intrf.oflow),
.ERR(intrf.err),
.G(intrf.g),
.L(intrf.l),
.E(intrf.e)
);

initial begin
  uvm_config_db#(virtual alu_intrf)::set(uvm_root::get(),"*","vif",intrf);
end

  initial begin
    run_test("alu_regression_test");
    #100 $finish;
  end
endmodule
