//base sequence class

class alu_sequence extends uvm_sequence#(alu_seq_item);
`uvm_object_utils(alu_sequence)
 alu_seq_item item;

function new(string name="alu_sequence");
  super.new(name);
endfunction

virtual task body();
  repeat(4000)
   begin
   item=alu_seq_item::type_id::create("item");
   wait_for_grant();
   item.randomize();
   send_request(item);
   wait_for_item_done();  //get_response is optional
 end
 endtask

 endclass

//logical single operand sequence

class alu_single_operand_logical extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_single_operand_logical)

  function new(string name="alu_single_operand_logical");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid inside {1,2,3};
                     req.mode==0;
                     req.cmd inside {[6:11]};
                     req.ce==1;
                })
      end
  endtask
endclass

//arithmetic single operand sequence

class alu_single_operand_arithmetic extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_single_operand_arithmetic)

  function new(string name="alu_single_operand_arithmetic");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid inside {1,2,3};
                     req.mode==1;
                     req.cmd inside {[4:7]};
                     req.ce==1;
                })
      end
  endtask
endclass

//logical multiple operand sequence

class alu_multiple_operand_logical extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_multiple_operand_logical)

  function new(string name="alu_multiple_operand_logical");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid==3;
                     req.mode==0;
                     req.cmd inside {[0:5],12,13};
                     req.ce==1;
                })
      end
  endtask
endclass

//arithmetic multiple operand sequence

class alu_multiple_operand_arithmetic extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_multiple_operand_arithmetic)

  function new(string name="alu_multiple_operand_arithmetic");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid==3;
                     req.mode==1;
                     req.cmd inside {[0:3],[8:10]};
                     req.ce==1;
                })
      end
  endtask
endclass

//arithmetic multiplication sequence

class alu_multiplication extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_multiplication)

  function new(string name="alu_multiplication");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid==3;
                     req.mode==1;
                     req.cmd inside {9,10};
                     req.ce==1;
                })
      end
  endtask
endclass

//16 cycle multiplication

class alu_16_cycle_multiplication extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_16_cycle_multiplication)

  function new(string name="alu_16_cycle_multiplication");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
        `uvm_do_with(req,{req.inp_valid inside {1,2,3};
                          req.inp_valid dist {1:=40,2:=40,3:=20};
                          req.mode==1;
                          req.cmd inside {9,10};
                          req.ce==1;
                })
      end
  endtask
endclass

//logical 16 cycle sequence

class alu_16_cycle_logical extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_16_cycle_logical)

  function new(string name="alu_16_cycle_logical");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
      `uvm_do_with(req,{req.inp_valid inside {1,2,3};
                        req.inp_valid dist {1:=40,2:=40,3:=20};
                        req.mode==0;
                        req.cmd inside {[0:13]};
                        req.ce==1;
                })
      end
  endtask
endclass

//arithmetic 16 cycle sequence

class alu_16_cycle_arithmetic extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_16_cycle_arithmetic)

  function new(string name="alu_16_cycle_arithmetic");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
      `uvm_do_with(req,{req.inp_valid inside {1,2,3};
                        req.inp_valid dist {1:=40,2:=40,3:=20};
                        req.mode==1;
                        req.cmd inside {[0:10]};
                        req.ce==1;
                })
      end
  endtask
endclass

//inactive clock enable sequence

class alu_inactive_enable extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_inactive_enable)

  function new(string name="alu_inactive_enable");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
      `uvm_do_with(req,{
                        req.ce==0;
                   })
      end
  endtask
endclass

//input valid  00 case

class alu_inp_valid_00 extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_inp_valid_00)

  function new(string name="alu_inp_valid_00");
    super.new(name);
  endfunction

  virtual task body();
    repeat(4000)
      begin
      `uvm_do_with(req,{
                        req.ce==1;
                        req.inp_valid==2'b00;
                   })
      end
  endtask
endclass


//regression sequence

class alu_regression extends uvm_sequence#(alu_seq_item);
  `uvm_object_utils(alu_regression)
   alu_sequence base;
   alu_single_operand_logical sing_log;
   alu_single_operand_arithmetic sing_arith;
   alu_multiple_operand_logical multi_log;
   alu_multiple_operand_arithmetic multi_arith;
   alu_multiplication mult;
   alu_16_cycle_multiplication mult_16;
   alu_16_cycle_arithmetic arith_16;
   alu_16_cycle_logical  log_16;
   alu_inactive_enable inactive_ce;
   alu_inp_valid_00 inp_00;

  function new(string name="alu_regression");
    super.new(name);
  endfunction

  virtual task body();
      begin
        `uvm_do(base)
        `uvm_do(sing_log)
        `uvm_do(sing_arith)
        `uvm_do(multi_log)
        `uvm_do(multi_arith)
        `uvm_do(mult)
        `uvm_do(mult_16)
        `uvm_do(arith_16)
        `uvm_do(log_16)
        `uvm_do(inactive_ce)
        `uvm_do(inp_00)
      end
  endtask
endclass

