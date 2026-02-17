`include"apb_master_defines.sv"
class apb_master_driver extends uvm_driver#(apb_master_sequence_item);
  `uvm_component_utils(apb_master_driver)
  
  virtual apb_interface vif;
  apb_master_sequence_item req;
  
  bit [`DATA_WIDTH-1:0] mem [int];
  
  function new(string name="apb_master_driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_interface)::get(this,"","vif",vif))
      `uvm_error(get_full_name(),"Driver didn't get interface handle");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    vif.apb_driver_cb.PREADY <= 0;
    vif.apb_driver_cb.PSLVERR <= 0;
    repeat(2)@(vif.apb_driver_cb);
    forever begin
      req = apb_master_sequence_item::type_id::create("req");
     seq_item_port.get_next_item(req);
     drive(req);
     seq_item_port.item_done();
   end
  endtask
  
  task drive(apb_master_sequence_item req);
    bit [`DATA_WIDTH-1:0] data_out;
//     repeat(0)@(vif.apb_driver_cb);
    if(!req.transfer) begin
      vif.apb_driver_cb.transfer   <= 0;
      vif.apb_driver_cb.write_read <= 0;
      vif.apb_driver_cb.addr_in    <= 0;
      vif.apb_driver_cb.wdata_in   <= 0;
      vif.apb_driver_cb.strb_in    <= 0;
    end
    else begin
      	vif.apb_driver_cb.transfer   <= req.transfer;
    	vif.apb_driver_cb.write_read <= req.write_read;
   	 	vif.apb_driver_cb.addr_in    <= req.addr_in;
    	vif.apb_driver_cb.wdata_in   <= req.wdata_in;
    	vif.apb_driver_cb.strb_in    <= req.strb_in;
      while(!(vif.apb_driver_cb.PSEL == 1 && vif.apb_driver_cb.PENABLE == 0)) begin
      repeat(1)@(vif.apb_driver_cb);
      end
      `uvm_info(get_full_name(), "PHASE: Entered SETUP Phase", UVM_MEDIUM)
      repeat(1)@(vif.apb_driver_cb);
        if(vif.apb_driver_cb.PSEL == 1 && vif.apb_driver_cb.PENABLE == 1) begin
          if(req.wait_cycles > 0) begin
       `uvm_info(get_full_name(), $sformatf("WAIT: Inserting %0d wait cycles", req.wait_cycles), UVM_HIGH)
      	  end
        repeat(req.wait_cycles) begin
          vif.apb_driver_cb.PREADY <= 0;
          repeat(1)@(vif.apb_driver_cb);
        end
        vif.apb_driver_cb.PREADY <= 1;
          slave_mem(vif.apb_driver_cb.PADDR, vif.apb_driver_cb.PWDATA, vif.apb_driver_cb.PWRITE, vif.apb_driver_cb.PSTRB, data_out);
           if(!vif.apb_driver_cb.PWRITE) begin
          	  vif.apb_driver_cb.PRDATA <= data_out;
             `uvm_info(get_full_name(), $sformatf("COMPLETE READ: Addr=0x%0h -> Data_Out=0x%0h", 
                 vif.apb_driver_cb.PADDR, data_out), UVM_MEDIUM)
        	end
          else begin
       `uvm_info(get_full_name(), $sformatf("COMPLETE WRITE: Addr=0x%0h <- Data_In=0x%0h", 
                 vif.apb_driver_cb.PADDR, vif.apb_driver_cb.PWDATA), UVM_MEDIUM)
    		end
          repeat(1)@(vif.apb_driver_cb);
          vif.apb_driver_cb.PREADY <= 0;
    end
    end
  endtask
  
  function slave_mem(input bit[`ADDR_WIDTH-1:0]PADDR, input bit[`DATA_WIDTH-1:0]PWDATA, input bit PWRITE, input bit [`DATA_WIDTH/8-1:0]PSTRB, output bit[`DATA_WIDTH-1:0] data_out);
        if(PWRITE) begin
          for(int i =0;i < (`DATA_WIDTH/8);i++) begin
            if(PSTRB[i]) begin
              mem [PADDR + i] = PWDATA[8*i+7 -: 8];
            end
          end
        end
        else begin
          for(int j = 0;j < (`DATA_WIDTH/8);j++) begin
            if(mem.exists(PADDR + j)) begin
              data_out[8*j+7 -: 8] = mem[PADDR + j];
            end
            else begin
              data_out[8*j+7 -: 8] = 8'h00;
            end
          end
        end
      endfunction     
endclass
