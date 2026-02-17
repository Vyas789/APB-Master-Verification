`include"apb_master_defines.sv"
class apb_master_subscriber extends uvm_subscriber#(apb_master_sequence_item);
  `uvm_component_utils(apb_master_subscriber)
  `uvm_analysis_imp_decl(_pas_mon)
  uvm_analysis_imp_pas_mon#(apb_master_sequence_item,apb_master_subscriber)pas_mon_imp;  //one implementation port is inbuilt in subscriber
  real inp_cov,op_cov;
  apb_master_sequence_item act_item,pas_item;
  
  covergroup inp_cg;
    coverpoint act_item.transfer{ 
                                  bins tr_low={0}; 
                                  bins tr_high={1};
                                }
    coverpoint act_item.write_read{ 
                                    bins wr_tr={0}; 
                                    bins rd_tr={1};
                                  }
    coverpoint act_item.addr_in{ 
                                  bins rd_adr_first_half[]={[0 : (2**`ADDR_WIDTH)/2 - 1]}; 
                                  bins rd_adr_second_half[]={[ (2**`ADDR_WIDTH)/2 : (2**`ADDR_WIDTH) - 1 ]};
                               }
    coverpoint act_item.wdata_in {
                                   bins wr_dt_first_half[]  = { [0 : (2**`DATA_WIDTH)/2 - 1] };
                                   bins wr_dt_second_half []= { [ (2**`DATA_WIDTH)/2 : (2**`DATA_WIDTH)-1 ] };
                                 }

    coverpoint act_item.strb_in{ 
                                 bins strb_bins[]={[0:2**((`DATA_WIDTH/8)-1)]};
                               }
    coverpoint act_item.PSLVERR{ 
                                 bins error={0}; 
                                 bins no_error={1};
                               }
    coverpoint act_item.PREADY{ 
                                 bins ready={0}; 
                                 bins not_ready={1};
                              }
    coverpoint act_item.PRDATA {
                                 bins pr_dt_first_half  = { [0 : (2**`DATA_WIDTH)/2 - 1] };
                                 bins pr_dt_second_half = { [ (2**`DATA_WIDTH)/2 : (2**`DATA_WIDTH)-1 ] };
                               }
  endgroup
  
  covergroup op_cg;
    coverpoint pas_item.rdata_out {
                                    bins rd_dt_first_half  = { [0 : (2**`DATA_WIDTH)/2 - 1] };
                                    bins rd_dt_second_half = { [ (2**`DATA_WIDTH)/2 : (2**`DATA_WIDTH)-1 ] };
                                   }

    coverpoint pas_item.PADDR{ 
                               bins paddr_first_half[]={[0 : (2**`ADDR_WIDTH)/2 - 1]}; 
                               bins paddr_second_half[]={[ (2**`ADDR_WIDTH)/2 : (2**`ADDR_WIDTH) - 1 ]};
                             }
    coverpoint pas_item.PSEL{ 
                              bins not_selected={0}; 
                              bins selected={1};
                            }
    coverpoint pas_item.PENABLE{ 
                                bins not_enabled={0}; 
                                bins enabled={1};
                               }
    coverpoint pas_item.PWDATA {
                                 bins pwdata_first_half[]  = { [0 : (2**`DATA_WIDTH)/2 - 1] };
                                 bins pwdata_second_half []= { [ (2**`DATA_WIDTH)/2 : (2**`DATA_WIDTH)-1 ] };
                               } 
    coverpoint pas_item.PWRITE{ 
                                bins read={0}; 
                                bins write={1};
                              }
    coverpoint pas_item.PSTRB{ 
                               bins pstrb_bins[]={[0:2**((`DATA_WIDTH/8)-1)]};
                             }
    coverpoint pas_item.transfer_done{ 
                                       bins not_done={0}; 
                                       bins done={1};
                                     }
    coverpoint pas_item.error{ 
                              bins error_bin={1}; 
                              bins no_error_bin={0};
                             }  
  endgroup
  
  function new(string name="apb_master_subscriber",uvm_component parent=null);
    super.new(name,parent);
    inp_cg=new();
    op_cg=new();
    pas_mon_imp=new("pas_mon_imp",this);
  endfunction
  
  virtual function void write(apb_master_sequence_item t);
   act_item=t;
   inp_cg.sample();
  endfunction
  
  virtual function void write_pas_mon(apb_master_sequence_item t);
   pas_item=t;
   op_cg.sample();
  endfunction
  
  function void extract_phase(uvm_phase phase);
   super.extract_phase(phase);
    inp_cov=inp_cg.get_coverage();
    op_cov=op_cg.get_coverage();
  endfunction
  
  function void report_phase(uvm_phase phase);
   super.report_phase(phase);
    `uvm_info(get_type_name,$sformatf("[INPUT]Coverage ------> %0.2f%%,",inp_cov),UVM_MEDIUM);
    `uvm_info(get_type_name,$sformatf("[OUTPUT]Coverage ------> %0.2f%%",op_cov),UVM_MEDIUM);
  endfunction
 
endclass
