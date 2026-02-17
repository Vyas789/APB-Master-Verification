`include "uvm_macros.svh"
`include "apb_master_interface.sv"
`include "apb_master_package.sv"
`include "apb_master_design.sv"

module top();
 import uvm_pkg::*;
 import apb_master_pkg::*;

 bit pclk,presetn;
 event act_mon_trigger,pas_mon_trigger;

 always #5 pclk=~pclk;

initial
    begin
      pclk=0;
      presetn=0;
//       #5  presetn=1;
//       #5  presetn=0;
      #15  presetn=1;
    end

  apb_interface intrf(pclk,presetn);
  
 apb_master dut(
    .PCLK(pclk),
    .PRESETn(presetn),
    .PADDR(intrf.PADDR),
    .PSEL(intrf.PSEL),
    .PENABLE(intrf.PENABLE),
    .PWRITE(intrf.PWRITE),
    .PWDATA(intrf.PWDATA),
    .PSTRB(intrf.PSTRB),
    .PRDATA(intrf.PRDATA),
    .PREADY(intrf.PREADY),
    .PSLVERR(intrf.PSLVERR),
    .transfer(intrf.transfer),
    .write_read(intrf.write_read),
    .addr_in(intrf.addr_in),
    .wdata_in(intrf.wdata_in),
    .strb_in(intrf.strb_in),
    .rdata_out(intrf.rdata_out),
    .transfer_done(intrf.transfer_done),
    .error(intrf.error)
);

initial begin
  uvm_config_db#(virtual apb_interface)::set(uvm_root::get(),"*","vif",intrf);
  uvm_config_db#(event)::set(uvm_root::get(),"*","act_evt",act_mon_trigger);
  uvm_config_db#(event)::set(uvm_root::get(),"*","pas_evt",pas_mon_trigger);
end

  initial begin
    run_test("apb_master_test");
    #100 $finish;
  end
  
  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
