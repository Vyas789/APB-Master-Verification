`include "uvm_macros.svh"
 import uvm_pkg::*;
`include"apb_master_defines.sv"

interface apb_interface(input logic PCLK,PRESETn);
  //inputs
  logic write_read;
  logic transfer;
  logic [`ADDR_WIDTH-1:0]addr_in;
  logic [`DATA_WIDTH-1:0]wdata_in;
  logic [(`DATA_WIDTH/8)-1:0] strb_in;
  logic PREADY;
  logic [`DATA_WIDTH-1:0]PRDATA;
  logic PSLVERR;
  //outputs
  logic PSEL;
  logic PENABLE;
  logic [`ADDR_WIDTH-1:0]PADDR;  
  logic [`DATA_WIDTH-1:0]PWDATA;
  logic PWRITE;
  logic [`DATA_WIDTH-1:0]rdata_out;
  logic transfer_done;
  logic error;
  logic [`DATA_WIDTH/8-1:0]PSTRB;
  
  clocking apb_driver_cb@(posedge PCLK);
    default input #0 output #0;
    output transfer,write_read,addr_in,wdata_in,PREADY,PRDATA,PSLVERR,strb_in;
    input PSEL,PENABLE,PADDR,PWDATA,PWRITE,PSTRB;
  endclocking
  
  clocking apb_act_mon_cb@(posedge PCLK);
    default input #0 output #0;
    input transfer_done,write_read,addr_in,wdata_in,PSEL,PENABLE,PREADY,PRDATA,PSLVERR,strb_in;
  endclocking
  
  clocking apb_pas_mon_cb@(posedge PCLK);
    default input #0 output #0;
    input PREADY,PSEL,PENABLE,PADDR,PWDATA,PWRITE,rdata_out,transfer_done,error,PSTRB;
  endclocking
  
//   clocking apb_scb_cb@(posedge PCLK);
//     default input #0 output #0;
//     input PRESETn;
//   endclocking
  
  modport APB_DRV(clocking apb_driver_cb);
  modport APB_ACT_MON(clocking apb_act_mon_cb);
  modport APB_PAS_MON(clocking apb_pas_mon_cb);
//   modport APB_SCB(clocking apb_scb_cb);
  
endinterface
