class apb_master_active_agent extends uvm_agent;
  `uvm_component_utils(apb_master_active_agent)
  apb_master_driver drv;
  apb_master_active_monitor act_mon;
  apb_master_sequencer seqr;
  
  function new(string name="apb_master_active_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
       `uvm_fatal(get_full_name(),"Agent not set")
      if(get_is_active() == UVM_ACTIVE)
         begin
           drv=apb_master_driver::type_id::create("drv",this);
           seqr=apb_master_sequencer::type_id::create("seqr",this);
         end
       act_mon=apb_master_active_monitor::type_id::create("act_mon",this);
   endfunction
       
   function void connect_phase(uvm_phase phase);
     if(get_is_active==UVM_ACTIVE)
       begin
         drv.seq_item_port.connect(seqr.seq_item_export);
       end
   endfunction
 endclass
         
    
