def ToHex(value):
    try:
        return hex(value.integer)
    except:
        return "0b" + str(value)

def ToBin(value):
    try:
        return bin(value.integer)
    except:
        return "0b" + str(value)

def ToDec(value):
    try:
        return str(int(value.integer))
    except:
        return "0b" + str(value)

def Log_Datapath(dut, logger):
    logger.debug("************ DUT DATAPATH Signals ***************")
    logger.debug("PC      (Decimal) : %s", ToDec(dut.Debug_PC.value))
    logger.debug("PCNext  (Decimal) : %s", ToDec(dut.datapath_inst.PCNext.value))
    logger.debug("Instruction       : %s", ToHex(dut.datapath_inst.INSTRUCTION.value))
    logger.debug("Rs1     (Decimal) : %s", ToDec(dut.datapath_inst.Ra1.value))
    logger.debug("Rs2     (Decimal) : %s", ToDec(dut.datapath_inst.Rs2.value))
    logger.debug("Rd      (Decimal) : %s", ToDec(dut.datapath_inst.Rd.value))
    logger.debug("WD                : %s", ToHex(dut.datapath_inst.WD.value))
    logger.debug("Rd1               : %s", ToHex(dut.datapath_inst.RD1.value))
    logger.debug("Rd2               : %s", ToHex(dut.datapath_inst.RD2.value))
    logger.debug("ImmExt            : %s", ToHex(dut.datapath_inst.ImmExt.value))
    logger.debug("ALUSrcA           : %s", ToHex(dut.datapath_inst.SrcA.value))
    logger.debug("ALUSrcB           : %s", ToHex(dut.datapath_inst.SrcB.value))
    logger.debug("ALUResult         : %s", ToHex(dut.datapath_inst.ALUResult.value))
    logger.debug("MemoryAddress     : %s", ToHex(dut.datapath_inst.ALUResult.value))
    logger.debug("WriteData         : %s", ToHex(dut.datapath_inst.WriteData.value))
    logger.debug("ReadData          : %s", ToHex(dut.datapath_inst.ReadData.value))
    logger.debug("UART_TRANSMIT_DATA: %s", ToHex(dut.datapath_inst.UART_TRANSMIT_DATA.value))
    logger.debug("UART_RECEIVE_DATA : %s", ToHex(dut.datapath_inst.UART_RECEIVE_DATA.value))
    logger.debug("00:ALUResult      : %s", ToHex(dut.datapath_inst.ALUResult.value))
    logger.debug("01:PCTarget       : %s", ToHex(dut.datapath_inst.PCTarget.value))
    logger.debug("10:ValidReadData  : %s", ToHex(dut.datapath_inst.ValidReadData.value))
    logger.debug("11:ExtendedMemory : %s", ToHex(dut.datapath_inst.ExtendedMemory.value))
    logger.debug("Result            : %s", ToHex(dut.datapath_inst.Result.value))


def Log_UART(dut, logger):
    logger.debug("************ DUT UART Signals ***************")
    logger.debug("UART_TX            : %s", ToBin(dut.TX_to_OUTSIDE.value))

def Log_Controller(dut, logger):
    logger.debug("************ DUT CONTROLLER Signals ***************")

    logger.debug("Instruction: %s", ToHex(dut.controller_inst.INSTRUCTION.value))
    logger.debug("ZeroBit    : %s", ToBin(dut.controller_inst.ZeroBit.value))
    logger.debug("CMPBit     : %s", ToBin(dut.controller_inst.CMPBit.value))
    logger.debug("ImmSrc     : %s", ToBin(dut.controller_inst.ImmSrc.value))
    logger.debug("ALUSrcA    : %s", ToBin(dut.controller_inst.ALUSrcA.value))
    logger.debug("ALUSrcB    : %s", ToBin(dut.controller_inst.ALUSrcB.value))
    logger.debug("ALUControl : %s", ToBin(dut.controller_inst.ALUControl.value))
    logger.debug("StoreSrc   : %s", ToBin(dut.controller_inst.StoreSrc.value))
    logger.debug("LoadByte   : %s", ToBin(dut.controller_inst.LoadByte.value))
    logger.debug("LoadSign   : %s", ToBin(dut.controller_inst.LoadSign.value))
    logger.debug("ResultSrc  : %s", ToBin(dut.controller_inst.ResultSrc.value))
    logger.debug("RegWrite   : %s", ToBin(dut.controller_inst.RegWrite.value))
    logger.debug("MemWrite   : %s", ToBin(dut.controller_inst.MemWrite.value))
    logger.debug("PCSrc      : %s", ToBin(dut.controller_inst.PCSrc.value))
    logger.debug("Link       : %s", ToBin(dut.controller_inst.Link.value))
    logger.debug("isSLT      : %s", ToBin(dut.controller_inst.isSLT.value))
    logger.debug("isU        : %s", ToBin(dut.controller_inst.isU.value))
    logger.debug("SELECT_UART: %s", ToBin(dut.controller_inst.SELECT_UART.value))
