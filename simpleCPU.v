module projectCPU2020(
  clk,
  rst,
  wrEn,
  data_fromRAM,
  addr_toRAM,
  data_toRAM,
  PC,
  W
);

input clk, rst;
input wire [15:0] data_fromRAM;
output reg [15:0] data_toRAM;
output reg wrEn;

// 12 can be made smaller so that it fits in the FPGA
output reg [12:0] addr_toRAM;
output reg [12:0] PC; // This has been added as an output for TB purposes
output reg [15:0] W; // This has been added as an output for TB purposes

reg [2:0] state, stateNext;
reg [12:0] a, aNext;
reg [15:0] starA, starAnext;
reg [2:0] opcode, opcodeNext;
reg [12:0] pcNext;


always @(posedge clk) begin
state <= #1 stateNext;
PC <= #1 pcNext;
opcode <= #1 opcodeNext;
starA <= #1 starAnext;
a <= #1 aNext;
end

always @* begin
stateNext = state;
opcodeNext = opcode;
aNext = a;
starAnext = starA;
pcNext = PC;
data_toRAM = 0;
addr_toRAM = 0;
wrEn = 0;
W = W;
if(rst)
  begin
  stateNext = 0;
  opcodeNext = 0;
  aNext = 0;
  starAnext = 0;
  W = 0;
  pcNext = 0;
  wrEn = 0;
  data_toRAM = 0;
  addr_toRAM = 0;
end
else
case(state)
  0: begin
  pcNext = PC;
  opcodeNext = opcode;
  aNext = 0;
  addr_toRAM = PC;
  starAnext = 0;
  wrEn = 0;
  data_toRAM = 0;
  stateNext = 1;
  end
  1: begin
  pcNext = PC;
  opcodeNext = data_fromRAM[15:13];
  aNext = data_fromRAM[12:0];
  addr_toRAM = data_fromRAM[12:0];
  starAnext = 0;
  wrEn = 0;
  data_toRAM = 0;
  stateNext = 2;
  end
  2: begin
  pcNext = PC;
  opcodeNext = opcode;
  aNext = a;
  addr_toRAM = a;
  starAnext = data_fromRAM;
  wrEn = 0;
  data_toRAM = 0;
    if(a==0)begin
      stateNext = 4;
      starAnext = 0;
      addr_toRAM = 2;
    end else
      stateNext = 3;
    end
  3: begin
  opcodeNext = opcode;
  aNext = a;
  addr_toRAM = a;
    case(opcode)
      3'b111: begin
        data_toRAM = 0;
        pcNext = starA;
        wrEn = 0;
        stateNext = 0;
      end
      3'b110: begin
        pcNext = PC+1;
        wrEn = 1;
        data_toRAM = W;
        stateNext = 0;
      end
      3'b101: begin
        pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        W = starA;
        stateNext = 0;
      end
      3'b100: begin
        if(starA==0)
          pcNext = PC+2;
        else
          pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        stateNext = 0;
      end
      3'b011: begin
        pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        W = W > starA;
        stateNext = 0;
      end
      3'b010: begin
        pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        if(starA<16)
        W = W >> starA;
        else if(starA>16 && starA<32)
        W = W << starA[3:0];
        else if(starA>31 && starA < 48 )
        W = (W >> starA[3:0] | W<< (15 - starA[3:0]));
        else
        W = (W << starA[3:0] | W >> (15 - starA[3:0]));
        stateNext = 0;
      end
      3'b001: begin
        pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        W = ~(W | starA);
        stateNext = 0;
      end
      3'b000: begin
        pcNext = PC+1;
        wrEn = 0;
        data_toRAM = 0;
        W = W + starA;
        stateNext = 0;
      end
    endcase

  end
  4: begin
    pcNext = PC;
  	data_toRAM = 0;
  	opcodeNext = opcode;
  	addr_toRAM = data_fromRAM;
    starAnext = 0;
    aNext = data_fromRAM;
    wrEn = 0;
    data_toRAM = 0;
    stateNext = 5;
    end
  5: begin
    pcNext = PC;
    data_toRAM = 0;
    opcodeNext = opcode;
    addr_toRAM = a;
    starAnext = data_fromRAM;
    aNext = a;
    wrEn = 0;
    data_toRAM = 0;
    stateNext = 3;
      end
endcase
end
endmodule
