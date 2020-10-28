
# The Janitor

The Janitor is a tool to clean up the decompiled script and turn it into something we can analyze without losing our minds. The Janitor runs the AutoIt code through several filters and produces a **deobfuscated, functionally identical** result.

## Stage 1: Constant deduplication

We can use the following regular expression to locate all integer constants:
```py
# Matches strings such as: $flqajqcgnb = Number(" 1 ")
LITERAL_CONSTANT_PATTERN = r'(\$([a-z]{10}) = Number\((" ([0-9]{1,}) ")\))'
```

Then we can write a function to get rid of the duplicates:

```py
# Get rid of duplicate global variables for constants 
def dedupe_constants(src):
    num_vars = re.findall(LITERAL_CONSTANT_PATTERN, src)

    # Tracking map for constants. 
    # Entry format: key=[value of constant], value=[name of constant var]
    found_constants = {}

    # example: var_name="flmayhqwzl", var_val=0
    for (_full, var_name, _, var_val) in num_vars:
        if var_val not in found_constants:
            # This constant hasn't been defined before.
            # Put the constant in the tracking map so we can replace duplicate variables
            found_constants[var_val] = var_name
        else:
            # This constant has already been defined.
            # Remove the declaration from the script
            src = src.replace('$%s = Number(" %d ")' % (var_name, int(var_val)), '')
            # Replace all occurrences of the name of the duplicate variable 
            # with the name of the original variable
            src = src.replace(var_name, found_constants[var_val])

    # Do a bit of comma cleanup (more will occur later)
    return re.sub(r'(, ){2,}', '', src)
```

This cleans up the decompilation a bit, but there's still more to do.

```autoit
Global $flavekolca = Number(" 0 "), $flerqqjbmh = Number(" 1 ")$flvjxcqxyn = Number(" 2 ")
Global $flemdcrqdd = Number(" 6 "), $flmmamrwab = Number(" 3 ")$flndzdxavp = Number(" 4 ")
Global $flviysztbd = Number(" 7 ")
Global $flevbybfkl = Number(" 5 ")
Global 
Global 
Global 
Global 
Global 
Global $flvaxmaxna = Number(" 8 ")$flsfkralzh = Number(" 9 ")
Global $flgcavcjkb = Number(" 36 "), $flizrncrjw = Number(" 39 "), ...
```

## Stage 2: Constant inlining

We can write another function to replace all usages of global constants with the appropriate values.

```py
# Inline constant values
def inline_constants(src):
    num_vars = re.findall(LITERAL_CONSTANT_PATTERN, src)
    const_names = set()

    for (full, var_name, _, var_val) in num_vars:
        const_names.add(var_name)

        # Rename variable to num_x where x = constant value
        # Example:
        #    $flqajqcgnb = Number(" 1 ")
        # to
        #    $num_1 = 1
        src = src.replace(full, '$num_%d = %d' % (int(var_val), int(var_val))).replace('$%s' % (var_name), '$num_%d' % (int(var_val)))

    # Replace all usages of $num_x with the value of x
    return re.sub(r'(?!Global.*=)(\$num_([0-9]+))', r'\g<2>', src)
```

After running the script through this processor,

```autoit
Local $flokwzamxw = GUICtrlCreateInput(AREHDIDXRGK($os[$flktwrjohv]), -$flerqqjbmh, $flevbybfkl, $flkfrjyxwm)
```
becomes
```autoit
Local $flokwzamxw = GUICtrlCreateInput(AREHDIDXRGK($os[130]), -1, 5, 300)
```

This is good progress, but we can do better. We still need to eliminate the string obfuscation.

## Stage 3: String deobfuscation

The `AREIHNVAPWN` function is responsible for initializing the global string table (`$os`). 

```autoit
Func AREIHNVAPWN()
    Local $dlit = "7374727563743b75696e7420626653697a653b75696e7420626652657365727665643b75696e742062664f6666426974733b"
    $dlit &= "75696e7420626953697a653b696e7420626957696474683b696e742062694865696768743b7573686f7274206269506c616e"
    ...
    Global $os = StringSplit($dlit, "4FD5$", 0x1)
```

The trained eye will notice that these hex strings look like encoded ASCII. This is easy to validate:
![It's ASCII](https://s.heyitsleo.io/ShareX/2020/10/HxD_vggepuDaa3.png)

The `AREHDIDXRGK` function that's used everywhere is responsible for decoding the strings:

```autoit
Func AREHDIDXRGK($in_str)
    Local $in_str_
    For $i = 0x1 To StringLen($in_str) Step 0x2
        $in_str_ &= Chr(Dec(StringMid($in_str, $i, 0x2)))
    Next
    Return $in_str_
EndFunc   ;==>AREHDIDXRGK
```

We can extend the Janitor to deal with the encoded strings. (`longstr` is too long to embed here - see the [janitor.py](./janitor.py) file for full source.)

```py
# Decode hex-strings and inline usages
def resolve_obfuscated_strings(src):
    # Taken from AREIHNVAPWN function
    longstr = "...."
    # 4FD5$ is the delimiter used by the AutoIt script.
    longstrparts = longstr.split("4FD5$")
    decodedparts = []
    
    # Each split part is a hex-string - no special decoding is necessary.
    # Just convert to bytes object and decode as a UTF-8 string.
    for x in range(len(longstrparts)):
        # example: 6c6f6e67 = long
        longstrpart = longstrparts[x]
        decodedparts.append(bytes.fromhex(longstrpart).decode('utf-8'))

    # Find instances of: AREHDIDXRGK($os[x]) where x is an integer
    # Replace with appropriate string for array index [x]
    # (Constant deduplication/inlining must take place before this step)
    matches = re.findall(r'(AREHDIDXRGK\(\$os\[([0-9]+)\]\))', src)
    for (_, sindex) in matches:
        idx = int(sindex)
        # Replace AREHDIDXRGK($os[x]) with decodedparts[x-1]. 
        # AutoIt array indices start at 1, but Python starts at 0.
        src = src.replace('AREHDIDXRGK($os[%d])' % idx, '"%s"' % decodedparts[idx-1])
    return src
```

After this stage,

```autoit
Local $flokwzamxw = GUICtrlCreateInput(AREHDIDXRGK($os[130]), -1, 5, 300)
```
becomes
```autoit
Local $flokwzamxw = GUICtrlCreateInput("Enter text to encode", -1, 5, 300)
```

Much better!

### Step 4: Cleanup

Earlier stages left some invalid code lying around:
```autoit
Global 0 = 0, 1 = 12 = 2
Global 6 = 6, 3 = 34 = 4
Global 7 = 7
Global 5 = 5
Global
... 
```

We can write one last function to take care of these:

```py
# Remove invalid global variables (such as the num_x temporaries)
def remove_invalid_globals(src):
    return re.sub(r'(Global \n)|(Global( ,)? ([0-9]{1,}.*)\n)', '', src)
```

Finally, the decompiled script looks decent. The names still aren't pretty, but we can work with this.
```autoit
#OnAutoItStartRegister "AREIHNVAPWN"
Global $os
Func AREOXAOHPTA($flmojocqtz, $fljzkjrgzs, $flsgxlqjno)
    Local $flfzxxyxzg[2]
    $flfzxxyxzg[0] = DllStructCreate("struct;uint bfSize;uint bfReserved;uint bfOffBits;uint biSize;int biWidth;int biHeight;ushort biPlanes;ushort biBitCount;uint biCompression;uint biSizeImage;int biXPelsPerMeter;int biYPelsPerMeter;uint biClrUsed;uint biClrImportant;endstruct;")
    DllStructSetData($flfzxxyxzg[0], "bfSize", (3 * $flmojocqtz + Mod($flmojocqtz, 4) * Abs($fljzkjrgzs)))
    DllStructSetData($flfzxxyxzg[0], "bfReserved", 0)
    DllStructSetData($flfzxxyxzg[0], "bfOffBits", 54)
    DllStructSetData($flfzxxyxzg[0], "biSize", 40)
    DllStructSetData($flfzxxyxzg[0], "biWidth", $flmojocqtz)
    DllStructSetData($flfzxxyxzg[0], "biHeight", $fljzkjrgzs)
    ...
EndFunc   ;==>AREOXAOHPTA
```

### Step 5 (Bonus): Name mappings and other fun things

With a bit more code, we can automate the process of applying name mappings:

```py
# Apply function and variable mappings
def apply_mappings(src):
    with open('mappings.json', 'r') as mappings_file:
        mappings = json.load(mappings_file)
        for (orig_name, new_name) in mappings['names'].items():
            src = re.sub(r'\b'+orig_name+r'\b', new_name, src)
        for (remove_func) in mappings['remove_funcs']:
            pattern = r'Func ' + remove_func + r'(.*?)EndFunc'
            print("remove %s (pattern: %s)" % (remove_func, pattern))
            src = re.sub(pattern, '', src, flags=re.M|re.S|re.DOTALL)
    return src
```

The usage of the word boundary (`\b`) prevents partial matches from being replaced. See [mappings.json](./mappings.json) for the name mappings I used.

There are some additional cleanup stages that can be found in the Janitor script.