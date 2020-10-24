# #2 - garbage by Jon Erickson

## Introduction

In this challenge we are presented with a 40 KB `.exe` file called `garbage`, as well as a message:

> One of our team members developed a Flare-On challenge but accidentally deleted it. We recovered it using extreme digital forensic techniques but it seems to be corrupted. We would fix it but we are too busy solving today's most important information security threats affecting our global economy. You should be able to get it working again, reverse engineer it, and acquire the flag.

Looks like we've got our work cut out for us. Let's get started.

## Part 1 - Recon

If we open the .exe file in a hex editor, it doesn't take long to see the first red flag:

![UPX0 segment at 0x1F0](https://s.heyitsleo.io/ShareX/2020/10/HxD_6FsuWE9wiR.png)

This is the mark of ~~the beast~~ UPX, or the [**Ultimate Packer for eXecutables**](https://upx.github.io/). Luckily, the tool for packing an executable also allows you to _unpack_ an executable. We should be good to go, right?

Nope.
![UPX failed to unpack](https://s.heyitsleo.io/ShareX/2020/10/WindowsTerminal_HC2Q9VJYyK.png)

> `Invalid overlay size; file is possibly corrupt`

Remember what the challenge message said?

> We recovered it using extreme digital forensic techniques but it seems to be corrupted

Now let's look at the _end_ of the file in the hex editor.

![Truncated data at the end](https://s.heyitsleo.io/ShareX/2020/10/HxD_YG87KAc5Hk.png)

Obviously this isn't right. What we're looking at is a truncated [assembly manifest](https://docs.microsoft.com/en-us/windows/win32/sbscs/assembly-manifests). We might want to fix the manifest, but first we need to track down the exact cause of the UPX error. Let's fire up [CFF Explorer](https://www.ntcore.com/?page_id=388) and see what we can do.

## Part 2 - restoring (some) order

After loading the `garbage.exe` file into CFF Explorer, we can see an overview of it.

![CFF Explorer overview](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_neeto8VSrA.png)

Let's go to the "Section Headers" tab. Recall that Windows executables are split up into "sections." Since we saw a truncated **assembly manifest** at the end of the file, we know something's up with the `.rsrc` (resources) section.

When we navigate to Section Headers, we see the following:
![Section headers data](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_gFyAtWlVMO.png)

We only care about the "Raw Size" and "Raw Address" columns (both are hexadecimal)

| Section name | Section raw address | Section raw size |
|--------------|---------------------|------------------|
| UPX0         | 00000400            | 00000000         |
| UPX1         | 00000400            | 00009A00         |
| .rsrc        | 00009E00            | 00000400         |

Note the offset and size of `.rsrc`: `0x9E00` and `0x400`. The data should end at offset `0xA200`. But it doesn't - instead, it ends at offset `0x9F24`! The next step is clear - insert padding. We have to insert `0x2DC` bytes of padding (typically `0x00`) at the end of the file.

![HxD edit menu](https://s.heyitsleo.io/ShareX/2020/10/HA6pCXXmNT.png)

![Insert Bytes popup](https://s.heyitsleo.io/ShareX/2020/10/HxD_OF9WxUZ5Gs.png)

![Final result](https://s.heyitsleo.io/ShareX/2020/10/HxD_L634sNx6iW.png)

Now that we've got that out of the way, let's try UPX again.

![UPX succeeded](https://s.heyitsleo.io/ShareX/2020/10/WindowsTerminal_t6iZkeoWcU.png)

Hooray! We're on the right track. Let's load the unpacked EXE into IDA and see what we get.

![IDA didn't resolve any imports?](https://s.heyitsleo.io/ShareX/2020/10/ida_GGp8aitrMT.png)

Rats. What happened here?

## Part 3 - restoring order, again

Upon opening IDA's **Imports** tab, we are greeted with _absolutely nothing._

![Indeed, no imports were loaded](https://s.heyitsleo.io/ShareX/2020/10/ida_09LBiunZ1t.png)

Let's load the unpacked EXE into CFF Explorer and check out the **import directory**, the part of the executable that holds information about - you guessed it - imports.

![Blank module names in imports](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_L0LSF581al.png)

Notice the two `Module Name` values are blank. Perhaps this is the problem. If we click on the first module entry, we can see that it's importing functions like `GetCurrentProcess` and `WriteFile`.

![KERNEL32 imports](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_OcyjhF6dHg.png)

 These come from `KERNEL32.DLL`, so we can update the `Module Name` accordingly. The second module entry is importing `ShellExecuteA`, a telltale sign that we're looking at `SHELL32.DLL`.

 ![SHELL32 imports](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_Ba4iuWnlne.png)

 We can once again update the `Module Name` value, and then save the executable.

 ![Fixed module names](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_APDbyKEgya.png)

 If we load the patched executable into IDA, we can see that it was able to resolve imports correctly.

 ![Better decompilation](https://s.heyitsleo.io/ShareX/2020/10/ida_kNOWAIGM5J.png)

 At this point, we have two options:
 1. Reverse engineer the flag generation
 2. Fix the EXE's manifest so we can run it

 Let's try option 2 first.

 ### Fixing the manifest

 Recall that the EXE's manifest was truncated, as shown below:

 ![Truncated manifest](https://s.heyitsleo.io/ShareX/2020/10/CFF_Explorer_TB2Ppsij7F.png)

 Because of this, the EXE will not run. Let's replace the manifest with our own:
 
 ```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
	<assemblyIdentity
		name="garbage"
		processorArchitecture="x86"
		version="1.0.0.0"
		type="win32"/>
	<description>Flare-On 2020 challenge #2</description>
</assembly>
 ```

 This gives Windows all the information it needs about the EXE. If we run our newly-patched EXE, we're greeted with the flag:

 ![Victory!](https://s.heyitsleo.io/ShareX/2020/10/MLP2YBUr1H.png)

 The flag is `C0rruptGarbag3@flare-on.com` . Looking at the folder with the EXE, we can see a new file was created: `sink_the_tanker.vbs`

 ![sink_the_tanker](https://s.heyitsleo.io/ShareX/2020/10/explorer_RRh2h3nJrw.png)

 This file contains a single line of Visual Basic code:

 `MsgBox("Congrats! Your key is: C0rruptGarbag3@flare-on.com")`

 Great, no obfuscation there. Now, how could we have done this _without_ running the application?

 ### Static analysis

 The code for the `main` function is _interesting_, to say the least. Here's a small excerpt:

 ```cpp
   v12 = 741548835;
  v13 = 1231306510;
  strcpy(&v10, "nPTnaGLkIqdcQwvieFQKGcTGOTbfMjDNmvibfBDdFBhoPaBbtfQuuGWYomtqTFqvBSKdUMmciqKSGZaosWCSoZlcIlyQpOwkcAgw ");
  v14 = 67771914;
  v15 = 436344355;
  v16 = 604530244;
  strcpy(&v11, "KglPFOsQDxBPXmclOpmsdLDEPMRWbMDzwhDGOyqAkVMRvnBeIkpZIhFznwVylfjrkqprBPAdPuaiVoVugQAlyOQQtxBNsTdPZgDH ");
  v17 = 745804082;
  v18 = 255995178;
  v19 = 224677950;
  v20 = 387646557;
```

It seems like we're working with code that uses a lot of stack arrays. The Hex-Rays decompiler isn't great at detecting these, so we need to step in and do some clean-up work.

Let's deal with `v10` and `v11` first. We'll use IDA's stack offset comments to help us figure out the appropriate array sizes.

```c
  char v10; // [esp+20h] [ebp-128h]
  char v11; // [esp+88h] [ebp-C0h]
  int v12; // [esp+F0h] [ebp-58h]
```

We can see that `v10` is at `ebp-128h`, while `v11` is at `ebp-C0h`. We can subtract `0xC0` from `0x128` to get `0x68`, indicating that the proper declaration of `v10` is

```c
char v10[0x68];
```

 `v11` is the same length (`0xC0 - 0x58 = 0x68`), so now we can re-type both variables accordingly.

 ![New variables](https://s.heyitsleo.io/ShareX/2020/10/ida_G1KeLUavpQ.png)

 The strings `nPTnaGLkIqdcQwvieFQKGcTGOTbfMjDNmvibfBDdFBhoPaBbtfQuuGWYomtqTFqvBSKdUMmciqKSGZaosWCSoZlcIlyQpOwkcAgw ` and `KglPFOsQDxBPXmclOpmsdLDEPMRWbMDzwhDGOyqAkVMRvnBeIkpZIhFznwVylfjrkqprBPAdPuaiVoVugQAlyOQQtxBNsTdPZgDH ` are copied into `v10` and `v11` respectively. These will become important later.

 Let's look at the next interesting bit of code:
 ```cpp
  v28 = 989990456;
  v29 = 874199833;
  v30 = 1042484251;
  v31 = 1108412467;
  v32 = 1931350585;
  sub_401000(&lpFileName, (int)&v28, 20, (int)v11, 0);
```

There are two arguments of interest here:
- `(int)&v28`
- `20`

Notice that there are assignments to 5 integer variables before the call to `sub_401000`. Each integer occupies 4 bytes, and `4 * 5 = 20`. However, it's **extremely** important to note the fact that this is a compiler optimization. 
**A bunch of 1-byte assignments may get converted to a bunch of 4-byte assignments, with byte or word assignments to deal with any remainder.**

With this in mind, let's change the type of `v28` from an `int` to a `char[20]`. The decompiled output isn't pretty, but it will have to do.
```cpp
*(_DWORD *)v28 = 0x3B020E38;
*(_DWORD *)&v28[4] = 0x341B3B19;
*(_DWORD *)&v28[8] = 0x3E230C1B;
*(_DWORD *)&v28[12] = 0x42110833;
*(_DWORD *)&v28[16] = 0x731E1239;
``` 

We also have this to deal with:
`sub_401000(&lpFileName, (int)&v12, 61, (int)v10, v4);`
Now let's change the type of `v12` from an `int` to a `char[61]`.

\* Recall that `v10` is a _string_ (character array). The signature of `sub_401000` will need to be updated.

Decompiling `sub_401000` yields the following pseudocode:

```cpp
_DWORD *__thiscall sub_401000(_DWORD *this, int a2, int a3, int a4, int a5)
{
  unsigned int v5; // edi

  v5 = 0;
  *this = a2;
  this[1] = a3;
  this[2] = a4;
  this[3] = 102;
  ... truncated for brevity
  return this;
}
```

This appears to be a constructor function that takes arguments. We can create a structure of length `0x10`, or 4 machine words. First, though, we should fix the signature. We can remove `a5` because it's never used, and also change the return type to `void`. Then we can consider the arguments.

Consider this function call:
`sub_401000(&lpFileName, (int)&v12, 61, (int)v10, v4);`

We know that `&lpFileName` is an instance of our `0x10`-length structure. To be sure of this, we can check the stack-variable comments:
```cpp
  LPCSTR lpFileName; // [esp+10h] [ebp-138h]
  char v8[104]; // [esp+20h] [ebp-128h]
```
Indeed, `0x138 - 0x128 = 0x10`.

We also know that `&v12` is an array of 61 bytes (or 64, if you want to round up.)
`61` is the length of the array, `v10` seems to be a decryption key, and `v4` is the unused 5th argument (it appears because of the incorrect constructor return type.)

Remember the constructor code:
```cpp
  *this = a2;
  this[1] = a3;
  this[2] = a4;
  this[3] = 102;
```

We can create a `decipher_ctx` structure as follows:
```cpp
struct decipher_ctx {
    unsigned char* data;
    unsigned int datalen;
    unsigned char* key;
    unsigned int keylen; // = 102 (we rounded up the array size to a multiple of 4)
};
```

Our new signature for `sub_401000` is:
`void __thiscall sub_401000(decipher_ctx *this, unsigned __int8 *data, int datalen, unsigned __int8 *key)`

We can rename this function to `decipher_ctx::ctor`. The decompiled code makes much more sense now.

```cpp
void __thiscall decipher_ctx::ctor(decipher_ctx *this, unsigned char *data, unsigned int datalen, unsigned char *key)
{
  unsigned int i; // edi

  i = 0;
  this->data = data;
  this->datalen = datalen;
  this->key = key;
  this->keylen = 102;
  if ( datalen )
  {
    do
    {
      this->data[i] ^= this->key[i % this->keylen];
      ++i;
    }
    while ( i < this->datalen );
  }
}
```

This is a simple XOR cipher. Nothing about it is particularly interesting.

Going back to the main function, we now see code like this:
`decipher_ctx::ctor((decipher_ctx *)&lpFileName, (unsigned __int8 *)v11, 20, (unsigned __int8 *)v9);`

Let's change the type of the `lpFileName` variable to `decipher_ctx`, and rename it to something more meaningful (such as `ctx`.) We can also change `v8`, `v9` and `v11` to be arrays of **unsigned** `char` rather than signed.

There is also a call to `sub_401045(&ctx);`. We can change the signature of this function from `char __thiscall sub_401045(_DWORD *this)` to `void __thiscall sub_401045(decipher_ctx*)`, as the supposed return value isn't ever used.

The pseudocode listing makes it clear that this is just re-encrypting the data:

```cpp
void __thiscall sub_401045(decipher_ctx *this)
{
  unsigned int i; // esi

  i = 0;
  if ( this->datalen )
  {
    do
    {
      this->data[i] ^= this->key[i % this->keylen];
      ++i;
    }
    while ( i < this->datalen );
  }
}
```

We can rename this to `decipher_ctx::reset`. Now we should have a much easier time understanding what's happening.

Going back to `main`, we can rename some more variables:
| Old variable name | New variable name |
|-------------------|-------------------|
| v8                | filedata_key      |
| v9                | filename_key      |
| v10               | filedata          |
| v11               | filename          |

Now we can work on reimplementing this cipher in Python. Since the code will mostly be a port of the C pseudocode, I won't put it in this document. You can find it [here](./decrypt.py). One new function was added to facilitate conversion from int arrays to byte arrays:

```py
def ints2bytes(int_array):
    result = bytearray(len(int_array) * 4)
    for i in range(len(int_array)):
        struct.pack_into('<I', result, i*4, int_array[i])
    return result
```

Running the Python script gives us the results:
```
Filename: sink_the_tanker.vbs
File contents: MsgBox("Congrats! Your key is: C0rruptGarbag3@flare-on.com")
```

And there we have it! Two different ways to solve the problem - which one would you have chosen?