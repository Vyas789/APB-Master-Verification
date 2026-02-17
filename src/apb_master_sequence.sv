class apb_master_sequence extends uvm_sequence#(apb_master_sequence_item);
  `uvm_object_utils(apb_master_sequence)
  apb_master_sequence_item req;
  
  function new(string name="apb_master_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        req=apb_master_sequence_item::type_id::create("req");
        wait_for_grant();
        if(!req.randomize())
          `uvm_error(get_full_name(), "Randomization failed");
        send_request(req);
        wait_for_item_done();
      end
  endtask
  
endclass

class apb_write_read_sequence extends uvm_sequence#(apb_master_sequence_item);
  `uvm_object_utils(apb_write_read_sequence)
  
  bit [31:0] target_addr;

  function new(string name="apb_write_read_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
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
    `uvm_info(get_full_name(), $sformatf("Completed Write followed by Read at Addr: %0h", target_addr), UVM_LOW);

  endtask
  
endclass
  
    
