class apb_master_sequence extends uvm_sequence#(apb_master_sequence_item);
  `uvm_object_utils(apb_master_sequence)
  apb_master_sequence_item req;
  
  function new(string name="apb_master_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
//     repeat(10)
//       begin
//         req=apb_master_sequence_item::type_id::create("req");
//         wait_for_grant();
//         if(!req.randomize())
//           `uvm_error(get_full_name(), "Randomization failed");
//         send_request(req);
//         wait_for_item_done();
//       end
  endtask
  
endclass

class apb_no_transfer_seq extends apb_master_sequence;
  `uvm_object_utils(apb_no_transfer_seq)
  
  function new(string name = "apb_no_transfer_seq");
    super.new(name);
  endfunction
  
  task body();
    apb_master_sequence_item req = apb_master_sequence_item::type_id::create("req");
    start_item(req);
    if(!req.randomize() with {transfer == 0;})
      `uvm_error(get_full_name(), $sformatf("Randomization failed"));
    finish_item(req);
    `uvm_info(get_full_name(), $sformatf("completed no tranfer sequence"), UVM_MEDIUM);
  endtask
endclass
    
class apb_master_r_wait_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_r_wait_seq)

  int wait_r = 5;
  
//   constraint c_wait_cycles {wait_cycles inside {[1:5]};}

  function new(string name = "apb_master_r_wait_seq");
    super.new(name);
  endfunction
  
  task body();
    apb_master_sequence_item req1, req2, req3;
    
    req1 = apb_master_sequence_item::type_id::create("req1");
    start_item(req1);
    if(!req1.randomize() with {transfer == 1;})
      `uvm_error(get_full_name(), "First transfer randomization failed");
    finish_item(req1);
    
    `uvm_info(get_full_name(), "Completed First Valid Transfer", UVM_MEDIUM);

    `uvm_info(get_full_name(), $sformatf("Inserting %0d wait cycles...", wait_r), UVM_MEDIUM);
    repeat(wait_r) begin
      req2 = apb_master_sequence_item::type_id::create("req2");
      start_item(req2);
      if(!req2.randomize() with { transfer == 0; })
        `uvm_error(get_full_name(), "Idle transfer randomization failed");
      finish_item(req2);
    end
    
    req3 = apb_master_sequence_item::type_id::create("req3");
    start_item(req3);
    if(!req3.randomize() with { transfer == 1; })
      `uvm_error(get_full_name(), "Second transfer randomization failed");
    finish_item(req3);
    
    `uvm_info(get_full_name(), "Completed Second Valid Transfer after wait", UVM_MEDIUM);

  endtask
endclass

class apb_master_wr_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_wr_seq)
  apb_master_sequence_item req;
  
  function new(string name="apb_master_wr_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        req=apb_master_sequence_item::type_id::create("req");
        wait_for_grant();
        if(!req.randomize() with {write_read == 1;})
          `uvm_error(get_full_name(), "Randomization failed");
        send_request(req);
        wait_for_item_done();
      end
  endtask
  
endclass

class apb_master_rd_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_rd_seq)
  apb_master_sequence_item req;
  
  function new(string name="apb_master_rd_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        req=apb_master_sequence_item::type_id::create("req");
        wait_for_grant();
        if(!req.randomize() with {write_read == 0;})
          `uvm_error(get_full_name(), "Randomization failed");
        send_request(req);
        wait_for_item_done();
      end
  endtask
  
endclass

class apb_master_normal_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_normal_seq)

  function new(string name="apb_master_normal_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(10) begin
    apb_master_sequence_item req = apb_master_sequence_item::type_id::create("req");   
    start_item(req);
    if(!req.randomize() with { 
        transfer == 1; 
        wait_cycles inside {[1:5]};
        PSLVERR == 0; 
    }) begin
      `uvm_error(get_full_name(), "master_normal_test Randomization failed");
    end
    finish_item(req);
    end
    `uvm_info(get_full_name(), "Completed Normal Transfer (0 wait states, PREADY=1 immediately)", UVM_LOW);
  endtask
  
endclass

class apb_write_read_seq extends apb_master_sequence;
  `uvm_object_utils(apb_write_read_seq)
  
  bit [31:0] target_addr;

  function new(string name="apb_write_read_seq");
    super.new(name);
  endfunction
  
  task body();
    repeat(10) begin
    apb_master_sequence_item req;
    req = apb_master_sequence_item::type_id::create("req");
    
    start_item(req); 
    if(!req.randomize() with { 
        write_read == 1; 
      }) 
      `uvm_error(get_full_name(), "Write Randomization failed");
    target_addr = req.addr_in; 
    finish_item(req); 
    req = apb_master_sequence_item::type_id::create("req");
    start_item(req);
    if(!req.randomize() with { 
        write_read == 0; 
        addr_in == target_addr; 
      }) 
      `uvm_error(get_full_name(), "Read Randomization failed");
    
    finish_item(req);
    `uvm_info(get_full_name(), $sformatf("Completed Write followed by Read at Addr: %0h", target_addr), UVM_MEDIUM);
    end
  endtask
  
endclass

class apb_master_strb_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_strb_seq)

  function new(string name="apb_master_strb_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(10) begin
    apb_master_sequence_item req = apb_master_sequence_item::type_id::create("req");
    
    start_item(req);
    if(!req.randomize() with { 
        transfer == 1; 
        write_read == 0; 
        strb_in != 4'b0000; 
      wait_cycles inside {[0:5]};  
    }) begin
      `uvm_error(get_full_name(), "Strobe Write randomization failed");
    end
    finish_item(req);
    `uvm_info(get_full_name(), $sformatf("Completed Strobe Write with PSTRB: %0b", req.strb_in), UVM_LOW);
    end
  endtask
endclass

class apb_master_regression_seq extends apb_master_sequence;
  `uvm_object_utils(apb_master_regression_seq)

  function new(string name="apb_master_regression_seq");
    super.new(name);
  endfunction

   task body();
    apb_no_transfer_seq       seq_no_trans;
    apb_master_r_wait_seq     seq_r_wait;
    apb_master_wr_seq         seq_wr;
    apb_master_rd_seq         seq_rd;
    apb_master_normal_seq     seq_normal;
    apb_write_read_seq        seq_wr_rd;
    apb_master_strb_seq       seq_strb;

    `uvm_info(get_full_name(), "==============================================", UVM_LOW)
    `uvm_info(get_full_name(), "    STARTING APB MASTER REGRESSION SEQUENCE   ", UVM_LOW)
    `uvm_info(get_full_name(), "==============================================", UVM_LOW)
    
    `uvm_info(get_full_name(), "Running 1: apb_no_transfer_seq", UVM_LOW)
    seq_no_trans = apb_no_transfer_seq::type_id::create("seq_no_trans");
    seq_no_trans.start(m_sequencer, this);

    `uvm_info(get_full_name(), "Running 2: apb_master_r_wait_seq", UVM_LOW)
    seq_r_wait = apb_master_r_wait_seq::type_id::create("seq_r_wait");
    seq_r_wait.start(m_sequencer, this);

    `uvm_info(get_full_name(), "Running 3: apb_master_wr_seq", UVM_LOW)
    seq_wr = apb_master_wr_seq::type_id::create("seq_wr");
    seq_wr.start(m_sequencer, this);

     `uvm_info(get_full_name(), "Running 4: apb_master_rd_seq", UVM_LOW)
    seq_rd = apb_master_rd_seq::type_id::create("seq_rd");
    seq_rd.start(m_sequencer, this);

    `uvm_info(get_full_name(), "Running 5: apb_master_normal_seq", UVM_LOW)
    seq_normal = apb_master_normal_seq::type_id::create("seq_normal");
    seq_normal.start(m_sequencer, this);

    `uvm_info(get_full_name(), "Running 6: apb_write_read_seq", UVM_LOW)
    seq_wr_rd = apb_write_read_seq::type_id::create("seq_wr_rd");
    seq_wr_rd.start(m_sequencer, this);

    `uvm_info(get_full_name(), "Running 7: apb_master_strb_seq", UVM_LOW)
    seq_strb = apb_master_strb_seq::type_id::create("seq_strb");
    seq_strb.start(m_sequencer, this);

    `uvm_info(get_full_name(), "==============================================", UVM_LOW)
    `uvm_info(get_full_name(), "    FINISHED APB MASTER REGRESSION SEQUENCE   ", UVM_LOW)
    `uvm_info(get_full_name(), "==============================================", UVM_LOW)

  endtask
endclass
