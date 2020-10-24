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

Hooray! We're on the right track.