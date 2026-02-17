`include"apb_master_defines.sv"
class apb_master_sequence_item extends uvm_sequence_item;
  
  rand bit write_read;
  rand bit transfer;
  rand bit [`ADDR_WIDTH-1:0]addr_in;
  rand bit [`DATA_WIDTH-1:0]wdata_in;
  rand bit [(`DATA_WIDTH/8)-1:0] strb_in;
  rand int wait_cycles;
  bit PREADY;
  bit [`DATA_WIDTH-1:0]PRDATA;
  bit PSLVERR;
  
  bit PSEL;
  bit PENABLE;
  bit [`ADDR_WIDTH-1:0]PADDR;   
  bit [`DATA_WIDTH-1:0]PWDATA;
  bit PWRITE;
  bit [`DATA_WIDTH-1:0]rdata_out;
  bit [(`DATA_WIDTH/8)-1:0]PSTRB;
  bit transfer_done;
  bit error;
  
  `uvm_object_utils_begin(apb_master_sequence_item)
     `uvm_field_int(transfer,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(write_read,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(addr_in,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(wdata_in,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(strb_in,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PSLVERR,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PREADY,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PRDATA,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(rdata_out,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PSEL,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PENABLE,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PWDATA,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PADDR,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PWRITE,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(PSTRB,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(transfer_done,UVM_ALL_ON+UVM_DEC)
     `uvm_field_int(error,UVM_ALL_ON+UVM_DEC)
  `uvm_object_utils_end
  
  constraint addr_alling_c{ addr_in[1:0] == 0;}
  constraint strb_c{(write_read == 1) -> strb_in != 0;}
  constraint transfer_c{soft transfer == 1;}
  constraint wait_cycle_c {wait_cycles == 4;}
//   constraint c1{write_read == 0;}
  
  function new(string name="apb_master_sequence_item");
    super.new(name);
  endfunction
  
endclass
  
