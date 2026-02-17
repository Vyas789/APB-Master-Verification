class apb_master_environment extends uvm_env;
  `uvm_component_utils(apb_master_environment)
  apb_master_passive_agent pas_agt;
  apb_master_active_agent act_agt;
  apb_master_scoreboard scb;
  apb_master_subscriber sub;
  
  function new(string name="apb_master_environment",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_active_passive_enum)::set(this,"act_agt","is_active",UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this,"pas_agt","is_active",UVM_PASSIVE);
    act_agt=apb_master_active_agent::type_id::create("act_agt",this);
    pas_agt=apb_master_passive_agent::type_id::create("pas_agt",this);
    scb=apb_master_scoreboard::type_id::create("scb",this);
//     sub=apb_master_subscriber::type_id::create("sub",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    act_agt.act_mon.act_mon_port.connect(scb.act_mon_fifo.analysis_export);
    pas_agt.pas_mon.pas_mon_port.connect(scb.pas_mon_fifo.analysis_export);
//     act_agt.act_mon.act_mon_port.connect(sub.analysis_export);
//     pas_agt.pas_mon.pas_mon_port.connect(sub.pas_mon_imp);
  endfunction
    
endclass
