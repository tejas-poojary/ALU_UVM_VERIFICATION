 import uvm_pkg::*;
`include "uvm_macros.svh"
`include "alu_defines.sv"

class alu_seq_item extends uvm_sequence_item;
  rand bit [`n-1:0]opa,opb;
  rand bit [`m-1:0]cmd;
  rand bit mode,cin,ce;
  rand bit [1:0]inp_valid;
  logic [`n:0] res;
  logic err,cout,oflow,g,l,e;

 `uvm_object_utils_begin(alu_seq_item)
   `uvm_field_int(opa,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(opb,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(cin,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(ce,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(mode,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(cmd,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(inp_valid,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(res,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(cout,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(oflow,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(err,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(g,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(l,UVM_ALL_ON+UVM_DEC)
   `uvm_field_int(e,UVM_ALL_ON+UVM_DEC)
 `uvm_object_utils_end

function new(string name="my_seq_item");
 super.new(name);
endfunction

//can write constraints here as well or in the sequence class
 constraint clk_en { ce dist {0:=10,1:=90}; }
 constraint input_valid { inp_valid dist {[1:3]:=90,0:=10};}
 constraint command {if(mode)
                       cmd inside {[0:10]};
                    else
                       cmd inside {[0:13]};
                   }

 /*constraint set{ cmd==0;
                   mode==1;
                   inp_valid inside{1,3};
                   inp_valid dist {1:=70,3:=30};
                }*/

 /* constraint set{ cmd==10;
                  mode==1;
                  inp_valid inside{1,3};
                  inp_valid dist {1:=70,3:=30};
                } */

endclass
