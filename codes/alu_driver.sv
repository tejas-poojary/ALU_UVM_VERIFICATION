class alu_driver extends uvm_driver#(alu_seq_item);
  `uvm_component_utils(alu_driver)
   virtual alu_intrf vif_drv;
   alu_seq_item drv_seqit;
   alu_seq_item temp;

  function new(string name="alu_driver",uvm_component parent =null);
    super.new(name,parent);
    temp = alu_seq_item::type_id::create("temp");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_intrf)::get(this," ","vif",vif_drv))
      begin
        `uvm_fatal(get_full_name(),"Driver didn't get interface handle");
      end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
   repeat(3)@(vif_drv.drv_cb);
    forever begin
      seq_item_port.get_next_item(drv_seqit);
      `uvm_info(get_full_name(),"Got a sequence item",UVM_LOW);
      drive_alu(drv_seqit);
      seq_item_port.item_done();
    end
  endtask

  task drive_alu(alu_seq_item drv_seqit);
    @(vif_drv.drv_cb);
        begin
         if(drv_seqit.inp_valid==2'b01 || drv_seqit.inp_valid==2'b10)
            begin
               if(((drv_seqit.mode==1)&& (drv_seqit.cmd inside {0,1,2,3,8,9,10})) || ((drv_seqit.mode==0)&& (drv_seqit.cmd inside {0,1,2,3,4,5,12,13})))
                 begin
                    vif_drv.drv_cb.opa<=drv_seqit.opa;
                    vif_drv.drv_cb.opb<=drv_seqit.opb;
                    vif_drv.drv_cb.cin<=drv_seqit.cin;
                    vif_drv.drv_cb.ce<=drv_seqit.ce;
                    vif_drv.drv_cb.cmd<=drv_seqit.cmd;
                    vif_drv.drv_cb.mode<=drv_seqit.mode;
                    vif_drv.drv_cb.inp_valid<=drv_seqit.inp_valid;

                    $display("Driver drived values normally at first edge of 16 cycle at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,drv_seqit.opa,drv_seqit.opb,drv_seqit.cin,drv_seqit.ce,drv_seqit.mode,drv_seqit.cmd,drv_seqit.inp_valid);

                for(int j=0;j<16;j++)
                begin
                 @(vif_drv.drv_cb);
                  begin
                  if(drv_seqit.inp_valid==2'b11)
                   begin
                      $display("Driver entered the if part of repeat 16 loop and got 11 at %0t",$time);
                      vif_drv.drv_cb.opa<=drv_seqit.opa;
                      vif_drv.drv_cb.opb<=drv_seqit.opb;
                      vif_drv.drv_cb.cin<=drv_seqit.cin;
                      vif_drv.drv_cb.ce<=drv_seqit.ce;
                      vif_drv.drv_cb.cmd<=drv_seqit.cmd;
                      vif_drv.drv_cb.mode<=drv_seqit.mode;
                      vif_drv.drv_cb.inp_valid<=drv_seqit.inp_valid;
                      $display("Driver driving values because it got 11 at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,drv_seqit.opa,drv_seqit.opb,drv_seqit.cin,drv_seqit.ce,drv_seqit.mode,drv_seqit.cmd,drv_seqit.inp_valid);
                     break;
                   end
                  else
                    begin
                      $display("Driver inside the else part repeat 16 loop but didnt get 11 at %0t",$time);
                      drv_seqit.mode.rand_mode(0);
                      drv_seqit.cmd.rand_mode(0);
                      drv_seqit.ce.rand_mode(0);   //optional to prevent the non existence of 2'b11 within 16 cycles.
                      drv_seqit.randomize();  //randomize with mode 0 for mode and cmd
                      $display("Driver driving constrained values because it didnt get 11 at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,drv_seqit.opa,drv_seqit.opb,drv_seqit.cin,drv_seqit.ce,drv_seqit.mode,drv_seqit.cmd,drv_seqit.inp_valid);
                    end
                 end //end of second clocking block
                end  //end of 16 for loop
              end  //two input check
           else    //else part for one input
            begin
              vif_drv.drv_cb.opa<=drv_seqit.opa;
              vif_drv.drv_cb.opb<=drv_seqit.opb;
              vif_drv.drv_cb.cin<=drv_seqit.cin;
              vif_drv.drv_cb.ce<=drv_seqit.ce;
              vif_drv.drv_cb.cmd<=drv_seqit.cmd;
              vif_drv.drv_cb.mode<=drv_seqit.mode;
              vif_drv.drv_cb.inp_valid<=drv_seqit.inp_valid;
              $display("Driver driving values because it got single operand operation at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,drv_seqit.opa,drv_seqit.opb,drv_seqit.cin,drv_seqit.ce,drv_seqit.mode,drv_seqit.cmd,drv_seqit.inp_valid);
            end
         end   //end of 01 or 10
     else    //else part for inp_valid is 11 or 00 directly in the 2 operand case
            begin
              vif_drv.drv_cb.opa<=drv_seqit.opa;
              vif_drv.drv_cb.opb<=drv_seqit.opb;
              vif_drv.drv_cb.cin<=drv_seqit.cin;
              vif_drv.drv_cb.ce<=drv_seqit.ce;
              vif_drv.drv_cb.cmd<=drv_seqit.cmd;
              vif_drv.drv_cb.mode<=drv_seqit.mode;
              vif_drv.drv_cb.inp_valid<=drv_seqit.inp_valid;
              $display("Driver driving values because it got 11 directly at first edge without waiting for 16 cycles at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d",$time,drv_seqit.opa,drv_seqit.opb,drv_seqit.cin,drv_seqit.ce,drv_seqit.mode,drv_seqit.cmd,drv_seqit.inp_valid);
            end
        end   //end of clocking block

//Logic to delay the next driving value

       if(drv_seqit.inp_valid inside {0,1,2,3} && ((drv_seqit.mode==1 &&drv_seqit.cmd inside {0,1,2,3,4,5,6,7,8})|| (drv_seqit.mode==0 &&drv_seqit.cmd inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})))
         repeat (1) @(vif_drv.drv_cb);
       else if(drv_seqit.inp_valid==3 && (drv_seqit.mode==1 && drv_seqit.cmd inside {9,10}))
         repeat(2)@(vif_drv.drv_cb);


  endtask

endclass
