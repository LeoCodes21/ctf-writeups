# https://github.com/fireeye/flare-ida/blob/master/shellcode_hashes/make_sc_hash_db.py#L160
ROTATE_BITMASK = {
    8  : 0xff,
    16 : 0xffff,
    32 : 0xffffffff,
    64 : 0xffffffffffffffff,
}

def rcr(inVal, numShifts, cb, dataSize=32):
    '''rotate carry right instruction emulation'''
    if numShifts == 0:
        return inVal
    if (numShifts < 0) or (numShifts > dataSize):
        raise ValueError('Bad numShifts')
    #make sure carry in bit is only 0 or 1
    cb = cb & 1
    if (dataSize != 8) and (dataSize != 16) and (dataSize != 32) and (dataSize != 64):
        raise ValueError('Bad dataSize')
    #or the carry value in there
    bitMask = ROTATE_BITMASK[dataSize]
    inVal = inVal | (cb << dataSize)
    x = (dataSize - numShifts) + 1
    res = (inVal >> numShifts) | (inVal << x)
    return (bitMask & res, 1 & (res >> dataSize))

def ror(inVal, numShifts, dataSize=32):
    '''rotate right instruction emulation'''
    if numShifts == 0:
        return inVal
    if (numShifts < 0) or (numShifts > dataSize):
        raise ValueError('Bad numShifts')
    if (dataSize != 8) and (dataSize != 16) and (dataSize != 32) and (dataSize != 64):
        raise ValueError('Bad dataSize')
    bitMask = ROTATE_BITMASK[dataSize]
    return bitMask & ((inVal >> numShifts) | (inVal << (dataSize-numShifts)))

def rol(inVal, numShifts, dataSize=32):
    '''rotate left instruction emulation'''
    if numShifts == 0:
        return inVal
    if (numShifts < 0) or (numShifts > dataSize):
        raise ValueError('Bad numShifts')
    if (dataSize != 8) and (dataSize != 16) and (dataSize != 32) and (dataSize != 64):
        raise ValueError('Bad dataSize')
    bitMask = ROTATE_BITMASK[dataSize]
    currVal = inVal
    return bitMask & ((inVal << numShifts) | (inVal >> (dataSize-numShifts)))\

def rol19AddHash32(inString):
    if inString is None:
        return 0
    val = 0
    for i in inString:
        val = rol(val, 19, 32)
        val += ord(i)
    return val

print(hex(rol19AddHash32("WS2_32.DLL")))