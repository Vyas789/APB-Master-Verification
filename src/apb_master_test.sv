class apb_master_test extends uvm_test;
  `uvm_component_utils(apb_master_test)
  apb_master_sequence seq;
  apb_master_environment env;
  
  function new(string name="apb_master_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=apb_master_environment::type_id::create("env",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=apb_master_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of test case",UVM_LOW);
  endtask
  
endclass

class apb_master_write_read_test extends uvm_test;
  `uvm_component_utils(apb_master_write_read_test)
  apb_write_read_sequence seq;
  apb_master_environment env;
  
  function new(string name="apb_master_write_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=apb_master_environment::type_id::create("env",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=apb_write_read_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of test case",UVM_LOW);
  endtask
  
endclass
