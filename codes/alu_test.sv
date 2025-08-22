class alu_base_test extends uvm_test;

  `uvm_component_utils(alu_base_test)

   alu_environment env;

  function new(string name = "alu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_environment::type_id::create("env", this);
    endfunction

   virtual task run_phase(uvm_phase phase);
    alu_sequence seq;
    seq = alu_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.active_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of test case",UVM_LOW);
   endtask
endclass

//alu_single_operand_logical_test

class alu_single_operand_logical_test extends alu_base_test;

    `uvm_component_utils(alu_single_operand_logical_test)

    alu_single_operand_logical seq;

    function new(string name = "alu_single_operand_logical_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_single_operand_logical::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass

//alu_single_operand_arithmetic_test

class alu_single_operand_arithmetic_test extends alu_base_test;

    `uvm_component_utils(alu_single_operand_arithmetic_test)

    alu_single_operand_arithmetic seq;

    function new(string name = "alu_single_operand_arithmetic_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_single_operand_arithmetic::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass

//alu_multiple_operand_arithmetic_test

class alu_multiple_operand_arithmetic_test extends alu_base_test;

  `uvm_component_utils(alu_multiple_operand_arithmetic_test)

    alu_multiple_operand_arithmetic seq;

    function new(string name = "alu_multiple_operand_arithmetic_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_multiple_operand_arithmetic::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass


//alu_multiple_operand_logical_test

class alu_multiple_operand_logical_test extends alu_base_test;

  `uvm_component_utils(alu_multiple_operand_logical_test)

    alu_multiple_operand_logical seq;

  function new(string name = "alu_multiple_operand_logical_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_multiple_operand_logical::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass

//alu_multiplication_test

class alu_multiplication_test extends alu_base_test;

  `uvm_component_utils(alu_multiplication_test)

    alu_multiplication seq;

  function new(string name = "alu_multiplication_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_multiplication::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass

//alu_regression_test

class alu_regression_test extends alu_base_test;

  `uvm_component_utils(alu_regression_test)

    alu_regression seq;

  function new(string name = "alu_regression_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_regression::type_id::create("seq");
        seq.start(env.active_agt.seqr);
        phase.drop_objection(this);
    endtask

endclass
