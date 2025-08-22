class alu_monitor extends uvm_monitor;
   virtual alu_intrf vif_mon;
   uvm_analysis_port#(alu_seq_item) mon_port;
  `uvm_component_utils(alu_monitor)
   alu_seq_item mon_seqit;

  function new(string name="alu_monitor",uvm_component parent =null);
    super.new(name,parent);
    mon_port=new("mon_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_intrf)::get(this," ","vif",vif_mon))
      begin
        `uvm_fatal(get_full_name(),"Monitor didn't get interface handle");
      end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Monitor run_phase started", UVM_MEDIUM)
   repeat(4)@(vif_mon.mon_cb);
    forever begin
      @(vif_mon.mon_cb);  //check this laterrrr was just @(vif_mon.mon_cb)
      mon_seqit=alu_seq_item::type_id::create("mon_sequit");      //create the sequence item
  if(vif_mon.mon_cb.inp_valid inside{0,1,2,3} && ((vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,6,7,8})||(vif_mon.mon_cb.mode==0 && vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
    repeat(1) @(vif_mon.mon_cb); //was repeat 1
else if(vif_mon.mon_cb.inp_valid==3 && (vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {9,10}))
    repeat(2) @(vif_mon.mon_cb);  //was repeat 2

   begin
     if((vif_mon.mon_cb.inp_valid==2'b01) ||(vif_mon.mon_cb.inp_valid==2'b10))
      begin
        if(((vif_mon.mon_cb.mode==1)&& (vif_mon.mon_cb.cmd inside {0,1,2,3,8,9,10})) || ((vif_mon.mon_cb.mode==0)&& (vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,12,13})))
          begin
            for(int j=0;j<16;j++)
              begin
                @(vif_mon.mon_cb);
                 begin
                  if(vif_mon.mon_cb.inp_valid==2'b11)
                    begin
                     if(vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {9,10})
                      begin
                       repeat(2)@(vif_mon.mon_cb);
                       $display("Virtual interface values from the dut to the monitor at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d,RES=%0d,OFLOW=%0d,COUT=%0d,ERR=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.cmd,vif_mon.mon_cb.res,vif_mon.mon_cb.oflow,vif_mon.mon_cb.cout,vif_mon.mon_cb.err,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);  //extra display added for debugging
                       mon_seqit.res=vif_mon.mon_cb.res;
                       mon_seqit.err=vif_mon.mon_cb.err;
                       mon_seqit.g=vif_mon.mon_cb.g;
                       mon_seqit.l=vif_mon.mon_cb.l;
                       mon_seqit.e=vif_mon.mon_cb.e;
                       mon_seqit.oflow=vif_mon.mon_cb.oflow;
                       mon_seqit.cout=vif_mon.mon_cb.cout;
          //put inputs so that to compare at the output
                       mon_seqit.opa=vif_mon.mon_cb.opa;
                       mon_seqit.opb=vif_mon.mon_cb.opb;
                       mon_seqit.cin=vif_mon.mon_cb.cin;
                       mon_seqit.ce=vif_mon.mon_cb.ce;
                       mon_seqit.mode=vif_mon.mon_cb.mode;
                       mon_seqit.cmd=vif_mon.mon_cb.cmd;
                       mon_seqit.inp_valid=vif_mon.mon_cb.inp_valid;
                       mon_port.write(mon_seqit);
                       $display("Monitor put  values from the DUT to scoreboard @ %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
                   end   // if cmd is of multiplication
                    else  //else if it is any other operation
                     begin
                      repeat(1)@(vif_mon.mon_cb);
                      $display("Virtual interface values from the dut to the monitor at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d,RES=%0d,OFLOW=%0d,COUT=%0d,ERR=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.cmd,vif_mon.mon_cb.res,vif_mon.mon_cb.oflow,vif_mon.mon_cb.cout,vif_mon.mon_cb.err,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);  //extra display added for debugging

                       mon_seqit.res=vif_mon.mon_cb.res;
                       mon_seqit.err=vif_mon.mon_cb.err;
                       mon_seqit.g=vif_mon.mon_cb.g;
                       mon_seqit.l=vif_mon.mon_cb.l;
                       mon_seqit.e=vif_mon.mon_cb.e;
                       mon_seqit.oflow=vif_mon.mon_cb.oflow;
                       mon_seqit.cout=vif_mon.mon_cb.cout;
                //put inputs so that to compare at the output
                       mon_seqit.opa=vif_mon.mon_cb.opa;
                       mon_seqit.opb=vif_mon.mon_cb.opb;
                       mon_seqit.cin=vif_mon.mon_cb.cin;
                       mon_seqit.ce=vif_mon.mon_cb.ce;
                       mon_seqit.mode=vif_mon.mon_cb.mode;
                       mon_seqit.cmd=vif_mon.mon_cb.cmd;
                       mon_seqit.inp_valid=vif_mon.mon_cb.inp_valid;

                       mon_port.write(mon_seqit);
                       $display("Monitor put  values from the DUT to scoreboard @ %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
                    end   //end of else
                     break;
                   end  // end of inp_valid 11
                 else
                    begin
                      continue;
                    end
                 end   //end of clocking
                end    //end of for loop
              end      //end of if for two inputs
        else if((vif_mon.mon_cb.mode==1 && vif_mon.mon_cb.cmd inside {4,5,6,7})||(vif_mon.mon_cb.mode==0 && vif_mon.mon_cb.cmd inside {6,7,8,9,10,11}))
              begin
                  $display("Virtual interface values from the dut to the monitor at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d,RES=%0d,OFLOW=%0d,COUT=%0d,ERR=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.cmd,vif_mon.mon_cb.res,vif_mon.mon_cb.oflow,vif_mon.mon_cb.cout,vif_mon.mon_cb.err,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);  //extra display added for debugging

                     mon_seqit.res=vif_mon.mon_cb.res;
                     mon_seqit.err=vif_mon.mon_cb.err;
                     mon_seqit.g=vif_mon.mon_cb.g;
                     mon_seqit.l=vif_mon.mon_cb.l;
                     mon_seqit.e=vif_mon.mon_cb.e;
                     mon_seqit.oflow=vif_mon.mon_cb.oflow;
                     mon_seqit.cout=vif_mon.mon_cb.cout;
 //put inputs so that to compare at the output
                      mon_seqit.opa=vif_mon.mon_cb.opa;
                      mon_seqit.opb=vif_mon.mon_cb.opb;
                      mon_seqit.cin=vif_mon.mon_cb.cin;
                      mon_seqit.ce=vif_mon.mon_cb.ce;
                      mon_seqit.mode=vif_mon.mon_cb.mode;
                      mon_seqit.cmd=vif_mon.mon_cb.cmd;
                      mon_seqit.inp_valid=vif_mon.mon_cb.inp_valid;

                      mon_port.write(mon_seqit);
                $display("Monitor put values from the DUT to scoreboard for direct single operand operation @ %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);

               end  // end for one input
           end  //end for 01 0r 10 at first edge
        else     // else for direct 11 or 00
           begin
             $display("Virtual interface values from the dut to the monitor at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d,RES=%0d,OFLOW=%0d,COUT=%0d,ERR=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.cmd,vif_mon.mon_cb.res,vif_mon.mon_cb.oflow,vif_mon.mon_cb.cout,vif_mon.mon_cb.err,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);  //extra display added for debugging

             mon_seqit.res=vif_mon.mon_cb.res;
             mon_seqit.err=vif_mon.mon_cb.err;
             mon_seqit.g=vif_mon.mon_cb.g;
             mon_seqit.l=vif_mon.mon_cb.l;
             mon_seqit.e=vif_mon.mon_cb.e;
             mon_seqit.oflow=vif_mon.mon_cb.oflow;
             mon_seqit.cout=vif_mon.mon_cb.cout;
 //put inputs so that to compare at the output
             mon_seqit.opa=vif_mon.mon_cb.opa;
             mon_seqit.opb=vif_mon.mon_cb.opb;
             mon_seqit.cin=vif_mon.mon_cb.cin;
             mon_seqit.ce=vif_mon.mon_cb.ce;
             mon_seqit.mode=vif_mon.mon_cb.mode;
             mon_seqit.cmd=vif_mon.mon_cb.cmd;
             mon_seqit.inp_valid=vif_mon.mon_cb.inp_valid;

             mon_port.write(mon_seqit);
            $display("Monitor put values from the DUT to scoreboard @ %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
   end  //end of direct 11
  end
end
endtask

endclass
