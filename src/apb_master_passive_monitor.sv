class apb_master_passive_monitor extends uvm_monitor;
  `uvm_component_utils(apb_master_passive_monitor)

  uvm_analysis_port#(apb_master_sequence_item) pas_mon_port;
  virtual apb_interface vif;
  apb_master_sequence_item seq;
  
  function new(string name="apb_master_passive_monitor",uvm_component parent=null);
    super.new(name,parent);
    pas_mon_port=new("pas_mon_port",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_interface)::get(this,"","vif",vif))
      `uvm_fatal(get_full_name(),"Passive monitor didn't get interface handle");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    repeat(1)@(vif.apb_pas_mon_cb);
    forever begin
      repeat(1)@(vif.apb_pas_mon_cb);
      if (vif.apb_pas_mon_cb.PSEL && vif.apb_pas_mon_cb.PENABLE && vif.apb_pas_mon_cb.PREADY) begin
      	seq = apb_master_sequence_item::type_id::create("seq");
//         seq.PSEL          = vif.apb_pas_mon_cb.PSEL;
// 		seq.PENABLE       = vif.apb_pas_mon_cb.PENABLE;
		seq.PADDR         = vif.apb_pas_mon_cb.PADDR;
        seq.PWRITE        = vif.apb_pas_mon_cb.PWRITE;
        seq.PSTRB         = vif.apb_pas_mon_cb.PSTRB;
        seq.transfer_done = vif.apb_pas_mon_cb.transfer_done;
        if (seq.PWRITE) begin
            seq.PWDATA = vif.apb_pas_mon_cb.PWDATA;
            seq.rdata_out = 0;
          `uvm_info("APB_MON_WRITE", 
                    $sformatf("Captured WRITE Transaction: Addr: 0x%0h Data: 0x%0h Strb: %b Resp:  %s", 
                    seq.PADDR, seq.PWDATA, seq.PSTRB, (seq.error ? "SLVERR" : "OKAY")), 
                    UVM_MEDIUM)
        end else begin
            seq.PWDATA = 0;
            seq.rdata_out = vif.apb_pas_mon_cb.rdata_out; 
          `uvm_info("APB_MON_READ", 
                    $sformatf("Captured READ  Transaction: Addr: 0x%0h Data: 0x%0h Resp:  %s", 
                    seq.PADDR, seq.rdata_out, (seq.error ? "SLVERR" : "OKAY")), 
                    UVM_MEDIUM)
        end
        seq.error = vif.apb_pas_mon_cb.error; 
//         `uvm_info(get_full_name, $sformatf("Passive Monitor Sampled: %s", seq.sprint()), UVM_LOW)
        pas_mon_port.write(seq);
    end
    end
  endtask
endclass
