# #8 - Aardvark by Jacob Thompson

## Introduction

For the 8th challenge, we're given a file called `ttt2.exe`, accompanied by the following message:

```
Expect difficulty running this one. I suggest investigating why each error is occuring. Or not, whatever. You do you.
```

As it turns out, though, looks can be deceiving - with a bit of setup, this challenge won't be problematic at all.

## Part 1 - Recon

Loading the binary in IDA Pro shows it is a 64-bit Windows application. Since the challenge description kindly warned us that there would be multiple errors, we should see if we can find any interesting messages in the binary.

Upon opening IDA's strings view, we can immediately see some interesting messages:

![Some of the possible error messages](https://s.heyitsleo.io/ShareX/2020/12/ida64_dVND9yM4o6.png)

Hold on _just_ a second. This is a Windows app, yet we're dealing with [Unix sockets](https://en.wikipedia.org/wiki/Unix_domain_socket)? This caught me off guard at first, but my confusion evaporated when I saw this:

![Some more error messages](https://s.heyitsleo.io/ShareX/2020/12/ida64_mLxKbd6kIy.png)

That last string is important: `Default distribution must be WSL 1.` If you're unfamiliar with it, WSL ("Windows Subsystem for Linux") is an extension to Windows 10 that allows users to natively run Linux applications on Windows systems. It seems like this challenge wants to run a Linux application, although the reason for that is not immediately clear.

## Part 2 - Environment setup

In order to work on this challenge, we'll need to set up our system to fit the required specifications. The executable helpfully tells us that we have to be on Windows 10, build **1803, 1809, 1903, 1909, 2004, or 20H2**. We also need to have WSL **v1** installed (there's a **v2** available, but we do not want that.) 

If you want to follow along, information on installing WSL can be found [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Note that you should _not_ run the command to set WSLv2 as the default.

Once WSL setup is complete, we need to install the [Ubuntu 18.04](https://www.microsoft.com/store/apps/9N9TNGVNDL3Q) distribution. You _should_ be able to get away with using a different one, but I did not test that when I was first working on this challenge.

## Part 3 - Testing the challenge

Once everything is set up, we can launch `ttt2.exe` to see what it does. Based on some other strings, like `BOARD` and `That space is already taken`, this will probably be a game.
Maybe even... Tic-Tac-Toe?

![It lives!](https://s.heyitsleo.io/ShareX/2020/12/ttt2_yzbJSJME2r.png)

If we try to play it, we will quickly realize that the game is rigged against us. The computer plays as X, and we play as O, but the computer will always get in our way when we try to make a move. It's possible to end the game in a draw, but you can never _win._

![Impossible game](https://s.heyitsleo.io/ShareX/2020/12/ttt2_aItfOBkMqn.png)

At this point, we should focus on figuring out how the game works. Perhaps we can find another way to get to the flag.

## Part 4 - Finally, some actual reversing

After digging through the executable's `start` function, which contains a bunch of [CRT](https://docs.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=msvc-160) boilerplate, we find the main function at `1400015A0`. This is where we find some of the error messages.

```cpp
int GameMain()
{
  ...
  if ( GetTempPathA(0x105u, Buffer) )
    SetCurrentDirectoryA(Buffer);
  if ( WSAStartup(0x202u, &WSAData) )
  {
    MessageBoxA(0i64, "Error initializing Winsock", "Error", 0x10u);
    goto LABEL_17;
  }
  ...
  if ( bind(v4, &name, 110) == -1 )
  {
    v6 = "bind failed";
  }
  else
  {
    if ( listen(v4, 0x7FFFFFFF) != -1 )
      goto LABEL_12;
    v6 = "listen failed";
  }
}
```

We still haven't figured out how Linux is involved, though. After getting past the socket errors, we can see a call to another function: `sub_1400012B0`.

```cpp
  if ( CoInitializeSecurity(0i64, -1, 0i64, 0i64, 0, 3u, 0i64, 0, 0i64) )
  {
    CoUninitialize();
    goto LABEL_15;
  }
  if ( sub_1400012B0() )
  {
    gSocket = accept(v4, 0i64, 0i64);
    ...
```

`sub_1400012B0` is responsible for loading an [embedded resource](https://docs.microsoft.com/en-us/windows/win32/menurc/rcdata-resource) and saving it to a temporary file. That's not all it does, though: after saving the file, it performs Windows version checks, and finally, **launches the file as a Linux executable in the WSL container!**

There are multiple versions of the WSL launcher code, likely to support all of the listed Windows 10 builds, but they share one key trait: instead of calling an easy-to-identify API, an undocumented WSLv1 [COM](https://docs.microsoft.com/en-us/windows/win32/com/the-component-object-model) API is used. (Just because it's undocumented doesn't mean it's unresearched - the API has been [reverse](https://github.com/Biswa96/WslReverse) [engineered](https://github.com/ionescu007/lxss) by various individuals.)

## Part 5 - What's that resource?

Let's go back and investigate that resource the challenge was dropping to disk. Using a tool like [CFF Explorer](https://www.ntcore.com/?page_id=388), we can extract the resource named `300`:

![CFF resource viewer](https://s.heyitsleo.io/ShareX/2020/12/HappKETjQe.png)

If we open the resource data in a hex editor, we can see it starts with the bytes `7F 45 4C 46`, or `.ELF` . This is the executable we were looking for, so let's open it in IDA.

The `main` function of this binary is rather long, but its functionality can be easily summarized:

1. Connect to the domain socket set up by the main executable
2. Wait for the player to make a move
3. Compute and make an obstructing move
4. Repeat from step 2.

Once the _player_ has won the game (which - remember - cannot happen!), the binary will go through a convoluted set of procedures, all of which mutate a small byte array at address `202010`. Each procedure reads the contents of a Linux system file (or does some other platform-specific action), and depending on the result, either modifies the byte array or leaves it alone. 

Upon analysis, it becomes clear that these are designed to confuse anyone who tries to be clever by running the Linux binary on an actual Linux system. WSLv1 does not use a real Linux kernel, so it's possible to detect when the software is running somewhere it shouldn't be. For example:
```cpp
stream = fopen("/proc/modules", "r");
if ( stream )
{
    // brief description of what this procedure does: read contents of the /proc/modules file, if "cpufreq_" is found then mutate the global byte array
}
```

Seeing such code might fluster the analyst, but it's really much ado about nothing, as there _isn't a `/proc/modules` file in WSLv1._

```sh
pwnie@DESKTOP:/mnt/c/Users/coder$ cat /proc/modules
cat: /proc/modules: No such file or directory
```

This file _does_ exist on real Linux systems, so debugging the binary on such a system would completely ruin the result it gives.

## Part 6 - Playing to win (Endgame)

With all that said, there's a simple way to beat the game and get the flag. All we need to do is find the code that makes the computer send a move for X, and make it play as O instead. Luckily, this is trivial. Before the anti-debug code, we can find the code that responds to our move:

```cpp
v6[3 * v8 + i] = 'X';
byte_2020A9 = sub_14B0(v5, v4);
send(fd, &byte_2020A0, 0xAuLL, 0);
```

In order to make the change, we need to replace the assembly code in the binary. We'll patch `ttt2.exe` directly.
We can replace the byte sequence `48 63 D2 48 8D 04 40 48 01 D8 C6 04 10 58` with `48 63 D2 48 8D 04 40 48 01 D8 C6 04 10 4F`. The only change we made was changing `58` to `4F`, or `X` to `O`.

Now we can save `ttt2.exe`, run it, and make any move we want. We instantly win, and get the flag: **`c1ArF/P2CjiDXQIZ@flare-on.com`**\*

![Victory!](https://s.heyitsleo.io/ShareX/2020/12/ttt2_9PJlRf9oJh.png)

\* Yes, this is actually the flag. When I saw this, I was confused, but figured I would try submitting it anyway. I got lucky - some players wasted several hours before they realized they had actually gotten the right answer.

## Conclusion

This challenge was fun, although a bit strange - the previous 7 challenges had gotten me used to seeing flags that actually said something, not random strings of letters and numbers. In any case, this was a nice adventure into the depths of undocumented Windows APIs and platform-specific Linux quirks.

## Bonus

At first I didn't understand why this challenge was called "Aardvark", until I heard about the [AARD code](https://en.wikipedia.org/wiki/AARD_code). AARD was a Windows 3.1 feature that relied on various undocumented aspects of DOS in order to detect if a machine was running DR-DOS. If it was, then AARD would show intentionally cryptic error messages, in an attempt to get users to buy Microsoft's software.