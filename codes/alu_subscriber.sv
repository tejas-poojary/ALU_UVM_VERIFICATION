class alu_subscriber extends uvm_subscriber#(alu_seq_item);
  `uvm_component_utils(alu_subscriber);
  `uvm_analysis_imp_decl(_act_mon)
  `uvm_analysis_imp_decl(_pas_mon)
   uvm_analysis_imp_act_mon#(alu_seq_item,alu_subscriber)act_sub_imp;
   uvm_analysis_imp_pas_mon#(alu_seq_item,alu_subscriber)pas_sub_imp;
   alu_seq_item act_mon_seq,pas_mon_seq;
   real act_mon_coverage,pas_mon_coverage;


  covergroup act_mon_cov;
     INPUT_VALID: coverpoint act_mon_seq.inp_valid {  bins valid_opa = {2'b01};
                                    bins valid_opb = {2'b10};
                                    bins valid_both = {2'b11};
                                    bins invalid = {2'b00};
                                 }
     COMMAND : coverpoint act_mon_seq.cmd { bins arithmetic[] = {[0:10]};
                                         bins logical[] = {[0:13]};
                                         bins arithmetic_invalid[] = {[11:15]};
                                         bins logical_invalid[] = {14,15};
                                          }
      MODE : coverpoint act_mon_seq.mode { bins arithmetic = {1};
                                         bins logical = {0};
                                       }
     CLOCK_ENABLE : coverpoint act_mon_seq.ce { bins clock_enable_valid = {1};
                                               bins clock_enable_invalid = {0};
                                               }
      OPERAND_A : coverpoint act_mon_seq.opa { bins opa[]={[0:(2**`n)-1]};}
      OPERAND_B : coverpoint act_mon_seq.opb { bins opb[]={[0:(2**`n)-1]};}
      CARRY_IN : coverpoint act_mon_seq.cin { bins cin_high = {1};
                                            bins cin_low = {0};
                                          }
      MODE_CMD_: cross MODE,COMMAND;
  endgroup

  covergroup pas_mon_cov;
    RESULT_CHECK:coverpoint pas_mon_seq.res { bins result[]={[0:(2**`n)-1]};
                                            }
      CARR_OUT:coverpoint pas_mon_seq.cout{ bins cout_active = {1};
                                          bins cout_inactive = {0};
                                        }
      OVERFLOW:coverpoint pas_mon_seq.oflow { bins oflow_active = {1};
                                          bins oflow_inactive = {0};
                                        }
      ERROR:coverpoint pas_mon_seq.err { bins error_active = {1};
                                     }
      GREATER:coverpoint pas_mon_seq.g { bins greater_active = {1};
                                     }
      EQUAL:coverpoint pas_mon_seq.e { bins equal_active = {1};
                                   }
      LESSER:coverpoint pas_mon_seq.l { bins lesser_active = {1};
                                    }
  endgroup

 function new(string name="alu_subscriber",uvm_component parent=null);
    super.new(name,parent);
    act_sub_imp=new("drv2sub_imp",this);
    pas_sub_imp=new("mon2sub_imp",this);
    act_mon_cov=new();
    pas_mon_cov=new();
  endfunction

 function void write(alu_seq_item t);
   // Not used already present in base class
 endfunction

  function void write_act_mon(alu_seq_item t);
    act_mon_seq=t;
    act_mon_cov.sample();
  endfunction

  function void write_pas_mon(alu_seq_item t);
    pas_mon_seq=t;
    pas_mon_cov.sample();
  endfunction

  function void extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  act_mon_coverage = act_mon_cov.get_coverage();
  pas_mon_coverage = pas_mon_cov.get_coverage();
endfunction

  function void report_phase(uvm_phase phase);
   super.report_phase(phase);
    `uvm_info(get_type_name, $sformatf("[INPUT] Coverage ------> %0.2f%%,", act_mon_coverage), UVM_MEDIUM);
    `uvm_info(get_type_name, $sformatf("[OUTPUT] Coverage ------> %0.2f%%", pas_mon_coverage), UVM_MEDIUM);
  endfunction

endclass
