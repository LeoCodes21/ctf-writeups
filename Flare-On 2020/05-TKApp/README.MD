# #5 - TKApp by Moritz Raabe (@m_r_tz)

## Introduction

For this challenge, we're presented with a `TKApp.tpk` file. The challenge description hints at this being software for an exotic target platform:

> Now you can play Flare-On on your watch! As long as you still have an arm left to put a watch on, or emulate the watch's operating system with sophisticated developer tools.

In an ideal world, we wouldn't need to emulate anything. Will that be the case?

## Part 1 - Recon

Opening the `TKApp` file in a hex editor immediately reveals something interesting: we're looking at a ZIP archive, as indicated by the presence of the `PK` (`50 4B`) marker.

![It's a ZIP file](https://s.heyitsleo.io/ShareX/2020/10/HxD_jSKufAm38V.png)

Armed with this knowledge, we can extract the contents of the file with ease. I personally used [WinRAR](https://www.rarlab.com/), but any tool will suffice.

![Contents shown in WinRAR](https://s.heyitsleo.io/ShareX/2020/10/WinRAR_gRj8KrFqTX.png)

Notice the `tizen-manifest.xml` file. [Tizen](https://www.tizen.org/) is an operating system for mobile devices, like watches!

With the data extracted, we can start looking for the actual application. It's in the `bin` folder:

![Contents of bin folder](https://s.heyitsleo.io/ShareX/2020/10/explorer_hog3gT9NPT.png)

Note the presence of `Xamarin.Forms` DLLs. It seems like we're dealing with a C# application - luckily, C# code is rather easy to decompile (provided it hasn't been tampered with!)

We can use one of the many .NET decompilers out there for this task - I prefer [dnSpy](https://github.com/dnSpy/dnSpy).

After loading the `TKApp.dll` file into dnSpy, we can see a namespace and class tree.

![Class tree in dnSpy](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_Buij9rdVrl.png)

Judging by its name, we should probably look at the `UnlockPage` class first.

## Part 2 - Opening the door

It doesn't take long to find the code we're interested in:

```cs
private async void OnLoginButtonClicked(object sender, EventArgs e)
{
	if (this.IsPasswordCorrect(this.passwordEntry.Text))
	{
        ...
		App.Password = this.passwordEntry.Text;		
        base.Navigation.InsertPageBefore(new MainPage(), this);
		await base.Navigation.PopAsync();
	}
    ...
}

private bool IsPasswordCorrect(string password)
{
	return password == Util.Decode(TKData.Password);
}
```

We need to figure out the correct password.

`Util.Decode` is a simple XOR cipher:
```cs
public static string Decode(byte[] e)
{
	string text = "";
	foreach (byte b in e)
	{
		text += Convert.ToChar((int)(b ^ 83)).ToString();
	}
    return text;
}
```

`TKData.Password` is a small byte array:
```cs
public static byte[] Password = new byte[]
{
	62, // 0x3E
	38, // 0x26
	63, // 0x3F
	63, // 0x3F
	54, // 0x36
	39, // 0x27
	59, // 0x3B
	50, // 0x32
    39  // 0x27
};
```

We can reimplement the decoder in Python:
```py
def decode(input):
    return ''.join(
        map(chr, 
            map(lambda x: x ^ 83, input)))
```

Calling this function with the password data gives us `mullethat`. This will be the value of `App.Password`. Now we can move on to `MainPage`.

## Part 3 - Step it up!

Upon opening `MainPage`, we quickly come across an interesting function called `PedDataUpdate`. This function is called when the device's pedometer sends new data.

![PedDataUpdate](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_T0Zv8kJSkn.png)

Hold on - why is pedometer code accessing application metadata? Immediately after that first `if` block, there's some interesting code:

```cs
if (!string.IsNullOrEmpty(App.Password) && !string.IsNullOrEmpty(App.Note) && !string.IsNullOrEmpty(App.Step) && !string.IsNullOrEmpty(App.Desc))
{
	HashAlgorithm hashAlgorithm = SHA256.Create();
	byte[] bytes = Encoding.ASCII.GetBytes(App.Password + App.Note + App.Step + App.Desc);
	byte[] first = hashAlgorithm.ComputeHash(bytes);
	byte[] second = new byte[]
	{
		50,
		148,
		76,
		233,
        ...
```

Notice this line: 

`byte[] bytes = Encoding.ASCII.GetBytes(App.Password + App.Note + App.Step + App.Desc);`

The `PedDataUpdate` function is computing the hash of a string composed of several other strings, one of them being `App.Step` - remember that? It's set by retrieving the "its" metadata entry, which can be found in the `tizen-manifest.xml` file. As shown below, the value is `magic` .

![Manifest XML](https://s.heyitsleo.io/ShareX/2020/10/notepad%2B%2B_exKZAj11n2.png)

At this point, we know two things:

```
App.Password = "mullethat"
App.Step = "magic"
```

We still need `App.Note` and `App.Desc`, though. Where do those come from?

## Part 4 - Following the breadcrumbs

dnSpy allows us to trace dataflow with its helpful **Analyzer**. If we select a field and press `CTRL+SHIFT+R`, we can see all direct references to it. Let's do that for the `Note` field of the `App` class.

![Selected Note field](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_ZvADIQAZP3.png)

![Analyzer output](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_hM8QCGVIx6.png)

I've expanded the information for `set`, because it shows us the code locations that can _write_ to `Note`. One function appears: `SetupList` in the `TodoPage` class. The code for this function is shown below:

```cs
private void SetupList()
{
	List<TodoPage.Todo> list = new List<TodoPage.Todo>();
	if (!this.isHome)
	{
		list.Add(new TodoPage.Todo("go home", "and enable GPS", false));
	}
	else
	{
		TodoPage.Todo[] collection = new TodoPage.Todo[]
		{
			new TodoPage.Todo("hang out in tiger cage", "and survive", true),
			new TodoPage.Todo("unload Walmart truck", "keep steaks for dinner", false),
			new TodoPage.Todo("yell at staff", "maybe fire someone", false),
			new TodoPage.Todo("say no to drugs", "unless it's a drinking day", false),
			new TodoPage.Todo("listen to some tunes", "https://youtu.be/kTmZnQOfAF8", true)
		};
		list.AddRange(collection);
	}
	List<TodoPage.Todo> list2 = new List<TodoPage.Todo>();
	foreach (TodoPage.Todo todo in list)
	{
		if (!todo.Done)
		{
			list2.Add(todo);
		}
	}
	this.mylist.ItemsSource = list2;
	App.Note = list2[0].Note;
}

...
public class Todo
{
	public string Name { get; set; }

	public string Note { get; set; }

	public bool Done { get; set; }

	public Todo(string Name, string Note, bool Done)
	{
		this.Name = Name;
		this.Note = Note;
		this.Done = Done;
	}
}
```

This function sets `App.Note` to the `Note` field of the first todo entry that **isn't** completed. 

Let's assume `this.isHome` is equal to `true`, in which case `App.Note` will be equal to `"keep steaks for dinner"`. (Remember, we're looking for the **note** on the first **incomplete** todo.)

Now we know _three_ things:

```
App.Password = "mullethat"
App.Step = "magic"
App.Note = "keep steaks for dinner"
```

All we need to find is `App.Desc`. If we invoke the Analyzer again, we can see it's initialized by a function in the `GalleryPage` class.

![Analyzed Desc field](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_axsUktO9QU.png)

`IndexPage_CurrentPageChanged` is implemented as shown below:
```cs
private void IndexPage_CurrentPageChanged(object sender, EventArgs e)
{
	if (base.Children.IndexOf(base.CurrentPage) == 4)
	{
		using (ExifReader exifReader = new ExifReader(Path.Combine(Application.Current.DirectoryInfo.Resource, "gallery", "05.jpg")))
		{
			string desc;
			if (exifReader.GetTagValue<string>(ExifTags.ImageDescription, out desc))
			{
		App.Desc = desc;
			}
			return;
		}
	}
	App.Desc = "";
}
```

It's _EXIF time._

### Hunting down the `ImageDescription`

In order to find the correct value of `Desc`, we first need to find the image file being loaded. The `res` folder in the TKApp package contains all of the resources, and we can find `gallery/05.jpg` in there.

![res folder](https://s.heyitsleo.io/ShareX/2020/10/explorer_JCq2rniVxa.png)

![gallery image 05](./gallery_05.jpg)

We can use [NirSoft's ExifDataView](http://www.nirsoft.net/utils/exif_data_view.html) to explore the image's EXIF properties.

![ExifDataView](https://s.heyitsleo.io/ShareX/2020/10/ExifDataView_uVxsb2QyuP.png)

Here's the property we were looking for! Now we have all of the information we need.

```
App.Password = "mullethat"
App.Step = "magic"
App.Note = "keep steaks for dinner"
App.Desc = "water"
```

## Part 5 - Checking our work

Now we can go back to the `PedDataUpdate` function in `MainPage`. 

```cs
HashAlgorithm hashAlgorithm = SHA256.Create();
byte[] bytes = Encoding.ASCII.GetBytes(App.Password + App.Note + App.Step + App.Desc);
byte[] first = hashAlgorithm.ComputeHash(bytes);
byte[] second = new byte[]
{
	50,
	148,
	76,
	233,
	110,
	199,
	228,
    ...
};

if (first.SequenceEqual(second))
{
	this.btn.Source = "img/tiger2.png";
	this.btn.Clicked += this.Clicked;
	return;
}
```

Let's take our known values and make sure we're on the right track.

```py
import hashlib

m = hashlib.sha256()
m.update(b"mullethatkeep steaks for dinnermagicwater")
result = m.digest()

if result == b'\x32\x94\x4c\xe9\x6e\xc7\xe4\x48\x72\xe3\x4e\x8a\x5d\xbd\xbd\x93\x9f\x46\x42\xdf\x7b\x89\x2c\x49\x65\xeb\x81\x10\xb5\x8b\x68\x38':
    print("good")
```

(The value that `result` is being compared against is the full checksum expected by TKApp.)

Running this script prints `good`, so our values are correct.

## Part 6 - Endgame

There's one more interesting function in `MainScreen`, and it's named `GetImage`. 

```cs
private bool GetImage(object sender, EventArgs e)
{
	...
	string text = new string(new char[]
	{
		App.Desc[2],
		App.Password[6],
		App.Password[4],
		App.Note[4],
		App.Note[0],
		App.Note[17],
		App.Note[18],
		App.Note[16],
		App.Note[11],
		App.Note[13],
		App.Note[12],
		App.Note[15],
		App.Step[4],
		App.Password[6],
		App.Desc[1],
		App.Password[2],
		App.Password[2],
		App.Password[4],
		App.Note[18],
		App.Step[2],
		App.Password[4],
		App.Note[5],
		App.Note[4],
		App.Desc[0],
		App.Desc[3],
		App.Note[15],
		App.Note[8],
		App.Desc[4],
		App.Desc[3],
		App.Note[4],
		App.Step[2],
		App.Note[13],
		App.Note[18],
		App.Note[18],
		App.Note[8],
		App.Note[4],
		App.Password[0],
		App.Password[7],
		App.Note[0],
		App.Password[4],
		App.Note[11],
		App.Password[6],
		App.Password[4],
		App.Desc[4],
		App.Desc[3]
	});
	byte[] key = SHA256.Create().ComputeHash(Encoding.ASCII.GetBytes(text));
	byte[] bytes = Encoding.ASCII.GetBytes("NoSaltOfTheEarth");
	try
	{
		App.ImgData = Convert.FromBase64String(Util.GetString(Runtime.Runtime_dll, key, bytes));
		return true;
	}
    ...
	return false;
}
```

We can obtain the [data in Runtime.Runtime_dll](./Runtime_dll.bin) from dnSpy.

![Resource viewer](https://s.heyitsleo.io/ShareX/2020/10/dnSpy_fMFgTMHjJn.png)

![Resource context menu](https://s.heyitsleo.io/ShareX/2020/10/b9a8GThGmd.png)

`Util.GetString` is used to decrypt the data with the generated key (which is `the kind of challenges we are gonna make here`) and IV (`NoSaltOfTheEarth`). It uses the `RijndaelManaged` class, which defaults to working in CBC mode with PKCS7 padding. The decrypted data is then Base64-decoded, and finally interpreted as a JPEG image.

\* **How do we know it's a JPEG?** The first 4 bytes of the Base64-decoded data are `ff d8 ff e0`, which is the marker of a JPEG in the JFIF format.

The decryption and decoding process is implemented in [dump_resource.py](./dump_resource.py).

![the flag](./out_data.jpg)

The flag is **n3ver_go1ng_to_recov3r@flare-on.com**.