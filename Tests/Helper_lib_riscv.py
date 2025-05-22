WIDTH = 32

instruction_mappings = {
            # (opcode, funct3, funct7) : instruction_name

            ## 0000011 instructions
            (0b0000011, 0b000): "LB",
            (0b0000011, 0b001): "LH",
            (0b0000011, 0b010): "LW",
            (0b0000011, 0b100): "LBU",
            (0b0000011, 0b101): "LHU",

            ## 0010011 instructions
            (0b0010011, 0b000): "ADDI",
            (0b0010011, 0b001): "SLLI",
            (0b0010011, 0b010): "SLTI",
            (0b0010011, 0b011): "SLTIU",
            (0b0010011, 0b100): "XORI",
            (0b0010011, 0b101): "SRLI",
            (0b0010011, 0b101, 0b0100000): "SRAI",
            (0b0010011, 0b110): "ORI",
            (0b0010011, 0b111): "ANDI",

            ## 0010111 instructions
            (0b0010111): "AUIPC",

            ## 0100011 instructions
            (0b0100011, 0b000): "SB",
            (0b0100011, 0b001): "SH",
            (0b0100011, 0b010): "SW",

            ## 0110011 instructions
            (0b0110011, 0b000, 0b0000000): "ADD",
            (0b0110011, 0b000, 0b0100000): "SUB",
            (0b0110011, 0b001, 0b0000000): "SLL",
            (0b0110011, 0b010, 0b0000000): "SLT",
            (0b0110011, 0b011, 0b0000000): "SLTU",
            (0b0110011, 0b100, 0b0000000): "XOR",
            (0b0110011, 0b101, 0b0000000): "SRL",
            (0b0110011, 0b101, 0b0100000): "SRA",
            (0b0110011, 0b110, 0b0000000): "OR",
            (0b0110011, 0b111, 0b0000000): "AND",
            
            ## 0110111 instructions
            (0b0110111): "LUI",

            ## 1100011 instructions
            (0b1100011, 0b000): "BEQ",
            (0b1100011, 0b001): "BNE",
            (0b1100011, 0b100): "BLT",
            (0b1100011, 0b101): "BGE",
            (0b1100011, 0b110): "BLTU",
            (0b1100011, 0b111): "BGEU",

            ## 1100111 instructions
            (0b1100111): "JALR",

            ## 1101111 instructions
            (0b1101111): "JAL"
        }

instruction_format = {
    # (opcode, funct3, funct7) : instruction_format

    ## 0000011 instructions
    (0b0000011, 0b000): "LB rd, imm(rs1)",
    (0b0000011, 0b001): "LH rd, imm(rs1)",
    (0b0000011, 0b010): "LW rd, imm(rs1)",
    (0b0000011, 0b100): "LBU rd, imm(rs1)",
    (0b0000011, 0b101): "LHU rd, imm(rs1)",

    ## 0010011 instructions
    (0b0010011, 0b000): "ADDI rd, rs1, imm",
    (0b0010011, 0b001): "SLLI rd, rs1, shamt",
    (0b0010011, 0b010): "SLTI rd, rs1, imm",
    (0b0010011, 0b011): "SLTIU rd, rs1, imm",
    (0b0010011, 0b100): "XORI rd, rs1, imm",
    (0b0010011, 0b101): "SRLI rd, rs1, shamt",
    (0b0010011, 0b101, 0b0100000): "SRAI rd, rs1, shamt",
    (0b0010011, 0b110): "ORI rd, rs1, imm",
    (0b0010011, 0b111): "ANDI rd, rs1, imm",

    ## 0010111 instructions
    (0b0010111): "AUIPC rd, imm",

    ## 0100011 instructions
    (0b0100011, 0b000): "SB rs2, imm(rs1)",
    (0b0100011, 0b001): "SH rs2, imm(rs1)",
    (0b0100011, 0b010): "SW rs2, imm(rs1)",

    ## 0110011 instructions
    (0b0110011, 0b000, 0b0000000): "ADD rd, rs1, rs2",
    (0b0110011, 0b000, 0b0100000): "SUB rd, rs1, rs2",
    (0b0110011, 0b001, 0b0000000): "SLL rd, rs1, rs2",
    (0b0110011, 0b010, 0b0000000): "SLT rd, rs1, rs2",
    (0b0110011, 0b011, 0b0000000): "SLTU rd, rs1, rs2",
    (0b0110011, 0b100, 0b0000000): "XOR rd, rs1, rs2",
    (0b0110011, 0b101, 0b0000000): "SRL rd, rs1, rs2",
    (0b0110011, 0b101, 0b0100000): "SRA rd, rs1, rs2",
    (0b0110011, 0b110, 0b0000000): "OR rd, rs1, rs2",
    (0b0110011, 0b111, 0b0000000): "AND rd, rs1, rs2",
    ## 0110111 instructions
    (0b0110111): "LUI rd, imm",
    ## 1100011 instructions
    (0b1100011, 0b000): "BEQ rs1, rs2, imm",
    (0b1100011, 0b001): "BNE rs1, rs2, imm",
    (0b1100011, 0b100): "BLT rs1, rs2, imm",
    (0b1100011, 0b101): "BGE rs1, rs2, imm",
    (0b1100011, 0b110): "BLTU rs1, rs2, imm",
    (0b1100011, 0b111): "BGEU rs1, rs2, imm",
    ## 1100111 instructions
    (0b1100111): "JALR rd, rs1, imm",
    ## 1101111 instructions
    (0b1101111): "JAL rd, imm"
}

instruction_types = {
    0b0110011: "R-type",
    0b0000011: "I-type (Load)",
    0b0100011: "S-type (Store)",
    0b1100011: "B-type (Branch)",
    0b0010011: "I-type (Immediate)",
    0b1100111: "I-type (JALR)",
    0b1101111: "J-type (Jump)",
    0b0110111: "U-type (LUI)",
    0b0010111: "U-type (AUIPC)"
}

def sign_extend(value, n_bits):
    '''
    Sign-extend a value to a specified number of bits.

    :param value: The value to sign-extend.
    :param n_bits: The number of bits to sign-extend to.
    :return: The sign-extended value.
    '''
    value = value & ((1 << n_bits) - 1)  # Mask to n_bits
    if (value & (1 << (n_bits - 1))) != 0:
        value = value | (((1 << WIDTH) - 1) ^ ((1 << n_bits) - 1))
    return value

def zero_extend(value, n_bits):
    '''
    Zero-extend a value to a specified number of bits.

    :param value: The value to zero-extend.
    :param n_bits: The number of bits to zero-extend to.
    :return: The zero-extended value.
    '''
    value = value & ((1 << n_bits) - 1)  # Mask to n_bits
    return value

def read_file_to_list(filename):
    with open(filename, 'r') as file:
        return [line.strip() for line in file]

def reverse_hex_string_endiannes(hex_string):  
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    return reversed_string.hex()

def rotate_right(value, shift, n_bits=32):
    '''
    Rotate `value` to the right by `shift` bits.

    :param value: The integer value to rotate.
    :param shift: The number of bits to rotate by.
    :param n_bits: The bit-width of the integer (default 32 for standard integer).
    :return: The value after rotating to the right.
    '''
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    return (value >> shift) | (value << (n_bits - shift)) & ((1 << n_bits) - 1)


def shift_helper(value, shift,shift_type, n_bits=32):
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    match shift_type:
        case 0:
            return (value  << shift)% 0x100000000
        case 1:
            return (value  >> shift) % 0x100000000
        case 2:
            if((value & 0x80000000)!=0):
                    filler = (0xFFFFFFFF >> (n_bits-shift))<<((n_bits-shift))
                    return ((value  >> shift)|filler) % 0x100000000
            else:
                return (value  >> shift) % 0x100000000
        case 3:
            return rotate_right(value,shift,n_bits)

class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address):
        if address < 0 or address + 4 > self.size:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + 4])
        return_val = return_val[::-1]
        return return_val

    def write(self, address, data):
        if address < 0 or address + 4> self.size:
            raise ValueError("Invalid memory address or data length")
        data_bytes = data.to_bytes(4, byteorder='little')
        self.memory[address : address + 4] = data_bytes
    
    def write_byte(self, address, data):
        if address < 0 or address + 1 > self.size:
            raise ValueError("Invalid memory address or data length")
        data_bytes = data.to_bytes(1, byteorder='little')
        self.memory[address : address + 1] = data_bytes
    def write_half(self, address, data):
        if address < 0 or address + 2 > self.size:
            raise ValueError("Invalid memory address or data length")
        data_bytes = data.to_bytes(2, byteorder='little')
        self.memory[address : address + 2] = data_bytes

class InstructionRISCV:
    def __init__(self, hex_inst):
        self.width= 32
        self.min_signed = -(1 << (self.width - 1))  # -8 for 4-bit
        self.max_signed = (1 << (self.width - 1)) - 1  # 7 for 4-bit
        self.max_unsigned = (1 << self.width) - 1  # 15 for 4-bit
        self.min_unsigned = 0  # 0 for 4-bit
        self.ceiling = 1 << self.width # 16 for 4-bit

        self.raw = int(hex_inst, 16)
        self.bin = format(self.raw, '032b')

        self.opcode = int(self.bin[25:32], 2)
        self.rd     = int(self.bin[20:25], 2)
        self.funct3 = int(self.bin[17:20], 2)
        self.rs1    = int(self.bin[12:17], 2)
        self.rs2    = int(self.bin[7:12], 2)
        self.funct7 = int(self.bin[0:7], 2)
        self.imm_i  = int(self.bin[0:12], 2) & 0xFFF ## 12-bit Signed Number
        self.imm_s  = int(self.bin[0:7] + self.bin[20:25], 2) & 0xFFF ## 12-bit Signed Number
        self.imm_b  = int(self.bin[0] + self.bin[24] + self.bin[1:7] + self.bin[20:24] + '0', 2) & 0x1FFF ## 13-bit Signed Number
        self.imm_u  = (int(self.bin[0:20], 2) << 12) & 0xFFFFFFFF ## 32-bit Signed Number
        self.imm_j  = int(self.bin[0] + self.bin[12:20] + self.bin[11] + self.bin[1:11] + '0', 2) & 0x1FFFFF ## 21-bit Signed Number

        self.imm_i = sign_extend(self.imm_i, 12)
        self.imm_s = sign_extend(self.imm_s, 12)
        self.imm_b = sign_extend(self.imm_b, 13)
        #self.imm_u = sign_extend(self.imm_u, 32)
        self.imm_j = sign_extend(self.imm_j, 21)

        # Actual Values with regarding signs
        self.signed_imm_i = self.imm_i if self.imm_i <= self.max_signed else self.imm_i - self.ceiling
        self.signed_imm_s = self.imm_s if self.imm_s <= self.max_signed else self.imm_s - self.ceiling
        self.signed_imm_b = self.imm_b if self.imm_b <= self.max_signed else self.imm_b - self.ceiling
        self.signed_imm_u = self.imm_u if self.imm_u <= self.max_signed else self.imm_u - self.ceiling
        self.signed_imm_j = self.imm_j if self.imm_j <= self.max_signed else self.imm_j - self.ceiling
        

    def log(self, logger, branch_flag):
        logger.debug("Instruction (hex): %s", hex(self.raw))
        #logger.debug("Instruction (binary): %s", self.bin)
        #logger.debug("Opcode: %s", self.bin[25:32])
        #logger.debug("funct3: %s", self.bin[17:20])
        #logger.debug("funct7: %s", self.bin[0:7])
        
        
        
        instruction_type = self.get_instruction_type()
        instruction_name = self.get_instruction_name()
        instruction_format = self.get_instruction_format()
        #logger.debug("Instruction type: %s", instruction_type)
        if branch_flag and instruction_type == "B-type (Branch)":
            logger.debug("Branch Instruction name: %s (TAKEN)", instruction_name)
        elif (branch_flag == False) and instruction_type == "B-type (Branch)":
            logger.debug("Branch Instruction name: %s (NOT TAKEN)", instruction_name)
        else:
            logger.debug("Instruction name: %s", instruction_name)
        logger.debug("Instruction format: %s", instruction_format)
        if instruction_type != "B-type (Branch)" or instruction_type != "S-type (Store)":
            logger.debug("rd: %d", self.rd)
        logger.debug("rs1: %d", self.rs1)
        if instruction_type == "R-type":
            logger.debug("rs2: %d", self.rs2)
        elif instruction_type == "I-type (Load)" or instruction_type == "I-type (Immediate)" or instruction_type == "I-type (JALR)":
            if instruction_name == "SLLI" or instruction_name == "SRLI" or instruction_name == "SRAI":
                logger.debug("uimm: %d", self.rs2)
            else:
                logger.debug("imm: %s | %d", self.bin[0:12], self.signed_imm_i)
        elif instruction_type == "S-type (Store)":
            logger.debug("imm: %s | %d", self.bin[0:7] + self.bin[20:25], self.signed_imm_s)
        elif instruction_type == "B-type (Branch)":
            logger.debug("imm: %s | %d", self.bin[0] + self.bin[24] + self.bin[1:7] + self.bin[20:24] + '0', self.signed_imm_b)
        elif instruction_type == "U-type (LUI)" or instruction_type == "U-type (AUIPC)":
            logger.debug("upimm: %s | %d", self.bin[0:20], self.signed_imm_u)
        elif instruction_type == "J-type (Jump)":
            logger.debug("imm: %s | %d", self.bin[0] + self.bin[12:20] + self.bin[11] + self.bin[1:11] + '0', self.signed_imm_j)

    def get_instruction_type(self):
        '''
        Returns the type of instruction based on the opcode.
        Example: 0x03 is a load instruction, 0x13 is an immediate instruction, etc.
        '''
        return instruction_types.get(self.opcode, "Unknown")
    
    def get_instruction_name(self):
        '''
        Returns the name of the instruction based on the opcode and funct3/funct7 fields.
        Note: This is a simplified mapping and may not cover all instructions.
        '''
        # Check for instruction name based on opcode, funct3, and funct7
        if (self.opcode, self.funct3, self.funct7) in instruction_mappings:
            return instruction_mappings[(self.opcode, self.funct3, self.funct7)]
        elif (self.opcode, self.funct3) in instruction_mappings:
            return instruction_mappings[(self.opcode, self.funct3)]
        elif (self.opcode,) in instruction_mappings:
            return instruction_mappings[(self.opcode,)]
        elif (self.opcode) in instruction_mappings:
            return instruction_mappings[(self.opcode)]
        # If no match found, return the instruction type
        return "Unknown Instruction"
    
    def get_instruction_format(self):
        '''
        Returns the instruction format based on the opcode, funct3, and funct7 fields.
        Example: XOR rd, rs1, rs2
        Example: ADDI rd, rs1, imm
        Example: JALR rd, rs1, imm
        Example: JAL rd
        '''
        # Check for instruction format based on opcode, funct3, and funct7
        if (self.opcode, self.funct3, self.funct7) in instruction_format:
            return instruction_format[(self.opcode, self.funct3, self.funct7)]
        elif (self.opcode, self.funct3) in instruction_format:
            return instruction_format[(self.opcode, self.funct3)]
        elif (self.opcode,) in instruction_format:
            return instruction_format[(self.opcode,)]
        elif (self.opcode) in instruction_format:
            return instruction_format[(self.opcode)]
        # If no match found, return the instruction type
        return "Unknown Instruction"