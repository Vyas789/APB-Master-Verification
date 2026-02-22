class apb_master_test extends uvm_test;
  `uvm_component_utils(apb_master_test)
  apb_master_sequence seq;
  apb_master_environment env;
  
  function new(string name="apb_master_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=apb_master_environment::type_id::create("env",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
//     seq=apb_master_sequence::type_id::create("seq");
//     phase.raise_objection(this);
//     seq.start(env.act_agt.seqr);
//     phase.drop_objection(this);
//     `uvm_info(get_type_name(),"End of test case",UVM_LOW);
  endtask
  
endclass

class apb_no_transfer_test extends apb_master_test;
  `uvm_component_utils(apb_no_transfer_test)
  
  apb_no_transfer_seq seq;
  
  function new(string name = "apb_no_transfer_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq = apb_no_transfer_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(), $sformatf("End of no transfer test"), UVM_MEDIUM);
  endtask
endclass

class apb_master_r_wait_test extends apb_master_test;
  `uvm_component_utils(apb_master_r_wait_test)
  
  apb_master_r_wait_seq seq;
  
  function new(string name = "apb_master_r_wait_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq = apb_master_r_wait_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(), $sformatf("End of transfer with delays in between test"), UVM_MEDIUM);
  endtask
endclass

class apb_master_wr_test extends apb_master_test;
  `uvm_component_utils(apb_master_wr_test)
  apb_master_wr_seq seq;
  
  function new(string name="apb_master_wr_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq = apb_master_wr_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of write only test case",UVM_LOW);
  endtask
  
endclass

class apb_master_rd_test extends apb_master_test;
  `uvm_component_utils(apb_master_rd_test)
  apb_master_rd_seq seq;
  
  function new(string name="apb_master_rd_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq = apb_master_rd_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of read only test case",UVM_LOW);
  endtask
  
endclass

class apb_master_normal_test extends apb_master_test;
  `uvm_component_utils(apb_master_normal_test)
  apb_master_normal_seq seq;
  
  function new(string name="apb_master_normal_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq = apb_master_normal_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of read only test case",UVM_LOW);
  endtask
  
endclass

class apb_master_write_read_test extends apb_master_test;
  `uvm_component_utils(apb_master_write_read_test)
  apb_write_read_seq seq;
  
  function new(string name="apb_master_write_read_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=apb_write_read_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of write followed by read from same addr test case",UVM_LOW);
  endtask
  
endclass

class apb_master_strb_test extends apb_master_test;
  `uvm_component_utils(apb_master_strb_test)
  apb_master_strb_seq seq;
  
  function new(string name="apb_master_strb_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq = apb_master_strb_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of write followed by read from same addr test case",UVM_LOW);
  endtask
  
endclass

class apb_master_regression_test extends apb_master_test;
  `uvm_component_utils(apb_master_regression_test)
  apb_master_regression_seq seq;
  
  function new(string name = "apb_master_regression_test",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq = apb_master_regression_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.act_agt.seqr);
    phase.drop_objection(this);
    `uvm_info(get_type_name(),"End of regression test case",UVM_LOW);
  endtask
  
endclass
