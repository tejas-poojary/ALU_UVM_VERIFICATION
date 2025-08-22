class alu_environment extends uvm_env;
  `uvm_component_utils(alu_environment)
  alu_agent active_agt;
  alu_agent passive_agt;
  alu_scoreboard scb;
  alu_subscriber sub;

  function new(string name="alu_environment",uvm_component parent =null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_active_passive_enum)::set(this,"active_agt","is_active",UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this,"passive_agt","is_active",UVM_PASSIVE);
    active_agt=alu_agent::type_id::create("active_agt",this);
    passive_agt=alu_agent::type_id::create("passive_agt",this);
    scb=alu_scoreboard::type_id::create("scb",this);
    sub=alu_subscriber::type_id::create("sub",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    active_agt.mon.mon_port.connect(scb.act_agt_fifo.analysis_export);
    active_agt.mon.mon_port.connect(sub.act_sub_imp);
    passive_agt.mon.mon_port.connect(scb.pas_agt_fifo.analysis_export);
    passive_agt.mon.mon_port.connect(sub.pas_sub_imp);
  endfunction


endclass
