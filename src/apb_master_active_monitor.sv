class apb_master_active_monitor extends uvm_monitor;
  `uvm_component_utils(apb_master_active_monitor)
  
  uvm_analysis_port #(apb_master_sequence_item) act_mon_port;
  virtual apb_interface vif;
  apb_master_sequence_item seq;
  
  function new(string name="apb_master_active_monitor", uvm_component parent=null);
    super.new(name, parent);
    act_mon_port = new("act_mon_port", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_interface)::get(this, "", "vif", vif))
      `uvm_fatal(get_full_name(), "Active monitor didn't get interface handle");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    repeat(1)@(vif.apb_act_mon_cb);
    forever begin
      while (vif.apb_act_mon_cb.PSEL !== 1 || vif.apb_act_mon_cb.PENABLE !== 0) begin
        repeat(1)@(vif.apb_act_mon_cb);
      end
      seq = apb_master_sequence_item::type_id::create("seq");
//       seq.transfer   = vif.apb_act_mon_cb.transfer;
      seq.write_read = vif.apb_act_mon_cb.write_read;
      seq.addr_in    = vif.apb_act_mon_cb.addr_in;
      seq.wdata_in   = vif.apb_act_mon_cb.wdata_in;
      seq.strb_in    = vif.apb_act_mon_cb.strb_in;
      repeat(1)@(vif.apb_act_mon_cb);
      while (vif.apb_act_mon_cb.PREADY !== 1) begin
        repeat(1)@(vif.apb_act_mon_cb); 
      end
//       seq.PREADY  = vif.apb_act_mon_cb.PREADY;
      if(seq.write_read == 0) begin
         seq.PRDATA = vif.apb_act_mon_cb.PRDATA;
        `uvm_info("ACT_MON_READ", 
                  $sformatf("Active Monitor READ: Addr: 0x%0h Data: 0x%0h Resp:  %s", 
                  seq.addr_in, seq.PRDATA, (seq.PSLVERR ? "SLVERR" : "OKAY")), 
                  UVM_MEDIUM)
      end else begin    
         seq.PRDATA = 0;
        `uvm_info("ACT_MON_WRITE", 
                  $sformatf("Active Monitor WRITE: Addr: 0x%0h Data: 0x%0h Strb: %b Resp:  %s", 
                  seq.addr_in, seq.wdata_in, seq.strb_in, (seq.PSLVERR ? "SLVERR" : "OKAY")), 
                  UVM_MEDIUM)
      end
       seq.PSLVERR = vif.apb_act_mon_cb.PSLVERR;
       seq.transfer_done = vif.apb_act_mon_cb.transfer_done;
      act_mon_port.write(seq);
//       repeat(1)@(vif.apb_act_mon_cb);
    end
  endtask
endclass
