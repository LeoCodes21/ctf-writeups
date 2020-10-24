# #3 - wednesday by Blaine Stancill (@MalwareMechanic)

## Introduction

In this challenge we are presented with a game called `mydude.exe`. It comes with a README telling the player to "BE THE WEDNESDAY", whatever that means.

## Part 1 - Recon

Just by glancing at the folder with binaries, it's clear that `mydude.exe` relies heavily on the [SDL2](https://www.libsdl.org/) library. 

![Files](https://s.heyitsleo.io/ShareX/2020/10/explorer_wHeqgoyVix.png)

Loading the game executable into IDA reveals something interesting: **DWARF info** exists in the file.

![DWARF info](https://s.heyitsleo.io/ShareX/2020/10/ida_noh7B0XwLH.png)

This gives us access to function names and rough function prototypes. Looking at the `main` function (address `00439F20`), we can see references to [Nim](https://nim-lang.org/), a programming language that can compile to several targets - including C and C++.

![Nim refs](https://s.heyitsleo.io/ShareX/2020/10/ida_r1nDvaus2I.png)

Going down the call tree, we find a function called `NimMainModule`. This is where our analysis should begin. (A word of warning: Nim code is quite frustrating to reverse engineer if you've never had to work with it before.)

## Part 2 - Scenes

It doesn't take too long to find references to "scenes" in the `NimMainModule` function. The title screen shown below is internally called `titleScene__IJdI0I6iwHtKh49aA8VvvxQ`.

![Title screen](https://s.heyitsleo.io/ShareX/2020/10/mydude_8vuDDPDHAt.png)

It is initialized by the following code:

```cpp
    v8 = newTitleScene__Jgb4BcSSCCr8oKdNvDvNGA();
    v10 = v8;
    if ( v8 )
      *(_DWORD *)(v8 - 8) += 8;
    v11 = titleScene__IJdI0I6iwHtKh49aA8VvvxQ;
    if ( titleScene__IJdI0I6iwHtKh49aA8VvvxQ )
    {
      v9 = titleScene__IJdI0I6iwHtKh49aA8VvvxQ - 8;
      v12 = *(_DWORD *)(titleScene__IJdI0I6iwHtKh49aA8VvvxQ - 8) - 8;
      *(_DWORD *)(titleScene__IJdI0I6iwHtKh49aA8VvvxQ - 8) = v12;
      if ( v12 <= 7 )
        addZCT__Y66tOYFjgwJ0k4aLz4bc0Q(&dword_44B54C, v11 - 8);
    }
    titleScene__IJdI0I6iwHtKh49aA8VvvxQ = v10;
```

There are similar initializers for the game itself (`mainScene_e7lrGlcCQSSCGHoN5Snd4g`) and the flag screen (`winScene__eVaCVkG1QBiYVChMxpMGBQ` .)

Finally, a function call is made in order to show the title screen: 

```cpp
sceneeq___HC7o4hYar8OQigU09cNyehg(game__7aozTrKmb7lwLeRmW9a9cs9cQ, titleScene__IJdI0I6iwHtKh49aA8VvvxQ);
```

Let's look for other references to this `sceneeq___HC7o4hYar8OQigU09cNyehg` function - it seems important. As it turns out, three other functions call it:

- `play__KWsuYX9aT5ERuB7nam2fV1w`

    ```cpp
    return sceneeq___HC7o4hYar8OQigU09cNyehg(game__7aozTrKmb7lwLeRmW9a9cs9cQ, mainScene__e7lrGlcCQSSCGHoN5Snd4g);
    ```
- `event__H0DXYyuBaoNcma9a816slhw`

    ```cpp
    return sceneeq___HC7o4hYar8OQigU09cNyehg(game__7aozTrKmb7lwLeRmW9a9cs9cQ, mainScene__e7lrGlcCQSSCGHoN5Snd4g);
    ```
- `update__Arw3f6ryHvqdibU49aaayOg`

    ```cpp
    if ( *v22 == 296 )
      sceneeq___HC7o4hYar8OQigU09cNyehg(game__7aozTrKmb7lwLeRmW9a9cs9cQ, winScene__eVaCVkG1QBiYVChMxpMGBQ);
    ```

Looks like `update__Arw3f6ryHvqdibU49aaayOg` holds the key to victory. Let's take a closer look at it.

## Part 3 - The win condition

The following code is responsible for transitioning to the victory screen:

```cpp
  v22 = *(_DWORD **)(v3[10] + 252);
  if ( v22 )
  {
    if ( *v22 == 296 )
      sceneeq___HC7o4hYar8OQigU09cNyehg(game__7aozTrKmb7lwLeRmW9a9cs9cQ, winScene__eVaCVkG1QBiYVChMxpMGBQ);
  }
```

Given the context, one can reasonably conclude that `296` must be the number of points the player needs to get.

![In-game](https://s.heyitsleo.io/ShareX/2020/10/mydude_j6sG8Rs0UE.png)
_**Me get 296 points? That's unpossible!**_

At this point, we have three options.

1. Play the game **manually** up to 296 points.
2. Figure out the significance of the number 296 and recover the flag without playing.
3. Create a **bot** to play the game for us. (I won't discuss this, but it's a method that was successfully used by others.)

### Playing the game manually

As strange as it sounds, this is what I originally did to solve the challenge. The game can be beaten in this way, although it's certainly not easy. Subjecting yourself to this torture ends up paying off, at the expense of precious time.

![Normal victory](https://s.heyitsleo.io/ShareX/2020/10/mydude_xUsJBvI1te.png)

The flag is `1t_i5_wEdn3sd4y_mY_Dud3s@flare-on.com` .

### Figuring out the meaning of 296

Just for fun, let's search for the constant `296` (`0x128`) in IDA.

![Searching for 0x128](https://s.heyitsleo.io/ShareX/2020/10/ida_VunJhfOOVw.png)

Looks like there's some data that includes the value `0x128`. 

![Data with 0x128](https://s.heyitsleo.io/ShareX/2020/10/ida_Gvzl58txZs.png)

Interesting - this looks like an array structure. Let's think of it as:

```cpp
struct nim_array {
    unsigned short len;
    unsigned short unk;
    unsigned short len2;
    unsigned short unk2;
    unsigned char data[len];
};
```

This is much nicer to look at:

![Improved array structure](https://s.heyitsleo.io/ShareX/2020/10/ida_CbpscyHaz6.png)

The array data is just 0s and 1s! This is almost certainly the flag in binary. We can write a simple Python function to convert a list of bits to printable text:

```py
def decode_binary_to_string(bits):
    result = ""

    for i in range(0, len(bits), 8):
        chr_bits = bits[i:i+8]
        new_chr = 0

        for j in range(8):
            new_chr |= chr_bits[j] << (7 - j)
        result += chr(new_chr)
    return result
```

Calling this function with the data from the array gives us the flag: `1t_i5_wEdn3sd4y_mY_Dud3s@flare-on.com`

(As it turns out, the flag is 37 characters long, or **296 bits!** Each point scored in the game corresponds to a single bit of the flag.)

## Conclusion

This was fun the first time I played it, and even more fun once I realized how it actually worked. My solution certainly wasn't the _expected_ one, but sometimes you have to think outside the box.