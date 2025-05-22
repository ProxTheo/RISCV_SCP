# ==============================================================================
# Authors:              Uğur Eroğlu, Necati Teoman Bahar
#
# Cocotb Testbench:     For Single Cycle RISC-V Project
#
# Description:
# ------------------------------------
# Test bench for the single cycle RISC-V project, used by us to check our designs
#
# License:
# ==============================================================================


import logging
import cocotb
from Helper_lib_riscv import read_file_to_list, InstructionRISCV, ByteAddressableMemory, reverse_hex_string_endiannes, shift_helper, zero_extend, sign_extend
from Helper_Student_riscv import Log_Datapath, Log_Controller, Log_UART
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

class Constants:
    # Define your constant values as class attributes for operation types
    LSL = 0
    LSR = 1
    ASR = 2
    ROR = 3

class TB:
    def __init__(self, Instruction_list,dut,dut_PC,dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
        #Configure the logger
        self.logger = logging.getLogger("Performance Model")
        self.logger.setLevel(logging.DEBUG)
        #Initial values are all 0 as in a FPGA
        self.PC = 0
        self.Z_flag = 0
        self.Register_File =[]
        for _ in range(32):
            self.Register_File.append(0)
        #Memory is a special class helper lib to simulate HDL counterpart    
        self.memory = ByteAddressableMemory(4096)

        self.width= 32
        self.min_signed = -(1 << (self.width - 1))  # -8 for 4-bit
        self.max_signed = (1 << (self.width - 1)) - 1  # 7 for 4-bit
        self.max_unsigned = (1 << self.width) - 1  # 15 for 4-bit
        self.min_unsigned = 0  # 0 for 4-bit
        self.ceiling = 1 << self.width # 16 for 4-bit

        self.clock_cycle_count = 0

    #Compares and lgos the PC and register file of Python module and HDL design
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC          :%d \t\t %d", self.PC, self.dut_PC.value.integer)
        for i in range(10):
            signed_model_value = self.Register_File[i] if self.Register_File[i] <= self.max_signed else self.Register_File[i] - self.ceiling
            signed_dut_value = self.dut_regfile.Reg_Out[i].value.integer if self.dut_regfile.Reg_Out[i].value.integer <= self.max_signed else self.dut_regfile.Reg_Out[i].value.integer - self.ceiling
            self.logger.debug("Register%d   : %d \t\t %d",i,signed_model_value, signed_dut_value)
        for i in range(10,32):
            signed_model_value = self.Register_File[i] if self.Register_File[i] <= self.max_signed else self.Register_File[i] - self.ceiling
            signed_dut_value = self.dut_regfile.Reg_Out[i].value.integer if self.dut_regfile.Reg_Out[i].value.integer <= self.max_signed else self.dut_regfile.Reg_Out[i].value.integer - self.ceiling
            self.logger.debug("Register%d  : %d \t\t %d",i,signed_model_value, signed_dut_value)
            #self.logger.debug("Register%d: %d \t %d",i,self.Register_File[i], self.dut_regfile.Reg_Out[i].value.integer)
        assert self.PC == self.dut_PC.value.integer
        for i in range(32):
           assert self.Register_File[i] == self.dut_regfile.Reg_Out[i].value.integer

    #Function to write into the register file, handles writing into R15(PC)
    def write_to_register_file(self,register_no, data):
        self.Register_File[register_no] = data
    
    def handleOverflow(self, value):
        '''
        In Verilog, the value is truncated to 32 bits, so we need to do the same in Python.
        This function will handle the overflow by masking the value to 32 bits.
        To achieve this, we can use the bitwise AND operator with a mask of 0xFFFFFFFF.
        '''
        return value & 0xFFFFFFFF

    def log_dut(self):
        Log_Datapath(self.dut, self.logger)
        Log_UART(self.dut, self.logger)
        Log_Controller(self.dut, self.logger)
        

    #A model of the verilog code to confirm operation, data is In_data
    def performance_model (self):
        self.logger.debug("**************** Clock cycle: %d **********************",self.clock_cycle_count + 1)
        self.clock_cycle_count = self.clock_cycle_count+1
        #Read current instructions, extract and log the fields
        self.logger.debug("**************** Instruction No: %d **********************",int((self.PC)/4) + 1)
        current_instruction = self.Instruction_list[int((self.PC)/4)]
        current_instruction = current_instruction.replace(" ", "")
        #We need to reverse the order of bytes since little endian makes the string reversed in Python
        current_instruction = reverse_hex_string_endiannes(current_instruction)
  
        self.PC = self.PC + 4
        #Flag to check if the current instruction will be executed.
        
        #Call Instruction calls to get each field from the instruction
        inst_fields = InstructionRISCV(current_instruction)
        #inst_fields.log(self.logger)

        instruction_name = inst_fields.get_instruction_name()
        branch_flag = False
        match instruction_name:
            case "LB": ### Load byte *** lb rd, imm(rs1) *** rd = SignExtend(Mem[rs1 + imm][0:8])
                self.Register_File[inst_fields.rd] = sign_extend(int.from_bytes(self.memory.read(self.Register_File[inst_fields.rs1] + inst_fields.imm_i)), n_bits=8)
            case "LH": ### Load half word *** lh rd, imm(rs1) *** rd = SignExtend(Mem[rs1 + imm][0:16])
                self.Register_File[inst_fields.rd] = sign_extend(int.from_bytes(self.memory.read(self.Register_File[inst_fields.rs1] + inst_fields.imm_i)), n_bits=16)
            case "LW": ### Load word *** lw rd, imm(rs1) *** rd = Mem[rs1 + imm]
                ### IF address rs1 + imm is 0x404, load is not to be done, instead load 0xFFFF_FFFF
                if self.Register_File[inst_fields.rs1] + inst_fields.imm_i == 0x404:
                    self.Register_File[inst_fields.rd] = 0xFFFFFFFF
                else:
                    self.Register_File[inst_fields.rd] = int.from_bytes(self.memory.read(self.Register_File[inst_fields.rs1] + inst_fields.imm_i))
            case "LBU": ### Load byte unsigned *** lbu rd, imm(rs1) *** rd = ZeroExtend(Mem[rs1 + imm][0:8])
                self.Register_File[inst_fields.rd] = zero_extend(int.from_bytes(self.memory.read(self.Register_File[inst_fields.rs1] + inst_fields.imm_i)), n_bits=8)
            case "LHU": ### Load half word unsigned *** lhu rd, imm(rs1) *** rd = ZeroExtend(Mem[rs1 + imm][0:16])
                self.Register_File[inst_fields.rd] = zero_extend(int.from_bytes(self.memory.read(self.Register_File[inst_fields.rs1] + inst_fields.imm_i)), n_bits=16)
            case "SB": ### Store byte *** sb rs2, imm(rs1) *** Mem[rs1 + imm][0:8] = rs2[0:8]
                ### IF address rs1 + imm is 0x404, store is not to be done, just ignore store and go on, since MemWrite is 0
                if self.Register_File[inst_fields.rs1] + inst_fields.imm_s != 0x400:
                    self.memory.write_byte(self.Register_File[inst_fields.rs1] + inst_fields.imm_s, self.Register_File[inst_fields.rs2] & 0xFF)
            case "SH": ### Store half word *** sh rs2, imm(rs1) *** Mem[rs1 + imm][0:16] = rs2[0:16]
                self.memory.write_half(self.Register_File[inst_fields.rs1] + inst_fields.imm_s, self.Register_File[inst_fields.rs2] & 0xFFFF)
            case "SW": ### Store word *** sw rs2, imm(rs1) *** Mem[rs1 + imm][0:32] = rs2[0:32]
                self.memory.write(self.Register_File[inst_fields.rs1] + inst_fields.imm_s, self.Register_File[inst_fields.rs2])
            case "ADDI": ### Add immediate *** addi rd, rs1, imm *** rd = rs1 + imm
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] + inst_fields.imm_i
            case "SLLI": ### Shift left logical immediate *** slli rd, rs1, uimm *** rd = rs1 << imm[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.imm_i & 0x1F, Constants.LSL, n_bits=32)
            case "SLTI": ### Set less than immediate *** slti rd, rs1, imm *** rd = (rs1 < imm) ? 1 : 0
                signed_reg_val = self.Register_File[inst_fields.rs1] if self.Register_File[inst_fields.rs1] <= self.max_signed else self.Register_File[inst_fields.rs1] - self.ceiling
                signed_imm_val = inst_fields.imm_i if inst_fields.imm_i <= self.max_signed else inst_fields.imm_i - self.ceiling
                self.Register_File[inst_fields.rd] = 1 if signed_reg_val < signed_imm_val else 0
            case "SLTIU": ### Set less than immediate unsigned *** sltiu rd, rs1, imm *** rd = (rs1 < imm) ? 1 : 0
                self.Register_File[inst_fields.rd] = 1 if self.Register_File[inst_fields.rs1] < inst_fields.imm_i else 0
            case "XORI": ### Exclusive or immediate *** xori rd, rs1, imm *** rd = rs1 ^ imm
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] ^ inst_fields.imm_i
            case "SRLI": ### Shift right logical immediate *** srli rd, rs1, uimm *** rd = rs1 >> imm[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.imm_i & 0x1F, Constants.LSR, n_bits=32)
            case "SRAI": ### Shift right arithmetic immediate *** srai rd, rs1, uimm *** rd = rs1 >> imm[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], inst_fields.imm_i & 0x1F, Constants.ASR, n_bits=32)
            case "ORI": ### Or immediate *** ori rd, rs1, imm *** rd = rs1 | imm
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] | inst_fields.imm_i
            case "ANDI": ### And immediate *** andi rd, rs1, imm *** rd = rs1 & imm
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] & inst_fields.imm_i
            case "ADD": ### Add immediate word *** add rd, rs1, rs2 *** rd = rs1 + rs2
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] + self.Register_File[inst_fields.rs2]
            case "SUB": ### Subtract immediate word *** sub rd, rs1, rs2 *** rd = rs1 - rs2
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] + ~(self.Register_File[inst_fields.rs2]) + 1
            case "SLL": ### Shift left logical *** sll rd, rs1, rs2 *** rd = rs1 << rs2[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], self.Register_File[inst_fields.rs2] & 0x1F, Constants.LSL, n_bits=32)
            case "SLT": ### Set less than *** slt rd, rs1, rs2 *** rd = (rs1 < rs2) ? 1 : 0
                signed_reg1_val = self.Register_File[inst_fields.rs1] if self.Register_File[inst_fields.rs1] <= self.max_signed else self.Register_File[inst_fields.rs1] - self.ceiling
                signed_reg2_val = self.Register_File[inst_fields.rs2] if self.Register_File[inst_fields.rs2] <= self.max_signed else self.Register_File[inst_fields.rs2] - self.ceiling
                self.Register_File[inst_fields.rd] = 1 if signed_reg1_val < signed_reg2_val else 0
            case "SLTU": ### Set less than unsigned *** sltu rd, rs1, rs2 *** rd = (rs1 < rs2) ? 1 : 0
                self.Register_File[inst_fields.rd] = 1 if self.Register_File[inst_fields.rs1] < self.Register_File[inst_fields.rs2] else 0
            case "XOR": ### Exclusive or *** xor rd, rs1, rs2 *** rd = rs1 ^ rs2
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] ^ self.Register_File[inst_fields.rs2]
            case "SRL": ### Shift right logical *** srl rd, rs1, rs2 *** rd = rs1 >> rs2[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], self.Register_File[inst_fields.rs2] & 0x1F, Constants.LSR, n_bits=32)
            case "SRA": ### Shift right arithmetic *** sra rd, rs1, rs2 *** rd = rs1 >> rs2[0:5]
                self.Register_File[inst_fields.rd] = shift_helper(self.Register_File[inst_fields.rs1], self.Register_File[inst_fields.rs2] & 0x1F, Constants.ASR, n_bits=32)
            case "OR": ### Or *** or rd, rs1, rs2 *** rd = rs1 | rs2
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] | self.Register_File[inst_fields.rs2]
            case "AND": ### And *** and rd, rs1, rs2 *** rd = rs1 & rs2
                self.Register_File[inst_fields.rd] = self.Register_File[inst_fields.rs1] & self.Register_File[inst_fields.rs2]
            case "AUIPC": ### Add upper immediate to PC *** auipc rd, imm *** rd = PC + upimm
                self.Register_File[inst_fields.rd] = (self.PC - 4) + inst_fields.imm_u
            case "LUI": ### Load upper immediate *** lui rd, imm *** rd = upimm
                self.Register_File[inst_fields.rd] = inst_fields.imm_u
            case "BEQ": ### Branch equal *** beq rs1, rs2, imm *** if (rs1 == rs2) PC = PC + imm
                if self.Register_File[inst_fields.rs1] == self.Register_File[inst_fields.rs2]:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag = True
            case "BNE": ### Branch not equal *** bne rs1, rs2, imm *** if (rs1 != rs2) PC = PC + imm
                if self.Register_File[inst_fields.rs1] != self.Register_File[inst_fields.rs2]:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag
            case "BLT": ## Branch less than *** blt rs1, rs2, imm *** if (rs1 < rs2) PC = PC + imm
                signed_reg1_val = self.Register_File[inst_fields.rs1] if self.Register_File[inst_fields.rs1] <= self.max_signed else self.Register_File[inst_fields.rs1] - self.ceiling
                signed_reg2_val = self.Register_File[inst_fields.rs2] if self.Register_File[inst_fields.rs2] <= self.max_signed else self.Register_File[inst_fields.rs2] - self.ceiling
                if signed_reg1_val < signed_reg2_val:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag = True
            case "BGE": ### Branch greater than or equal *** bge rs1, rs2, imm *** if (rs1 >= rs2) PC = PC + imm
                signed_reg1_val = self.Register_File[inst_fields.rs1] if self.Register_File[inst_fields.rs1] <= self.max_signed else self.Register_File[inst_fields.rs1] - self.ceiling
                signed_reg2_val = self.Register_File[inst_fields.rs2] if self.Register_File[inst_fields.rs2] <= self.max_signed else self.Register_File[inst_fields.rs2] - self.ceiling
                if signed_reg1_val >= signed_reg2_val:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag = True
            case "BLTU": ### Branch less than unsigned *** bltu rs1, rs2, imm *** if (rs1 < rs2) PC = PC + imm
                if self.Register_File[inst_fields.rs1] < self.Register_File[inst_fields.rs2]:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag = True
            case "BGEU": ### Branch greater than or equal unsigned *** bgeu rs1, rs2, imm *** if (rs1 >= rs2) PC = PC + imm
                if self.Register_File[inst_fields.rs1] >= self.Register_File[inst_fields.rs2]:
                    self.PC = (self.PC - 4) + inst_fields.imm_b
                    branch_flag = True
            case "JALR":
                ### Jump and link register *** jalr rd, imm(rs1) *** rd = PC + 4; PC = rs1 + imm
                self.Register_File[inst_fields.rd] = (self.PC - 4) + 4
                self.PC = (self.Register_File[inst_fields.rs1] + inst_fields.imm_i)
            case "JAL":
                ### Jump and link *** jal rd, imm *** rd = PC + 4; PC = PC + imm
                self.Register_File[inst_fields.rd] = (self.PC - 4) + 4
                self.PC = (self.PC - 4) + inst_fields.imm_j
            case _:
                self.logger.error("Not supported data processing instruction!!")
                assert False 
        # BEFORE returning, we should handle overflow in Register_File and PC
        # Handle overflow for PC
        self.PC = self.handleOverflow(self.PC)
        # Handle overflow for Register_File
        for i in range(1,32):
            self.Register_File[i] = self.handleOverflow(self.Register_File[i])
        inst_fields.log(self.logger, branch_flag=branch_flag)
        return

    async def run_test(self):
        self.performance_model()
        #Wait 1 us the very first time bc. initially all signals are "X"
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()
        while(int(self.Instruction_list[int((self.PC)/4)].replace(" ", ""),16)!=0):
            self.performance_model()
            #Log datapath and controller before clock edge, this calls user filled functions
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()
        # Uncomment to log the final state of the memory
        #with open("Memory.txt", "w") as f:
        #    for i in range(0, len(self.memory.memory), 4):
        #        line = " ".join(f"{byte:02X}" for byte in self.memory.memory[i:i + 4])
        #        f.write(line + "\n")
        # Write the dut memory to a file
        #with open("DUT_Memory.txt", "w") as f:
        #    for i in range(0, len(self.dut.datapath_inst.mem_data.mem), 4):
        #        line = ""
        #        word_list = []
        #        for j in range(0,4):
        #            byte = self.dut.datapath_inst.mem_data.mem[i+j].value.integer
        #            word_list.append(byte)
        #        line = " ".join(f"{byte:02X}" for byte in word_list)
        #        f.write(line + "\n")

@cocotb.test()
async def riscv_single_cycle_test(dut):
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    await cocotb.start(Clock(dut.clk100Mhz, 10, 'us').start(start_high=False))
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk100Mhz)
    dut.reset.value = 0
    await FallingEdge(dut.clk)
    await FallingEdge(dut.clk100Mhz)

    instr_list = read_file_to_list("Instructions.hex")
    tb = TB(instr_list, dut, dut.Debug_PC, dut.datapath_inst.register_file)
    await tb.run_test()
