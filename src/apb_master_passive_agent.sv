class apb_master_passive_agent extends uvm_agent;
  `uvm_component_utils(apb_master_passive_agent)
  
  apb_master_passive_monitor pas_mon;
  
  function new(string name="apb_master_passive_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uvm_active_passive_enum)::get(this,"","is_active",is_active))
       `uvm_fatal(get_full_name(),"Agent not set")
      pas_mon=apb_master_passive_monitor::type_id::create("pas_mon",this);
   endfunction
       
 endclass
         
    
