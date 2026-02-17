`include"apb_master_defines.sv"
class apb_master_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_master_scoreboard)
  
  uvm_tlm_analysis_fifo#(apb_master_sequence_item) act_mon_fifo;
  uvm_tlm_analysis_fifo#(apb_master_sequence_item) pas_mon_fifo;
  
  apb_master_sequence_item act_item, pas_item;
  
  int match_count    = 0;   
  int mismatch_count = 0;     
  int read_count     = 0;     
  int write_count    = 0;    
  int error_count    = 0;     
  
  bit [`DATA_WIDTH-1:0] golden_mem [bit[`ADDR_WIDTH-1:0]];
  bit[`DATA_WIDTH-1:0] expected_rdata;
  
  function new(string name="apb_master_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    act_mon_fifo = new("act_mon_fifo", this);
    pas_mon_fifo = new("pas_mon_fifo", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      act_mon_fifo.get(act_item);
      pas_mon_fifo.get(pas_item);
      compare_transactions(act_item, pas_item);
    end
  endtask
  
  task compare_transactions(apb_master_sequence_item act_txn, apb_master_sequence_item pas_txn);
    
    bit transaction_error = 0;
    
    `uvm_info("SB_COMPARE_START",
              $sformatf("====== Starting Transaction Comparison at %0t ======", $time),
              UVM_HIGH)

    if(act_txn.addr_in !== pas_txn.PADDR) begin
      `uvm_error("SB_ADDR_MISMATCH",
                 $sformatf("ADDRESS MISMATCH!\n\t\tExpected (Active Monitor): 0x%0h\n\t\tObserved (Passive Monitor): 0x%0h\n\t\tTime: %0t",
                           act_txn.addr_in, pas_txn.PADDR, $time))
      transaction_error = 1;
    end else begin
      `uvm_info("SB_PASS",
                $sformatf("ADDRESS MATCH: 0x%0h", act_txn.addr_in),
                UVM_MEDIUM)
    end
    
    if(act_txn.write_read !== pas_txn.PWRITE) begin
      `uvm_error("SB_DIRECTION_MISMATCH",
                 $sformatf("DIRECTION MISMATCH!\n\t\tExpected (Active Monitor): %s\n\t\tObserved (Passive Monitor): %s\n\t\tTime: %0t",
                           act_txn.write_read ? "WRITE" : "READ",
                           pas_txn.PWRITE ? "WRITE" : "READ",
                           $time))
      transaction_error = 1;
    end else begin
      `uvm_info("SB_PASS",
                $sformatf("DIRECTION MATCH: %s", act_txn.write_read ? "WRITE" : "READ"),
                UVM_MEDIUM)
    end
    
    if(act_txn.write_read == 1) begin 
      if(act_txn.strb_in !== pas_txn.PSTRB) begin
        `uvm_error("SB_STRB_MISMATCH",
                   $sformatf("BYTE STROBE MISMATCH!\n\t\tExpected (Active Monitor): 0x%0h\n\t\tObserved (Passive Monitor): 0x%0h\n\t\tTime: %0t",
                             act_txn.strb_in, pas_txn.PSTRB, $time))
        transaction_error = 1;
      end else begin
        `uvm_info("SB_PASS",
                  $sformatf("STROBE MATCH: 0x%0h", act_txn.strb_in),
                  UVM_MEDIUM)
      end
    end

    if(act_txn.write_read == 1) begin
      // ---- WRITE OPERATION ----
      write_count++;
      
      `uvm_info("SB_WRITE", "Processing WRITE transaction...", UVM_MEDIUM)

      if(act_txn.wdata_in !== pas_txn.PWDATA) begin
        `uvm_error("SB_WDATA_MISMATCH",
                   $sformatf("WRITE DATA MISMATCH!\n\t\tExpected (Active Monitor): 0x%0h\n\t\tObserved (Passive Monitor): 0x%0h\n\t\tTime: %0t",
                             act_txn.wdata_in, pas_txn.PWDATA, $time))
        transaction_error = 1;
      end else begin
        `uvm_info("SB_PASS",
                  $sformatf("WRITE DATA MATCH: 0x%0h", act_txn.wdata_in),
                  UVM_MEDIUM)
      end

      update_golden_mem(pas_txn.PADDR, pas_txn.PWDATA, pas_txn.PSTRB);
      
    end else begin
      // ---- READ OPERATION ----
      read_count++;
      
      `uvm_info("SB_READ", "Processing READ transaction...", UVM_MEDIUM)

      expected_rdata = read_golden_mem(pas_txn.PADDR);

      if(act_txn.PRDATA !== expected_rdata) begin
        `uvm_error("SB_RDATA_MISMATCH",
                   $sformatf("READ DATA MISMATCH!\n\t\tExpected (Golden Mem): 0x%0h\n\t\tObserved (Bus): 0x%0h\n\t\tAddress: 0x%0h\n\t\tTime: %0t",
                             expected_rdata, act_txn.PRDATA, pas_txn.PADDR, $time))
        transaction_error = 1;
      end else begin
        `uvm_info("SB_PASS",
                  $sformatf("READ DATA MATCH: 0x%0h (Address: 0x%0h)", 
                            act_txn.PRDATA, pas_txn.PADDR),
                  UVM_MEDIUM)
      end

      if(pas_txn.rdata_out !== act_txn.PRDATA) begin
        `uvm_error("SB_MONITOR_MISMATCH",
                   $sformatf("MONITOR DATA MISMATCH!\n\t\tActive Monitor: 0x%0h\n\t\tPassive Monitor: 0x%0h\n\t\tTime: %0t",
                             act_txn.PRDATA, pas_txn.rdata_out, $time))
        transaction_error = 1;
      end else begin
        `uvm_info("SB_PASS",
                  $sformatf("MONITOR CONSISTENCY: Both captured 0x%0h", act_txn.PRDATA),
                  UVM_MEDIUM)
      end
    end

    if(act_txn.PSLVERR !== pas_txn.error) begin
      `uvm_error("SB_PSLVERR_MISMATCH",
                 $sformatf("PSLVERR MISMATCH!\n\t\tExpected (Active Monitor): %0b\n\t\tObserved (Passive Monitor): %0b\n\t\tTime: %0t",
                           act_txn.PSLVERR, pas_txn.error, $time))
      transaction_error = 1;
    end else if(act_txn.PSLVERR == 1) begin
      error_count++;
      `uvm_info("SB_PASS",
                $sformatf("PSLVERR MATCH: Slave error detected as expected"),
                UVM_MEDIUM)
    end else begin
      `uvm_info("SB_PASS",
                $sformatf("PSLVERR MATCH: No slave error (%0b)", act_txn.PSLVERR),
                UVM_MEDIUM)
    end

    
    if(!transaction_error) begin
      match_count++;
      `uvm_info("SB_TRANSACTION_PASS",
                $sformatf("======✓ TRANSACTION PASSED ======\n\t\tAll fields matched correctly at %0t",
                          $time),
                UVM_MEDIUM)
    end else begin
      mismatch_count++;
      `uvm_error("SB_TRANSACTION_FAIL",
                 $sformatf("======✗ TRANSACTION FAILED ======\n\t\tOne or more mismatches detected at %0t",
                           $time))
    end
    
  endtask

  function void update_golden_mem(bit [`ADDR_WIDTH-1:0] addr, bit [`DATA_WIDTH-1:0] data, bit [`DATA_WIDTH/8-1:0] strb);
    
    bit [`DATA_WIDTH-1:0] current_value;

    if(golden_mem.exists(addr)) begin
      current_value = golden_mem[addr];
    end else begin
      current_value = '0;
    end
    

    for(int i = 0; i < (`DATA_WIDTH/8); i++) begin
      if(strb[i]) begin
        current_value[8*i+7 -: 8] = data[8*i+7 -: 8];
      end
    end
    golden_mem[addr] = current_value;
    
    `uvm_info("SB_GMEM_UPDATE",
              $sformatf("Golden Memory UPDATED:\n\t\tAddress: 0x%0h\n\t\tNew Data: 0x%0h\n\t\tStrobe: 0x%0h",
                        addr, current_value, strb),
              UVM_MEDIUM)
  endfunction

  function bit [`DATA_WIDTH-1:0] read_golden_mem(bit [`ADDR_WIDTH-1:0] addr);
    if(golden_mem.exists(addr)) begin
      `uvm_info("SB_GMEM_READ",
                $sformatf("Golden Memory READ:\n\t\tAddress: 0x%0h\n\t\tData: 0x%0h",
                          addr, golden_mem[addr]),
                UVM_HIGH)
      return golden_mem[addr];
    end else begin
      `uvm_warning("SB_GMEM_UNINIT",
                   $sformatf("Reading uninitialized address: 0x%0h (returning 0x00)", addr))
      return '0;
    end
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    // Print test summary
    `uvm_info("SB_REPORT", "========================================", UVM_LOW)
    `uvm_info("SB_REPORT", "     APB MASTER SCOREBOARD REPORT       ", UVM_LOW)
    `uvm_info("SB_REPORT", "========================================", UVM_LOW)
    `uvm_info("SB_REPORT", 
              $sformatf("Total Transactions Matched:    %0d", match_count),
              UVM_LOW)
    `uvm_info("SB_REPORT",
              $sformatf("Total Transactions Mismatched: %0d", mismatch_count),
              UVM_LOW)
    `uvm_info("SB_REPORT", "", UVM_LOW)
    `uvm_info("SB_REPORT",
              $sformatf("Total READ Operations:         %0d", read_count),
              UVM_LOW)
    `uvm_info("SB_REPORT",
              $sformatf("Total WRITE Operations:        %0d", write_count),
              UVM_LOW)
    `uvm_info("SB_REPORT",
              $sformatf("Total Slave Errors:            %0d", error_count),
              UVM_LOW)
    `uvm_info("SB_REPORT", "========================================", UVM_LOW)

    if(mismatch_count == 0 && (match_count > 0)) begin
      `uvm_info("SB_FINAL_VERDICT",
                " TEST PASSED \n\t\tAll transactions verified successfully!",
                UVM_LOW)
    end else begin
      `uvm_error("SB_FINAL_VERDICT",
                 $sformatf(" TEST FAILED \n\t\t%0d mismatches detected out of %0d transactions",
                           mismatch_count, match_count + mismatch_count))
    end
    
  endfunction
  
endclass
