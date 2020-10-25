# Script to decrypt the contents of Runtime_dll.bin
from py3rijndael import RijndaelCbc, Pkcs7Padding
import base64
import hashlib
import sys

PASSWORD    = b"mullethat"
STEP        = b"magic"
NOTE        = b"keep steaks for dinner"
DESC        = b"water"
KEY_SRC     = bytearray([
    DESC[2],
    PASSWORD[6],
    PASSWORD[4],
    NOTE[4],
    NOTE[0],
    NOTE[17],
    NOTE[18],
    NOTE[16],
    NOTE[11],
    NOTE[13],
    NOTE[12],
    NOTE[15],
    STEP[4],
    PASSWORD[6],
    DESC[1],
    PASSWORD[2],
    PASSWORD[2],
    PASSWORD[4],
    NOTE[18],
    STEP[2],
    PASSWORD[4],
    NOTE[5],
    NOTE[4],
    DESC[0],
    DESC[3],
    NOTE[15],
    NOTE[8],
    DESC[4],
    DESC[3],
    NOTE[4],
    STEP[2],
    NOTE[13],
    NOTE[18],
    NOTE[18],
    NOTE[8],
    NOTE[4],
    PASSWORD[0],
    PASSWORD[7],
    NOTE[0],
    PASSWORD[4],
    NOTE[11],
    PASSWORD[6],
    PASSWORD[4],
    DESC[4],
    DESC[3]
])

# Compute hash of KEY_SRC
m = hashlib.sha256()
m.update(KEY_SRC)

key = m.digest()
iv = b'NoSaltOfTheEarth'

ri = RijndaelCbc(
    key=key, 
    iv=iv,
    padding=Pkcs7Padding(16)
)
in_data = open('./Runtime_dll.bin', 'rb').read()
in_data_len = len(in_data)

if in_data_len % 16 != 0:
    print("data length not divisible by 16")
    sys.exit(1)

decrypted = ri.decrypt(in_data)
decoded = base64.b64decode(decrypted)

out_file = open('out_data.jpg', 'wb')
out_file.write(decoded)
out_file.close()