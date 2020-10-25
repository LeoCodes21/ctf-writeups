# Implementation of Util.Decode function

def decode(input):
    return ''.join(
        map(chr, 
            map(lambda x: x ^ 83, input)))

if __name__ == "__main__":
    print(decode(b'\x3E\x26\x3F\x3F\x36\x27\x3B\x32\x27'))