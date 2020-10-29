# Decoder for Alpha2 mixed-case Unicode format
# See repository LICENSE
import sys

# Decode the given mixed-case-Unicode shellcode
def process_shellcode(shellcode):
    shellcode_len = len(shellcode)

    if shellcode_len % 2 != 0:
        raise RuntimeError("Shellcode must consist of 2-character pairs")

    out_len = shellcode_len // 2
    decoded = []

    for i in range(out_len):
        # Every byte 0xAB is encoded in two characters
        pair = shellcode[i*2:i*2+2]
        val1 = pair[0] # CD
        val2 = pair[1] # EF

        if not chr(val1).isalnum():
            raise RuntimeError("Non-alphanumeric character: %c" % chr(val1))
        if not chr(val2).isalnum():
            raise RuntimeError("Non-alphanumeric character: %c" % chr(val2))

        # Original decoder stops at AA
        if val1 == 0x41 and val2 == 0x41:
            break

        # F = B
        # D = A-E, E is arbitrary; A=D+E

        D = val1 & 0x0F
        E = (val2 >> 4) & 0x0F
        A = (D + E) & 0x0F
        B = val2 & 0x0F

        decoded.append(((A << 4) | B) & 0xff)
    return bytes(decoded)

EXPECTED_PREFIX = b"VVYAIAIAIAIAIAIAIAIAIAIAIAIAIAIA"
EXPECTED_BODY = b"jXAQADAZABARALAYAIAQAIAQAIAhAAAZ1AIAIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JB"

# Process a full Alpha2 payload
def process_payload(payload):
    payload_len = len(payload)
    skip_len = len(EXPECTED_PREFIX) + len(EXPECTED_BODY)
    min_len = skip_len + 2

    if payload_len < min_len:
        raise RuntimeError("Payload is too short")

    if payload[:len(EXPECTED_PREFIX)] != EXPECTED_PREFIX:
        raise RuntimeError("Payload does not begin with prefix for mixed-case Unicode")
    if payload[len(EXPECTED_PREFIX):len(EXPECTED_PREFIX) + len(EXPECTED_BODY)] != EXPECTED_BODY:
        raise RuntimeError("Payload does not have correct decoder loop after prefix")
    return process_shellcode(payload[skip_len:])

def main():
    if len(sys.argv) != 2:
        print("Usage: %s <path to payload.txt>" % sys.argv[0])
        sys.exit(1)
    with open(sys.argv[1], 'rb') as payload_file:
        payload = payload_file.read()
        print("Result: %s" % bytes.hex(process_payload(payload)))

if __name__ == "__main__":
    main()