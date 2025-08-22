class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)
  uvm_tlm_analysis_fifo#(alu_seq_item)act_agt_fifo;
  uvm_tlm_analysis_fifo#(alu_seq_item)pas_agt_fifo;
   virtual alu_intrf vif_ref;
   alu_seq_item in_seq,ref_out_seq,mon_out_seq;
   int shift_value,got,inside_16;
   localparam int required_bits = $clog2(`n);
   logic [`n:0] prev_res;  //for ce latching logic
   logic prev_oflow, prev_cout, prev_g, prev_l, prev_e, prev_err;

  function new(string name="alu_scoreboard",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    act_agt_fifo=new("act_agt_fifo",this);
    pas_agt_fifo=new("pas_agt_fifo",this);
    if(!uvm_config_db#(virtual alu_intrf)::get(this," ","vif",vif_ref))   //to get reset and clk access
      begin
        `uvm_fatal(get_full_name(),"Scoreboard didn't get interface handle");
      end
  endfunction

  task reference_model_process(input alu_seq_item in_seq,inout alu_seq_item ref_out_seq);
    $display("Inside the ref model task at %0t",$time);
    ref_out_seq.res=9'bz;
             ref_out_seq.oflow=1'bz;    //added this check later
             ref_out_seq.cout=1'bz;
             ref_out_seq.g=1'bz;
             ref_out_seq.l=1'bz;
             ref_out_seq.e=1'bz;
             ref_out_seq.err=1'bz;
    if(vif_ref.ref_cb.reset==1)
           begin
             ref_out_seq.res=9'bz;
             ref_out_seq.oflow=1'bz;
             ref_out_seq.cout=1'bz;
             ref_out_seq.g=1'bz;
             ref_out_seq.l=1'bz;
             ref_out_seq.e=1'bz;
             ref_out_seq.err=1'bz;
           end
         else   //else if reset is not 1
           begin
             if(in_seq.ce==1)    //check for clock enable
              begin
                 if(in_seq.inp_valid == 2'b01 || in_seq.inp_valid == 2'b10)     //16 cycle delay logic
                     begin
                       if(((in_seq.mode==1)&& (in_seq.cmd inside {0,1,2,3,8,9,10})) || ((in_seq.mode==0)&& (in_seq.cmd inside {0,1,2,3,4,5,12,13})))   //inp_valid is 01 or 10 at first clock but cmd is 2 operand operation
                         begin
                           $display("Reference model got values at %0t:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,INP_VALID=%0d,CMD=%0d",$time,in_seq.opa,in_seq.opb,in_seq.cin,in_seq.ce,in_seq.mode,in_seq.inp_valid,in_seq.cmd);

                           if(in_seq.inp_valid==2'b11)  //perform all operations also
                            begin
                              got=1;
                             if(in_seq.mode==1)
                               begin
                                case(in_seq.cmd)
                                  `ADD:begin
                                            $display("INSIDE 16 CYCLE ADD OPERATION");
                                            ref_out_seq.res=(in_seq.opa+in_seq.opb);
                                            ref_out_seq.cout=ref_out_seq.res[`n]?1:0;
                                              end
                                      `SUB:begin
                                           ref_out_seq.res=(in_seq.opa-in_seq.opb);
                                           ref_out_seq.oflow=(in_seq.opa<in_seq.opb)?1:0;
                                              end
                                      `ADD_CIN:begin
                                                 ref_out_seq.res=(in_seq.opa+in_seq.opb+in_seq.cin);
                                                 ref_out_seq.cout=ref_out_seq.res[`n]?1:0;
                                              end
                                      `SUB_CIN:begin
                                                 ref_out_seq.res=(in_seq.opa-in_seq.opb-in_seq.cin);
                                                 ref_out_seq.oflow=((in_seq.opa<in_seq.opb)||((in_seq.opa==in_seq.opb)&&in_seq.cin))?1:0;
                                               end
                                  `CMP:begin
                                          ref_out_seq.e=(in_seq.opa==in_seq.opb)? 1'b1:1'b0;
                                          ref_out_seq.g=(in_seq.opa>in_seq.opb)? 1'b1:1'b0;
                                          ref_out_seq.l=(in_seq.opa<in_seq.opb)? 1'b1:1'b0;
                                      end
                                  `INC_MUL:begin
                                              ref_out_seq.res=(in_seq.opa+1)*(in_seq.opb+1);
                                          end
                                  `SHIFT_MUL:begin
                                               ref_out_seq.res=(in_seq.opa<<1)*(in_seq.opb);
                                            end
                                  default:begin
                                               ref_out_seq.res=9'bz;
                                               ref_out_seq.oflow=1'bz;
                                               ref_out_seq.cout=1'bz;
                                               ref_out_seq.err=1'bz;
                                               ref_out_seq.g=1'bz;
                                               ref_out_seq.l=1'bz;
                                               ref_out_seq.e=1'bz;
                                          end
                                endcase
                               end     //end of if mode==1
                  else              //else part for mode=0
                    begin
                      case(in_seq.cmd)
                        `AND:begin
                                ref_out_seq.res={1'b0,(in_seq.opa & in_seq.opb)};
                            end
                        `NAND:begin
                               ref_out_seq.res={1'b0,~(in_seq.opa & in_seq.opb)};
                            end
                        `OR:begin
                              ref_out_seq.res={1'b0,(in_seq.opa | in_seq.opb)};
                            end
                        `NOR:begin
                               ref_out_seq.res={1'b0,~(in_seq.opa | in_seq.opb)};
                            end
                        `XOR:begin
                               ref_out_seq.res={1'b0,(in_seq.opa ^ in_seq.opb)};
                            end
                        `XNOR:begin
                                ref_out_seq.res={1'b0,~(in_seq.opa ^ in_seq.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=in_seq.opb[required_bits-1:0];
                                 ref_out_seq.res={1'b0,((in_seq.opa<<shift_value)|(in_seq.opa>>`n-shift_value))};
                                 if(in_seq.opb>`n-1)
                                  ref_out_seq.err=1;
                                end
                        `ROR_A_B:begin
                                 shift_value=in_seq.opb[required_bits-1:0];
                                 ref_out_seq.res={1'b0,((in_seq.opa>>shift_value)|(in_seq.opa<<`n-shift_value))};
                                if(in_seq.opb>`n-1)
                                  ref_out_seq.err=1;
                                end
                        default:begin
                               ref_out_seq.res=9'bz;
                               ref_out_seq.oflow=1'bz;
                               ref_out_seq.cout=1'bz;
                               ref_out_seq.g=1'bz;
                               ref_out_seq.l=1'bz;
                               ref_out_seq.e=1'bz;
                               ref_out_seq.err=1'bz;
                              end
                      endcase
                  end // end of mode==0
             end              //end of if inp_valid becomes 11 within 16 cycle
        if(got!=1)
         ref_out_seq.err=1'b1;
       end   //end for 2 input mode and cmd check
    else if((in_seq.mode==1 && in_seq.cmd inside {4,5,6,7}) || (in_seq.mode==0 && in_seq.cmd inside {6,7,8,9,10,11}))      //else loop for single operand operatons
      begin

       if(in_seq.mode==1)
          begin
            if(in_seq.inp_valid==01)
              begin
               case(in_seq.cmd)
                `INC_A:begin
                        ref_out_seq.res=in_seq.opa+1;
                    end
                `DEC_A:begin
                        ref_out_seq.res=in_seq.opa-1;
                    end
                 default:begin
                        ref_out_seq.res=9'bz;
                        ref_out_seq.oflow=1'bz;
                        ref_out_seq.cout=1'bz;
                        ref_out_seq.g=1'bz;
                        ref_out_seq.l=1'bz;
                        ref_out_seq.e=1'bz;
                        ref_out_seq.err=1'bz;
                      end
               endcase //endcase for 01
            end //end for 01
         else  //for 10
           begin
             case(in_seq.cmd)
               `INC_B:begin
                        ref_out_seq.res=in_seq.opb+1;
                      end
                `DEC_B:begin
                        ref_out_seq.res=in_seq.opb-1;
                      end
                 default:begin
                        ref_out_seq.res=9'bz;
                        ref_out_seq.oflow=1'bz;
                        ref_out_seq.cout=1'bz;
                        ref_out_seq.g=1'bz;
                        ref_out_seq.l=1'bz;
                        ref_out_seq.e=1'bz;
                        ref_out_seq.err=1'bz;
                      end
              endcase
            end
          end //end of mode 1
        else   //for mode=0
          begin
          if(in_seq.inp_valid==2'b01)
            begin
            case(in_seq.cmd)
              `NOT_A:begin
                        ref_out_seq.res={1'b0,~(in_seq.opa)};
                    end
              `SHR1_A:begin
                       ref_out_seq.res={1'b0,(in_seq.opa>>1)};
                    end
              `SHL1_A:begin
                        ref_out_seq.res={1'b0,(in_seq.opa<<1)};
                    end
              default:begin
                        ref_out_seq.res=9'bz;
                        ref_out_seq.oflow=1'bz;
                        ref_out_seq.cout=1'bz;
                        ref_out_seq.g=1'bz;
                        ref_out_seq.l=1'bz;
                        ref_out_seq.e=1'bz;
                        ref_out_seq.err=1'bz;
                      end
             endcase
            end  //end for if 01
          else
             begin
               case(in_seq.cmd)
               `NOT_B:begin
                       ref_out_seq.res={1'b0,~(in_seq.opb)};
                      end
                `SHR1_B:begin
                         ref_out_seq.res={1'b0,(in_seq.opb>>1)};
                        end
                `SHL1_B:begin
                         ref_out_seq.res={1'b0,(in_seq.opb<<1)};
                        end
                  default:begin
                        ref_out_seq.res=9'bz;
                        ref_out_seq.oflow=1'bz;
                        ref_out_seq.cout=1'bz;
                        ref_out_seq.g=1'bz;
                        ref_out_seq.l=1'bz;
                        ref_out_seq.e=1'bz;
                        ref_out_seq.err=1'bz;
                      end
                endcase
             end
           end //end of else mode=0
      end     //end of single input operands
  end      // end of check for input valid 01 or 10
else if (in_seq.inp_valid==2'b11)    //else if 11 directly
  begin
      if(in_seq.mode==1)
        begin
            case(in_seq.cmd)
                             `ADD:begin
                                    $display("I am here and i got 11 directly heyyy!!!! at %0t",$time);
                                    ref_out_seq.res=(in_seq.opa+in_seq.opb);
                                    ref_out_seq.cout=ref_out_seq.res[`n]?1:0;
                               $display("I gave result=%0d,cout=%0d",ref_out_seq.res,ref_out_seq.cout);
                                  end
                                 `SUB:begin
                                        ref_out_seq.res=(in_seq.opa-in_seq.opb);
                                        ref_out_seq.oflow=(in_seq.opa<in_seq.opb)?1:0;
                                         end
                                 `ADD_CIN:begin
                                            ref_out_seq.res=(in_seq.opa+in_seq.opb+in_seq.cin);
                                            ref_out_seq.cout=ref_out_seq.res[`n]?1:0;
                                         end
                                `SUB_CIN:begin
                                             ref_out_seq.res=(in_seq.opa-in_seq.opb-in_seq.cin);
                                  ref_out_seq.oflow=((in_seq.opa<in_seq.opb)||((in_seq.opa==in_seq.opb)&&in_seq.cin))?1:0;
                                         end
                                `CMP:begin
                                        ref_out_seq.e=(in_seq.opa==in_seq.opb)? 1'b1:1'b0;
                                        ref_out_seq.g=(in_seq.opa>in_seq.opb)? 1'b1:1'b0;
                                        ref_out_seq.l=(in_seq.opa<in_seq.opb)? 1'b1:1'b0;
                                      end
                           `INC_MUL:begin
                                     ref_out_seq.res=(in_seq.opa+1)*(in_seq.opb+1);
                                   end
                           `SHIFT_MUL:begin
                                       ref_out_seq.res=(in_seq.opa<<1)*(in_seq.opb);
                                     end
                           `INC_A:begin
                                   ref_out_seq.res=in_seq.opa+1;
                                  end
                           `DEC_A:begin
                                  ref_out_seq.res=in_seq.opa-1;
                                  end
                          `INC_B:begin
                                  ref_out_seq.res=in_seq.opb+1;
                                 end
                         `DEC_B:begin
                                 ref_out_seq.res=in_seq.opb-1;
                                end
                           default:begin
                                        ref_out_seq.res=9'bz;
                                        ref_out_seq.oflow=1'bz;
                                        ref_out_seq.cout=1'bz;
                                        ref_out_seq.g=1'bz;
                                        ref_out_seq.l=1'bz;
                                        ref_out_seq.e=1'bz;
                                        ref_out_seq.err=1'bz;
                                   end
                        endcase
                    end  //end of if mode==1
                  else               //else part for mode=0
                    begin
                      case(in_seq.cmd)
                        `AND:begin
                                ref_out_seq.res={1'b0,(in_seq.opa & in_seq.opb)};
                            end
                        `NAND:begin
                               ref_out_seq.res={1'b0,~(in_seq.opa & in_seq.opb)};
                            end
                        `OR:begin
                               ref_out_seq.res={1'b0,(in_seq.opa | in_seq.opb)};
                            end
                        `NOR:begin
                               ref_out_seq.res={1'b0,~(in_seq.opa | in_seq.opb)};
                            end
                        `XOR:begin;
                               ref_out_seq.res={1'b0,(in_seq.opa ^ in_seq.opb)};
                            end
                        `XNOR:begin
                               ref_out_seq.res={1'b0,~(in_seq.opa ^ in_seq.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=in_seq.opb[required_bits-1:0];
                                 ref_out_seq.res={1'b0,((in_seq.opa<<shift_value)|(in_seq.opa>>`n-shift_value))};
                                 if(in_seq.opb>`n-1)
                                  ref_out_seq.err=1;
                                end
                        `ROR_A_B:begin
                                 shift_value=in_seq.opb[required_bits-1:0];
                                 ref_out_seq.res={1'b0,((in_seq.opa>>shift_value)|(in_seq.opa<<`n-shift_value))};
                                if(in_seq.opb>`n-1)
                                  ref_out_seq.err=1;
                                end
                         `NOT_A:begin
                                 ref_out_seq.res={1'b0,~(in_seq.opa)};
                                end
                         `NOT_B:begin
                                ref_out_seq.res={1'b0,~(in_seq.opb)};
                                end
                         `SHR1_A:begin
                                 ref_out_seq.res={1'b0,(in_seq.opa>>1)};
                                 end
                        `SHL1_A:begin
                                ref_out_seq.res={1'b0,(in_seq.opa<<1)};
                                end
                        `SHR1_B:begin
                                 ref_out_seq.res={1'b0,(in_seq.opb>>1)};
                                end
                        `SHL1_B:begin
                                 ref_out_seq.res={1'b0,(in_seq.opb<<1)};
                                end

                        default:begin
                                 ref_out_seq.res=9'bz;
                                 ref_out_seq.oflow=1'bz;
                                 ref_out_seq.cout=1'bz;
                                 ref_out_seq.g=1'bz;
                                 ref_out_seq.l=1'bz;
                                 ref_out_seq.e=1'bz;
                                 ref_out_seq.err=1'bz;
                              end
                      endcase
                  end       //end of else mode==0
            end        //end of inp_valid=11 directly case
   else   //input valid is 00
     begin
       ref_out_seq.res=prev_res;
       ref_out_seq.oflow=prev_oflow;
       ref_out_seq.cout=prev_cout;
       ref_out_seq.g=prev_g;
       ref_out_seq.l=prev_l;
       ref_out_seq.e=prev_e;
       ref_out_seq.err=prev_err;
     end  //end of 00
  end    //end of ce=1
else   //if ce=0
    begin
       ref_out_seq.res=prev_res;
       ref_out_seq.oflow=prev_oflow;
       ref_out_seq.cout=prev_cout;
       ref_out_seq.g=prev_g;
       ref_out_seq.l=prev_l;
       ref_out_seq.e=prev_e;
       ref_out_seq.err=prev_err;
     end
  end   //end of else loop for reset!=1

        $display("Reference model putting values to scoreboard at %0t :OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,COUT=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,in_seq.opa,in_seq.opb,in_seq.cin,in_seq.ce,in_seq.mode,in_seq.cmd,in_seq.inp_valid,ref_out_seq.res,ref_out_seq.err,ref_out_seq.cout,ref_out_seq.oflow,ref_out_seq.g,ref_out_seq.l,ref_out_seq.e);

endtask  //end of reference model task


task run_phase(uvm_phase phase);
    super.run_phase(phase);
   repeat(1)@(vif_ref.ref_cb);
    forever begin
      $display("Inside forever begin loop of scoreboard at %0t",$time);
      act_agt_fifo.get(in_seq);
      `uvm_info("ACTIVE_MONITOR_TO_REFERENCE_MODEL", $sformatf("Got: %s", in_seq.sprint()), UVM_LOW)
      ref_out_seq=alu_seq_item::type_id::create("ref_out_seq");
      $display("Giving call to the reference model task at %0t",$time);
      reference_model_process(in_seq,ref_out_seq); //reference model task call
      $display("Reference model gave result as:%0d",ref_out_seq.res);
       prev_res=ref_out_seq.res;
       prev_err=ref_out_seq.err;
       prev_oflow=ref_out_seq.oflow;
       prev_cout=ref_out_seq.cout;
       prev_g=ref_out_seq.g;
       prev_l=ref_out_seq.l;
       prev_e=ref_out_seq.e;
       pas_agt_fifo.get(mon_out_seq);
      `uvm_info("PASSIVE_MONITOR_TO_REFERENCE_MODEL", $sformatf("Got: %s", mon_out_seq.sprint()), UVM_LOW)


      if(ref_out_seq.res===mon_out_seq.res)
       begin
         `uvm_info(get_full_name(),$sformatf("RES Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.res, mon_out_seq.res),UVM_LOW)
       end
       else
        begin
          `uvm_error(get_full_name(),$sformatf("RES Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.res, mon_out_seq.res))
        end
      if(ref_out_seq.cout===mon_out_seq.cout)
       begin
         `uvm_info(get_full_name(),$sformatf("COUT Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.cout, mon_out_seq.cout),UVM_LOW)
       end
      else
        begin
          `uvm_error(get_full_name(),$sformatf("COUT Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.cout, mon_out_seq.cout))
        end
      if(ref_out_seq.oflow===mon_out_seq.oflow)
       begin
         `uvm_info(get_full_name(),$sformatf("OFLOW Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.oflow, mon_out_seq.oflow),UVM_LOW)
       end
      else
        begin
          `uvm_error(get_full_name(),$sformatf("OFLOW Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.oflow, mon_out_seq.oflow))
        end
      if(ref_out_seq.err===mon_out_seq.err)
        begin
          `uvm_info(get_full_name(),$sformatf("ERR Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.err, mon_out_seq.err),UVM_LOW)
        end
      else
        begin
          `uvm_error(get_full_name(),$sformatf("ERR Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.err, mon_out_seq.err))
        end
      if(ref_out_seq.g===mon_out_seq.g)
       begin
         `uvm_info(get_full_name(),$sformatf("G Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.g, mon_out_seq.g),UVM_LOW)
       end
      else
       begin
         `uvm_error(get_full_name(),$sformatf("G Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.g, mon_out_seq.g))
       end
      if(ref_out_seq.l===mon_out_seq.l)
        begin
          `uvm_info(get_full_name(),$sformatf("L Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.l, mon_out_seq.l),UVM_LOW)
        end
      else
        begin
          `uvm_error(get_full_name(),$sformatf("L Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.l, mon_out_seq.l))
        end
      if(ref_out_seq.e===mon_out_seq.e)
       begin
         `uvm_info(get_full_name(),$sformatf("E Comparison Pass: REF=%0d||MON=%0d",ref_out_seq.e, mon_out_seq.e),UVM_LOW)
       end
      else
        begin
          `uvm_error(get_full_name(),$sformatf("E Comparison Fail: REF=%0d||MON=%0d",ref_out_seq.e, mon_out_seq.e))
        end
    end
 endtask

endclass
