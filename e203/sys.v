`timescale 1ns/1ps

module sys
(
//  input wire CLK200M_p, // Genesys2 has a differential LVDS 200MHz oscillator
//  input wire CLK200M_n,
  input wire clk200M,  // for soc clock

 // input wire fpga_rst,  // FPGA_RESET-E18 button. ATTENTION: when pressing, value = 1. See: 13 Basic I/O Fig. 15
  input wire mcu_rst,   // MCU_RESET-R19 button. When pressing, value = 0

  // Dedicated QSPI interface
  output wire qspi0_cs,
  // output wire qspi0_sck, //  Genesys2 dosen't have it. See: 6.2 Quad-SPI Flash
  inout wire [3:0] qspi0_dq,

  //gpioA
  // inout wire [7:0] gpioA, // GPIOA-0~28, use 29 gpios of port A

  /*
  * Leds on board
  * GPIOA0 LED0
  * GPIOA1 LED1
  * GPIOA2 LED2
  * GPIOA3 LED3
  * GPIOA4 LED4
  */
  inout wire [4:0] led,

  /*
  * switches on board
  * GPIOA22 SW0
  * GPIOA23 SW1
  * GPIOA24 SW2
  * GPIOA25 SW3
  * GPIOA26 SW4
  * GPIOA27 SW5
  * GPIOA28 SW6
  */
  inout wire [6:0] sw,

  /*
  * Buttons on board
  * GPIOA6  btnd
  * GPIOA7  btnl
  * GPIOA20 btnr
  * GPIOA21 btnu
  */
  inout wire btnd,
  inout wire btnl,
  inout wire btnr,
  inout wire btnu,
  
  /*
  * OLED SPI CS is always active. See: 15 OLED
  * GPIOA8  SCLK. OLED SPI sclk of Genesys2
  * GPIOA9  RES. OLED Reset. Active-low
  * GPIOA10 DC. OLED SPI dc
  * GPIOA11 SDIN. OLED SPI sdin
  * GPIOA12 VBAT
  * GPIOA13 VDD
  */

  /*
  * GPIOA14 I2C0 SCL for power monitoring. See: 3 Power Monitoring
  * GPIOA15 I2C0 SDA
  * GPIOA16 UART0 RX. Console UART RX for debugging
  * GPIOA17 UART0 TX. Console UART TX for debugging
  * GPIOA18 UART2 RX
  * GPIOA19 UART2 TX
  */
  inout wire uart0_rx,
  inout wire uart0_tx,

  
  //gpioB
  //inout wire [6:0] gpioB,// GPIOB00~GPIOB31

  // JD (used for JTAG connection)
  inout wire mcu_TDO,   // MCU_TDO
  inout wire mcu_TCK,   // MCU_TCK
  inout wire mcu_TDI,   // MCU_TDI
  inout wire mcu_TMS,   // MCU_TMS


    /********  AXI    *******/
	output wire expl_axi_arvalid,
	input  wire expl_axi_arready,
	output wire [32-1:0] expl_axi_araddr,
	output wire [3:0] expl_axi_arcache,
	output wire [2:0] expl_axi_arprot,
	output wire [1:0] expl_axi_arlock,
	output wire [1:0] expl_axi_arburst,
	output wire [3:0] expl_axi_arlen,
	output wire [2:0] expl_axi_arsize,

	output wire expl_axi_awvalid,
	input  wire expl_axi_awready,
	output wire [32-1:0] expl_axi_awaddr,
	output wire [3:0] expl_axi_awcache,
	output wire [2:0] expl_axi_awprot,
	output wire [1:0] expl_axi_awlock,
	output wire [1:0] expl_axi_awburst,
	output wire [3:0] expl_axi_awlen,
	output wire [2:0] expl_axi_awsize,

	input  wire expl_axi_rvalid,
	output wire expl_axi_rready,
	input  wire [32-1:0] expl_axi_rdata,
	input  wire [1:0] expl_axi_rresp,
	input  wire expl_axi_rlast,

	output wire expl_axi_wvalid,
	input  wire expl_axi_wready,
	output wire [32-1:0] expl_axi_wdata,
	output wire [(32/8)-1:0] expl_axi_wstrb,
	output wire expl_axi_wlast,

	input  wire expl_axi_bvalid,
	output wire expl_axi_bready,
	input  wire[1:0] expl_axi_bresp,
	

	output aclk,
	output ck_rst,
	output aresetn,


  //pmu_wakeup

  inout wire pmu_paden,  //PMU_VDDPADEN
  inout wire pmu_padrst, //PMU_VADDPARST
  inout wire mcu_wakeup  //MCU_WAKE
);


 	//axi
  wire                     expl_axi_icb_cmd_valid;
  wire                     expl_axi_icb_cmd_ready;
  wire [32-1:0]            expl_axi_icb_cmd_addr;
  wire                     expl_axi_icb_cmd_read; 
  wire [32-1:0]            expl_axi_icb_cmd_wdata;
  wire [4 -1:0]            expl_axi_icb_cmd_wmask;
   
  wire                     expl_axi_icb_rsp_valid;
  wire                     expl_axi_icb_rsp_ready;
  wire [32-1:0]            expl_axi_icb_rsp_rdata;
  wire                     expl_axi_icb_rsp_err;

  wire mmcm_locked;
  wire reset_periph;
  //wire ck_rst;

  // All wires connected to the chip top
  wire dut_clock;
  wire dut_reset;

  wire dut_io_pads_jtag_TCK_i_ival;
  wire dut_io_pads_jtag_TMS_i_ival;
  wire dut_io_pads_jtag_TMS_o_oval;
  wire dut_io_pads_jtag_TMS_o_oe;
  wire dut_io_pads_jtag_TMS_o_ie;
  wire dut_io_pads_jtag_TMS_o_pue;
  wire dut_io_pads_jtag_TMS_o_ds;
  wire dut_io_pads_jtag_TDI_i_ival;
  wire dut_io_pads_jtag_TDO_o_oval;
  wire dut_io_pads_jtag_TDO_o_oe;

  wire [32-1:0] dut_io_pads_gpioA_i_ival;
  wire [32-1:0] dut_io_pads_gpioA_o_oval;
  wire [32-1:0] dut_io_pads_gpioA_o_oe;

  wire [32-1:0] dut_io_pads_gpioB_i_ival;
  wire [32-1:0] dut_io_pads_gpioB_o_oval;
  wire [32-1:0] dut_io_pads_gpioB_o_oe;

  wire dut_io_pads_qspi0_sck_o_oval;
  wire dut_io_pads_qspi0_cs_0_o_oval;
  wire dut_io_pads_qspi0_dq_0_i_ival;
  wire dut_io_pads_qspi0_dq_0_o_oval;
  wire dut_io_pads_qspi0_dq_0_o_oe;
  wire dut_io_pads_qspi0_dq_1_i_ival;
  wire dut_io_pads_qspi0_dq_1_o_oval;
  wire dut_io_pads_qspi0_dq_1_o_oe;
  wire dut_io_pads_qspi0_dq_2_i_ival;
  wire dut_io_pads_qspi0_dq_2_o_oval;
  wire dut_io_pads_qspi0_dq_2_o_oe;
  wire dut_io_pads_qspi0_dq_3_i_ival;
  wire dut_io_pads_qspi0_dq_3_o_oval;
  wire dut_io_pads_qspi0_dq_3_o_oe;


  wire dut_io_pads_aon_erst_n_i_ival;
  wire dut_io_pads_aon_pmu_dwakeup_n_i_ival;
  wire dut_io_pads_aon_pmu_vddpaden_o_oval;
  wire dut_io_pads_aon_pmu_padrst_o_oval ;
  wire dut_io_pads_bootrom_n_i_ival;
  wire dut_io_pads_dbgmode0_n_i_ival;
  wire dut_io_pads_dbgmode1_n_i_ival;
  wire dut_io_pads_dbgmode2_n_i_ival;

  //=================================================
  // Clock & Reset
  wire clk_8388;    // 8.388MHz clock
  wire clk_16M;     // 16MHz clock
  wire CLK32768KHZ;   // 32768KHz clock

  assign ck_rst =  mcu_rst;

//  clk_wiz_0 ip_mmcm
//  (
//    .resetn(ck_rst),
//    .clk_in1_p(CLK200M_p),
//    .clk_in1_n(CLK200M_n),

//    .CLK_O_16M(clk_16M), // 16 MHz, this clock we set to 16MHz
//    .CLK_O_8M388(clk_8388),
//    .locked(mmcm_locked)
//  );
    clk_wiz_0 ip_mmcm
  (
    .resetn(ck_rst),
    .clk_in1(clk200M),
   

    .CLK_O_16M(clk_16M), // 16 MHz, this clock we set to 16MHz
    .CLK_O_8M388(clk_8388),
    .locked(mmcm_locked)
  );

  // Clock divider
  clkdivider rtc_clk_gen(
    .clk         (clk_8388   ),//generate 32.768KHz
    .reset       (~mmcm_locked),
    .clk_out     (CLK32768KHZ)
  );
  
//  reset_sys ip_reset_sys
//  (
//    .slowest_sync_clk(clk_16M),
//    .ext_reset_in(ck_rst), // Active-low
//    .aux_reset_in(1'b1),
//    .mb_debug_sys_rst(1'b0),
//    .dcm_locked(mmcm_locked),
//    .mb_reset(),
//    .bus_struct_reset(),
//    .peripheral_reset(reset_periph),
//    .interconnect_aresetn(),
//    .peripheral_aresetn()
//  );

  //=================================================
  // SPI0 Interface

  wire [3:0] qspi0_ui_dq_o;
  wire [3:0] qspi0_ui_dq_oe;
  wire [3:0] qspi0_ui_dq_i;

  PULLUP qspi0_pullup[3:0]
  (
    .O(qspi0_dq)
  );

  IOBUF qspi0_iobuf[3:0]
  (
    .IO(qspi0_dq),
    .O(qspi0_ui_dq_i),
    .I(qspi0_ui_dq_o),
    .T(~qspi0_ui_dq_oe)
  );

  //=================================================
  // IOBUF instantiation for GPIOs

  // IOBUF
  // #(
  //   .DRIVE(12),
  //   .IBUF_LOW_PWR("TRUE"),
  //   .IOSTANDARD("DEFAULT"),
  //   .SLEW("SLOW")
  // )
  // gpioA_iobuf
  // (
  //   .O(dut_io_pads_gpioA_i_ival[7:0]),
  //   .IO(gpioA[7:0]),
  //   .I(dut_io_pads_gpioA_o_oval[7:0]),
  //   .T(~dut_io_pads_gpioA_o_oe[7:0])
  // );

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  led_iobuf_0
  (
    .O(dut_io_pads_gpioA_i_ival[0]),
    .IO(led[0]),
    .I(dut_io_pads_gpioA_o_oval[0]),
    .T(~dut_io_pads_gpioA_o_oe[0])
  );
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  led_iobuf_1
  (
    .O(dut_io_pads_gpioA_i_ival[1]),
    .IO(led[1]),
    .I(dut_io_pads_gpioA_o_oval[1]),
    .T(~dut_io_pads_gpioA_o_oe[1])
  );
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  led_iobuf_2
  (
    .O(dut_io_pads_gpioA_i_ival[2]),
    .IO(led[2]),
    .I(dut_io_pads_gpioA_o_oval[2]),
    .T(~dut_io_pads_gpioA_o_oe[2])
  );
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  led_iobuf_3
  (
    .O(dut_io_pads_gpioA_i_ival[3]),
    .IO(led[3]),
    .I(dut_io_pads_gpioA_o_oval[3]),
    .T(~dut_io_pads_gpioA_o_oe[3])
  );
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  led_iobuf_4
  (
    .O(dut_io_pads_gpioA_i_ival[4]),
    .IO(led[4]),
    .I(dut_io_pads_gpioA_o_oval[4]),
    .T(~dut_io_pads_gpioA_o_oe[4])
  );
  

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_0
  (
    .O(dut_io_pads_gpioA_i_ival[22]),
    .IO(sw[0]),
    .I(dut_io_pads_gpioA_o_oval[22]),
    .T(~dut_io_pads_gpioA_o_oe[22])
  );
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_1
  (
    .O(dut_io_pads_gpioA_i_ival[23]),
    .IO(sw[1]),
    .I(dut_io_pads_gpioA_o_oval[23]),
    .T(~dut_io_pads_gpioA_o_oe[23])
  );
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_2
  (
    .O(dut_io_pads_gpioA_i_ival[24]),
    .IO(sw[2]),
    .I(dut_io_pads_gpioA_o_oval[24]),
    .T(~dut_io_pads_gpioA_o_oe[24])
  );
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_3
  (
    .O(dut_io_pads_gpioA_i_ival[25]),
    .IO(sw[3]),
    .I(dut_io_pads_gpioA_o_oval[25]),
    .T(~dut_io_pads_gpioA_o_oe[25])
  );
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_4
  (
    .O(dut_io_pads_gpioA_i_ival[26]),
    .IO(sw[4]),
    .I(dut_io_pads_gpioA_o_oval[26]),
    .T(~dut_io_pads_gpioA_o_oe[26])
  );
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_5
  (
    .O(dut_io_pads_gpioA_i_ival[27]),
    .IO(sw[5]),
    .I(dut_io_pads_gpioA_o_oval[27]),
    .T(~dut_io_pads_gpioA_o_oe[27])
  );
  
  
    IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  sw_iobuf_6
  (
    .O(dut_io_pads_gpioA_i_ival[28]),
    .IO(sw[6]),
    .I(dut_io_pads_gpioA_o_oval[28]),
    .T(~dut_io_pads_gpioA_o_oe[28])
  );

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  uart0_rx_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[16]),
    .IO(uart0_rx),
    .I(dut_io_pads_gpioA_o_oval[16]),
    .T(~dut_io_pads_gpioA_o_oe[16])
  );
  
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  uart0_tx_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[17]),
    .IO(uart0_tx),
    .I(dut_io_pads_gpioA_o_oval[17]),
    .T(~dut_io_pads_gpioA_o_oe[17])
  );



  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  btnd_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[6]),
    .IO(btnd),
    .I(dut_io_pads_gpioA_o_oval[6]),
    .T(~dut_io_pads_gpioA_o_oe[6])
  );

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  btnl_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[7]),
    .IO(btnl),
    .I(dut_io_pads_gpioA_o_oval[7]),
    .T(~dut_io_pads_gpioA_o_oe[7])
  );

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  btnr_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[20]),
    .IO(btnr),
    .I(dut_io_pads_gpioA_o_oval[20]),
    .T(~dut_io_pads_gpioA_o_oe[20])
  );

  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  btnu_iobuf
  (
    .O(dut_io_pads_gpioA_i_ival[21]),
    .IO(btnu),
    .I(dut_io_pads_gpioA_o_oval[21]),
    .T(~dut_io_pads_gpioA_o_oe[21])
  );

  // Disable gpioB for we don't use them

  // IOBUF
  // #(
  //   .DRIVE(12),
  //   .IBUF_LOW_PWR("TRUE"),
  //   .IOSTANDARD("DEFAULT"),
  //   .SLEW("SLOW")
  // )
  // gpioB_iobuf
  // (
  //   .O(dut_io_pads_gpioB_i_ival),
  //   .IO(gpioB),
  //   .I(dut_io_pads_gpioB_o_oval),
  //   .T(~dut_io_pads_gpioB_o_oe)
  // );

  //=================================================
  // JTAG IOBUFs

  wire iobuf_jtag_TCK_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TCK
  (
    .O(iobuf_jtag_TCK_o),
    .IO(mcu_TCK),
    .I(1'b0),
    .T(1'b1)
  );
  assign dut_io_pads_jtag_TCK_i_ival = iobuf_jtag_TCK_o ;
  PULLUP pullup_TCK (.O(mcu_TCK));

  wire iobuf_jtag_TMS_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TMS
  (
    .O(iobuf_jtag_TMS_o),
    .IO(mcu_TMS),
    .I(1'b0),
    .T(1'b1)
  );
  assign dut_io_pads_jtag_TMS_i_ival = iobuf_jtag_TMS_o;
  PULLUP pullup_TMS (.O(mcu_TMS));

  wire iobuf_jtag_TDI_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TDI
  (
    .O(iobuf_jtag_TDI_o),
    .IO(mcu_TDI),
    .I(1'b0),
    .T(1'b1)
  );
  assign dut_io_pads_jtag_TDI_i_ival = iobuf_jtag_TDI_o;
  PULLUP pullup_TDI (.O(mcu_TDI));

  wire iobuf_jtag_TDO_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_jtag_TDO
  (
    .O(iobuf_jtag_TDO_o),
    .IO(mcu_TDO),
    .I(dut_io_pads_jtag_TDO_o_oval),
    .T(~dut_io_pads_jtag_TDO_o_oe)
  );

  //wire iobuf_jtag_TRST_n_o;
  //IOBUF
  //#(
  //  .DRIVE(12),
  //  .IBUF_LOW_PWR("TRUE"),
  //  .IOSTANDARD("DEFAULT"),
  //  .SLEW("SLOW")
  //)

  //=================================================
  // Assignment of IOBUF "IO" pins to package pins

  // Pins IO0-IO13
  // Shield header row 0: PD0-PD7

  // Use the LEDs for some more useful debugging things.
  assign pmu_paden  = dut_io_pads_aon_pmu_vddpaden_o_oval;
  assign pmu_padrst = dut_io_pads_aon_pmu_padrst_o_oval;

  // model select
  assign dut_io_pads_bootrom_n_i_ival  = 1'b1;   //
  assign dut_io_pads_dbgmode0_n_i_ival = 1'b1;
  assign dut_io_pads_dbgmode1_n_i_ival = 1'b1;
  assign dut_io_pads_dbgmode2_n_i_ival = 1'b1;
  //

  e203_soc_top dut
  (
    .hfextclk(clk_16M),
    .hfxoscen(),

    .lfextclk(CLK32768KHZ),
    .lfxoscen(),

       // Note: this is the real SoC top AON domain slow clock
    .io_pads_jtag_TCK_i_ival(dut_io_pads_jtag_TCK_i_ival),
    .io_pads_jtag_TMS_i_ival(dut_io_pads_jtag_TMS_i_ival),
    .io_pads_jtag_TDI_i_ival(dut_io_pads_jtag_TDI_i_ival),
    .io_pads_jtag_TDO_o_oval(dut_io_pads_jtag_TDO_o_oval),
    .io_pads_jtag_TDO_o_oe  (dut_io_pads_jtag_TDO_o_oe),

    .io_pads_gpioA_i_ival(dut_io_pads_gpioA_i_ival),
    .io_pads_gpioA_o_oval(dut_io_pads_gpioA_o_oval),
    .io_pads_gpioA_o_oe  (dut_io_pads_gpioA_o_oe),

    .io_pads_gpioB_i_ival(dut_io_pads_gpioB_i_ival),
    .io_pads_gpioB_o_oval(dut_io_pads_gpioB_o_oval),
    .io_pads_gpioB_o_oe  (dut_io_pads_gpioB_o_oe),

    .io_pads_qspi0_sck_o_oval (dut_io_pads_qspi0_sck_o_oval),
    .io_pads_qspi0_cs_0_o_oval(dut_io_pads_qspi0_cs_0_o_oval),

    .io_pads_qspi0_dq_0_i_ival(dut_io_pads_qspi0_dq_0_i_ival),
    .io_pads_qspi0_dq_0_o_oval(dut_io_pads_qspi0_dq_0_o_oval),
    .io_pads_qspi0_dq_0_o_oe  (dut_io_pads_qspi0_dq_0_o_oe),
    .io_pads_qspi0_dq_1_i_ival(dut_io_pads_qspi0_dq_1_i_ival),
    .io_pads_qspi0_dq_1_o_oval(dut_io_pads_qspi0_dq_1_o_oval),
    .io_pads_qspi0_dq_1_o_oe  (dut_io_pads_qspi0_dq_1_o_oe),
    .io_pads_qspi0_dq_2_i_ival(dut_io_pads_qspi0_dq_2_i_ival),
    .io_pads_qspi0_dq_2_o_oval(dut_io_pads_qspi0_dq_2_o_oval),
    .io_pads_qspi0_dq_2_o_oe  (dut_io_pads_qspi0_dq_2_o_oe),
    .io_pads_qspi0_dq_3_i_ival(dut_io_pads_qspi0_dq_3_i_ival),
    .io_pads_qspi0_dq_3_o_oval(dut_io_pads_qspi0_dq_3_o_oval),
    .io_pads_qspi0_dq_3_o_oe  (dut_io_pads_qspi0_dq_3_o_oe),


       // Note: this is the real SoC top level reset signal
    .io_pads_aon_erst_n_i_ival(ck_rst),
    .io_pads_aon_pmu_dwakeup_n_i_ival(dut_io_pads_aon_pmu_dwakeup_n_i_ival),
    .io_pads_aon_pmu_vddpaden_o_oval(dut_io_pads_aon_pmu_vddpaden_o_oval),

    .io_pads_aon_pmu_padrst_o_oval    (dut_io_pads_aon_pmu_padrst_o_oval ),

    .io_pads_bootrom_n_i_ival       (dut_io_pads_bootrom_n_i_ival),

    .io_pads_dbgmode0_n_i_ival       (dut_io_pads_dbgmode0_n_i_ival),
    .io_pads_dbgmode1_n_i_ival       (dut_io_pads_dbgmode1_n_i_ival),
    .io_pads_dbgmode2_n_i_ival       (dut_io_pads_dbgmode2_n_i_ival),
    
    	//axi
  //////////////////////////////////AXI����
    .expl_axi_arvalid  (expl_axi_arvalid),
    .expl_axi_arready  (expl_axi_arready),
	.expl_axi_araddr   (expl_axi_araddr),
	.expl_axi_arcache    (expl_axi_arcache),
	.expl_axi_arprot     (expl_axi_arprot),
	.expl_axi_arlock     (expl_axi_arlock),
	.expl_axi_arburst    (expl_axi_arburst),
	.expl_axi_arlen(expl_axi_arlen),
	.expl_axi_arsize(expl_axi_arsize),

	.expl_axi_awvalid(expl_axi_awvalid),
	.expl_axi_awready(expl_axi_awready),
	.expl_axi_awaddr(expl_axi_awaddr),
	.expl_axi_awcache(expl_axi_awcache),
	.expl_axi_awprot(expl_axi_awprot),
	.expl_axi_awlock(expl_axi_awlock),
	.expl_axi_awburst(expl_axi_awburst),
	.expl_axi_awlen(expl_axi_awlen),
	.expl_axi_awsize(expl_axi_awsize),

	.expl_axi_rvalid(expl_axi_rvalid),
	.expl_axi_rready(expl_axi_rready),
	.expl_axi_rdata(expl_axi_rdata),
	.expl_axi_rresp(expl_axi_rresp),
	.expl_axi_rlast(expl_axi_rlast),

	.expl_axi_wvalid(expl_axi_wvalid),
	.expl_axi_wready(expl_axi_wready),
	.expl_axi_wdata(expl_axi_wdata),
	.expl_axi_wstrb(expl_axi_wstrb),
	.expl_axi_wlast(expl_axi_wlast),

	.expl_axi_bvalid(expl_axi_bvalid),
	.expl_axi_bready(expl_axi_bready),
	.expl_axi_bresp(expl_axi_bresp),
   
	.aclk    (aclk),
	.aresetn (aresetn)
  );

  // Assign reasonable values to otherwise unconnected inputs to chip top

  wire iobuf_dwakeup_o;
  IOBUF
  #(
    .DRIVE(12),
    .IBUF_LOW_PWR("TRUE"),
    .IOSTANDARD("DEFAULT"),
    .SLEW("SLOW")
  )
  IOBUF_dwakeup_n
  (
    .O(iobuf_dwakeup_o),
    .IO(mcu_wakeup),
    .I(1'b1),
    .T(1'b1)
  );
  assign dut_io_pads_aon_pmu_dwakeup_n_i_ival = (~iobuf_dwakeup_o);



  assign dut_io_pads_aon_pmu_vddpaden_i_ival = 1'b1;

  wire qspi0_sck;
  assign qspi0_sck = dut_io_pads_qspi0_sck_o_oval;
  assign qspi0_cs  = dut_io_pads_qspi0_cs_0_o_oval;
  assign qspi0_ui_dq_o = {
    dut_io_pads_qspi0_dq_3_o_oval,
    dut_io_pads_qspi0_dq_2_o_oval,
    dut_io_pads_qspi0_dq_1_o_oval,
    dut_io_pads_qspi0_dq_0_o_oval
  };
  assign qspi0_ui_dq_oe = {
    dut_io_pads_qspi0_dq_3_o_oe,
    dut_io_pads_qspi0_dq_2_o_oe,
    dut_io_pads_qspi0_dq_1_o_oe,
    dut_io_pads_qspi0_dq_0_o_oe
  };
  assign dut_io_pads_qspi0_dq_0_i_ival = qspi0_ui_dq_i[0];
  assign dut_io_pads_qspi0_dq_1_i_ival = qspi0_ui_dq_i[1];
  assign dut_io_pads_qspi0_dq_2_i_ival = qspi0_ui_dq_i[2];
  assign dut_io_pads_qspi0_dq_3_i_ival = qspi0_ui_dq_i[3];

  STARTUPE2
  #(
  .PROG_USR("FALSE"),
  .SIM_CCLK_FREQ(0.0)
  )  STARTUPE2_inst (
    .CFGCLK     (),
    .CFGMCLK    (),
    .EOS        (),
    .PREQ       (),
    .CLK        (1'b0),
    .GSR        (1'b0),
    .GTS        (1'b0),
    .KEYCLEARB  (1'b0),
    .PACK       (1'b0),
    .USRCCLKO   (qspi0_sck),  // First three cycles after config ignored, see AR# 52626
    .USRCCLKTS  (1'b0),       // 0 to enable CCLK output
    .USRDONEO   (1'b1),       // Shouldn't matter if tristate is high, but generates a warning if tied low.
    .USRDONETS  (1'b1)        // 1 to tristate DONE output
  );


endmodule