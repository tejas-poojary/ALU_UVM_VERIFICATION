class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)
  alu_driver drv;
  alu_monitor mon;
  alu_sequencer seqr;

  function new(string name="alu_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_active_passive_enum) :: get(this,"","is_active",is_active);
    if(get_is_active()==UVM_ACTIVE)
      begin
       drv=alu_driver::type_id::create("drv",this);
       seqr=alu_sequencer::type_id::create("seqr",this);
      end
       mon=alu_monitor::type_id::create("mon",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if(get_is_active()==UVM_ACTIVE)
     drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
