# #1 - fidler by Nick Harbour

## Introduction

In this challenge we are presented with a [PyGame](https://www.pygame.org) application. We are provided with the original source code as well as a compiled binary (which we will only use for playing.) The code is not obfuscated, so we can focus on understanding the logic.

## Part 1 - the password

Upon launching the game, we are presented with a screen asking for a password.

![Screen asking for password](https://s.heyitsleo.io/ShareX/2020/10/fidler_n4x6hocVgz.png)

Let's examine the game code and see if we can find anything interesting. The game's `main` function is defined as follows:

```python
def main():
    if password_screen():
        game_screen()
    else:
        password_fail_screen()
    pg.quit()
```

We can see that a function named `password_screen` is responsible for granting or denying entry to the second part of the game. What does it do?

```python
def password_screen():
    ...
    heading = Label(20, 20, 'This program is protected by Flare-On TURBO Nuke v55.7')
    prompt = Label(20, 105, 'Password:')
    input_box = InputBox(140, 100, 470, 32)
    controls = [heading, prompt, input_box]
    done = False
    while not done:
        ...
        if input_box.submitted:
            if password_check(input_box.text):
                return True
            else:
                return False
```

Hmm - it's calling `password_check` with whatever we entered in the password box. How do we know what to enter?

```python
def password_check(input):
    altered_key = 'hiptu'
    key = ''.join([chr(ord(x) - 1) for x in altered_key])
    return input == key
```

This is an extremely simple Caesar cipher, with every letter shifted by 1.

```
h -> g
i -> h
p -> o
t -> s
u -> t
```

The password to enter is `ghost`. Indeed, supplying `ghost` as the password brings us to the game screen:

![Main game screen](https://s.heyitsleo.io/ShareX/2020/10/fidler_9mou50Dz0F.png)

## Part 2 - the game

Uh oh - it wants us to earn **100 billion coins**? We could use an autoclicker, sure, but there's got to be a better way. Looking at the implementation of `game_screen` (as referenced above), we can see this interesting block of code:

```py
while not done:
    target_amount = (2**36) + (2**35)
    if current_coins > (target_amount - 2**20):
        while current_coins >= (target_amount + 2**20):
            current_coins -= 2**20
        victory_screen(int(current_coins / 10**8))
        return
```

We can see that we need `current_coins` to be greater than `(2**36) + (2**35) - (2**20)`, or `103078166528`. For simplcity's sake, let's use `103078166529` as our `current_coins` value.

Next, we see a call to `victory_screen(int(current_coins / 10**8))`.
We'll simplify this to `victory_screen(int(103078166529 / 10**8))`, then to `victory_screen(1030)`. 

Much better!

## Part 3 - Victory screen

What does this `victory_screen` function do?

```py
def victory_screen(token):
    ...
    flag_content_label.change_text(decode_flag(token))
```

Remember that `token` is equal to 1030. Now we need to go to `decode_flag`.

```py
def decode_flag(frob):
    last_value = frob
    encoded_flag = [
        1135, 1038, 1126, 1028, 1117, 1071, 1094, 1077, 
        1121, 1087, 1110, 1092, 1072, 1095, 1090, 1027, 
        1127, 1040, 1137, 1030, 1127, 1099, 1062, 1101, 
        1123, 1027, 1136, 1054
    ]
    decoded_flag = []

    for i in range(len(encoded_flag)):
        c = encoded_flag[i]
        val = (c - ((i%2)*1 + (i%3)*2)) ^ last_value
        decoded_flag.append(val)
        last_value = c

    return ''.join([chr(x) for x in decoded_flag])
```

Slightly unwieldy, but we can deal with this. Let's create a Python script of our own (or use an online REPL service) so we can run this function. All we're going to do is copy the function into our script, and then call it like so: 
`print(decode_flag(1030))`

You can find the source in [flag_decoder.py](./flag_decoder.py).
When we run it, we get the flag!

![Victory!](https://s.heyitsleo.io/ShareX/2020/10/chrome_SRVGfoYuqV.png)

The flag is `idle_with_kitty@flare-on.com`, and we're free to move on to the next one.