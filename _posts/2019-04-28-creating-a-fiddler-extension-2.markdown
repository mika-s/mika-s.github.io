---
layout: post
title:  "Creating a Fiddler extension - part 2 (custom response inspector)"
date:   2019-04-28 12:00:00 +0200
categories: fiddler extension
---

This post resumes where [the first post]({% post_url 2019-04-09-creating-a-fiddler-extension-1 %}) left off.
In this post I'll make a custom inspector that pretty-prints XML responses in Fiddler.

So instead of this:

![XML not pretty-printed in Fiddler]({{ "/assets/creating-a-fiddler-extension-2/xml-nonpretty.png" | absolute_url }})

we see this:

![XML pretty-printed in Fiddler]({{ "/assets/creating-a-fiddler-extension-2/xml-pretty.png" | absolute_url }})

## Creating a custom inspector

I assume the project has been set up properly already (see the first post). As a recap, setting
up a new project consists of creating a new class library project, adding a reference to
Fiddler.exe and System.Windows.Forms and then creating a main class with the RequireVersion attribute
on top. To create a custom inspector you have to inherit from `Inspector2` and `IResponseInspector2`,
and then implement the methods in `IResponseInspector2`. We also have to create the view that the
inspector will use.

### Basic setup

I rename Class1.cs to XmlPrettifier.cs and inherit from the base class and interface used with
custom inspectors:

```cs
using System;
using System.Windows.Forms;
using Fiddler;

[assembly: RequiredVersion("5.0.0.0")]

namespace FiddlerXmlPrettifier
{
    public sealed class XmlPrettifier : Inspector2, IResponseInspector2
    {
        #region In IResponseInspector2

        public HTTPResponseHeaders headers
        {
            get => throw new NotImplementedException();
            set => throw new NotImplementedException();
        }

        public byte[] body
        {
            get => throw new NotImplementedException();
            set => throw new NotImplementedException();
        }

        public bool bDirty => throw new NotImplementedException();

        public bool bReadOnly
        {
            get => throw new NotImplementedException();
            set => throw new NotImplementedException();
        }

        public void Clear()
        {
            throw new NotImplementedException();
        }

        #endregion

        #region In Inspector2

        public override void AddToTab(TabPage o)
        {
            throw new NotImplementedException();
        }

        public override int GetOrder()
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}
```

`headers`, `body`, `bDirty`, `bReadOnly` and `Clear()` are properties and methods in `IResponseInspector2`
and they have to be implemented by us. `AddToTab()` and `GetOrder()` are abstract methods in
`Inspector2`. `Inspector2` also have a few non-abstract virtual methods that I won't implement.
At the moment nothing is implemented properly. This is only the skeleton.

We also have to add the view, as well as a viewmodel for the view. Fiddler uses Windows Forms, but
I will use a WPF view instead. WPF views can be hosted in Windows Forms by using the `ElementHost`
class. To create a view I use a UserControl and call it XmlPrettyfierView.xaml. It doesn't contain
anything just yet:

```xml
<UserControl x:Class="FiddlerXmlPrettifier.XmlPrettyfierView"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
             xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
             xmlns:local="clr-namespace:FiddlerXmlPrettifier"
             mc:Ignorable="d"
             d:DesignHeight="450" d:DesignWidth="800">
    <Grid>

    </Grid>
</UserControl>
```

I also have to create a viewmodel that's attached to the view's DataContext. I call it ViewModel.cs
and it looks like this:

```cs
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FiddlerXmlPrettifier
{
    public sealed class ViewModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private void NotifyPropertyChanged([CallerMemberName]string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
```

It's just a plain class with `INotifyPropertyChanged` implemented. We can instantiate the viewmodel
and make it the datacontext of the view like this:

```cs
public partial class XmlPrettyfierView : UserControl
{
    public XmlPrettyfierView()
    {
        InitializeComponent();
        ViewModel = new ViewModel();
        DataContext = ViewModel;
    }

    public ViewModel ViewModel { get; }
}
```

This is in XmlPrettyfierView.cs, the code behind of the view. The reason the ViewModel is available
as a property is because we need access to the viewmodel from the inspector class (XmlPrettifier).

Lets also add the pre-build and post-build events that are described in the first post:

Pre-build event:

```console
taskkill /im fiddler.exe /t /f 2>&1 | exit /B 0
```

Post-build event:

```
XCOPY "$(TargetPath)" "%25userprofile%25\Documents\Fiddler2\Inspectors\" /S /Y
```

The pre-build event will close Fiddler when building and the post-build event will copy the compiled
dll to the local Inspectors folder. I want to start Fiddler and debug the inspector with Visual
Studio, so I'm also making Fiddler.exe the startup executable:

![Fiddler.exe as startup executable]({{ "/assets/creating-a-fiddler-extension-2/project-properties-debug.png" | absolute_url }})

When I click Start in Visual Studio it will close Fiddler if it's running, compile, place the
compiled dll in the Inspectors folder and then start Fiddler again. Everything happens automatically,
which is nice. If you want to see the project so far you can have a look
[here][mikas-github-visual-studio-project-1].

### Prettify XML

Lets start creating the actual inspector. In order to prettify XML we need a method that takes a
string of ugly XML as input. This should return a string containing the prettified XML. So I did
what everyone else would've done and googled "prettify xml c#" and found a snippet on Stack
Overflow that I can use:

```cs
/// Taken from Stack Overflow:
/// https://stackoverflow.com/a/1123947/8574934
/// By Charles Prakash Dasari.
/// https://stackoverflow.com/users/129196/charles-prakash-dasari
/// Under CC BY-SA 3.0
/// https://creativecommons.org/licenses/by-sa/3.0/
public static string FormatXml(string xml)
{
    try
    {
        XDocument doc = XDocument.Parse(xml);
        return doc.ToString();
    }
    catch (Exception)
    {
        return xml;
    }
}
```

We also need a method that determines whether a response contains XML. If not, we ignore it. We can
modify the snippet above to return true if it's able to parse the input string, and false otherwise:

```cs
public static bool IsXml(string maybeXml)
{
    try
    {
         XDocument doc = XDocument.Parse(maybeXml);
         return true;
    }
    catch (Exception)
    {
        return false;
    }
}
```

I've put these to methods in a static class called `XmlUtil` which is located in a file called
*XmlUtil.cs*.

### Setup the inspector

Next, we can start creating the actual inspector logic by removing the throws of `NotImplementedException`
and implementing real code. I'll just post the entire class and comment on it below:

```cs
public class XmlPrettifier : Inspector2, IResponseInspector2
{
    private readonly XmlPrettifierView xmlPrettifierView;
    private readonly ElementHost host = new ElementHost();
    private byte[] _body;

    public XmlPrettifier()
    {
        xmlPrettifierView = new XmlPrettifierView();
    }

    #region In IResponseInspector2

    public HTTPResponseHeaders headers { get; set; }

    public byte[] body
    {
        get
        {
            return _body;
        }

        set
        {
            _body = value;

            if (body != null)
            {
                string maybeXml = Encoding.UTF8.GetString(body);

                if (XmlUtil.IsXml(maybeXml))
                    xmlPrettifierView.ViewModel.PrettifiedXml
                        = XmlUtil.FormatXml(maybeXml);
            }
        }
    }

    public bool bDirty { get { return false; } }

    public bool bReadOnly { get; set; }

    public void Clear()
    {
        body = null;
        xmlPrettifierView.ViewModel.Clear();
    }

    #endregion

    #region In Inspector2

    public override void AddToTab(TabPage o)
    {
        host.Dock = DockStyle.Fill;
        host.Child = xmlPrettifierView;
        o.Text = "XML pretty";
        o.Controls.Add(host);
    }

    public override int GetOrder()
    {
        return 150;
    }

    #endregion
}
```

At the top we have:

```cs
private readonly XmlPrettifierView xmlPrettifierView;
private readonly ElementHost host = new ElementHost();
private byte[] _body;

public XmlPrettifier()
{
    xmlPrettifierView = new XmlPrettifierView();
}
```

The inspector has to know about the view, so we instantiate it in the constructor and then hold a
reference to it in `xmlPrettyTextView`. `host`, which is of the `ElementHost` class is used as a
container for the WPF view so it can be used in a Windows Forms application. In order to use
`ElementHost` we have to add a reference to *WindowsFormsIntegration*.

`GetOrder()` and `AddToTab()` were inherited from the class `Inspector2`. Fiddler will call our
overridden `AddToTab()` to get information on what view to put in the new tab it has created for
our new inspector. In `AddToTab()` we put the WPF view inside the `host` container and then add it
to the `Controls` collection. We also change the title of the tab to *"XML pretty"*.

`GetOrder()` is called by Fiddler in order to determine how the tabs should be sorted in the UI.
Lower numbers are displayed on the left side, larger numbers on the right side. Negative numbers
can be used. Fiddler claims it uses -1000 to 110 for its own inspectors. So if I return -2000 in
`GetOrder()` the new tab will appear to the right:

![GetOrder returns -2000]({{ "/assets/creating-a-fiddler-extension-2/GetOrder -2000.png" | absolute_url }})

If I return 0 it will appear in the middle:

![GetOrder returns 0]({{ "/assets/creating-a-fiddler-extension-2/GetOrder 0.png" | absolute_url }})

and if I return 150 it will appear on the right side:

![GetOrder returns 150]({{ "/assets/creating-a-fiddler-extension-2/GetOrder 150.png" | absolute_url }})

I think it's suitable to have it right next to the original XML tab, so I'll use 150.

`body` and `headers` will receive values when Fiddler reads a response. `body` will contain the
response body as bytes, `headers` will contain the response headers as Fiddler's own
`HTTPResponseHeaders` class. `headers` is provided by Fiddler first. I am not interested in the
HTTP headers in this inspector, so I'll just leave it as a property that's never used. The core
logic lies in the setter of `body`. I check whether it's XML, and if it is I try to prettify it.
I then store it in a property of the viewmodel.

`bDirty` and `bReadOnly` are booleans that are used with inspectors that can modify requests and
responses. I am making a read-only inspector, so I will not use these further.

`Clean()` is a function that is called by Fiddler when the inspector is supposed to clean up after
itself. I reset the `body` field and also call a method in the viewmodel that is doing the cleanup
there.

### Create a proper view

The xaml part of the view is quite simple:

```xml
<UserControl x:Class="FiddlerXmlPrettifier.XmlPrettifierView"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
             xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
             mc:Ignorable="d" d:DesignHeight="450" d:DesignWidth="800">
    <UserControl.Resources>
        <SolidColorBrush
            x:Key="ReadOnlyColor"
            Color="{Binding Fiddler.CONFIG.colorDisabledEdit}" />
    </UserControl.Resources>

    <Grid>
        <TextBox ScrollViewer.VerticalScrollBarVisibility="Auto"
                 ScrollViewer.HorizontalScrollBarVisibility="Auto"
                 IsReadOnly="True"
                 Background="{StaticResource ReadOnlyColor}"
                 Text="{Binding PrettifiedXml, Mode=OneWay}"/>
    </Grid>
</UserControl>
```

The entire view consists of a text box that contains the prettified XML. The text property is bound
to a property in the viewmodel. I have bound the background color to one of Fiddler's colors to make
it look uneditable (which it is).

The viewmodel looks like this:

```cs
public sealed class ViewModel : INotifyPropertyChanged
{
    private string prettifiedXml;

    public string PrettifiedXml
    {
        get
        {
            return prettifiedXml;
        }

        set
        {
            prettifiedXml = value;
            NotifyPropertyChanged();
        }
    }

    public void Clear()
    {
        PrettifiedXml = string.Empty;
    }

    public event PropertyChangedEventHandler PropertyChanged;

    private void NotifyPropertyChanged([CallerMemberName]string propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}
```

It contains the string property for the prettified XML and a `Clear()` function that sets the string
property to empty when it's called in the inspector class.

And that's all that's needed to create the response inspector. It might be better to look at the
actual project to get a clear picture of what's needed. You can see the final version of the project
[here][mikas-github-visual-studio-project-2]. It might not work perfectly in all circumstances, but
since this is just a tutorial in a blog post I'll stop here.

Here is a small summary of what's needed to create a response inspector:

- Create a main inspector class. It has to inherit from `Inspector2` and `IResponseInspector2`.
- Implement the properties and methods in the inherited class/interface. The business logic
  lies here.
- Create a view that the inspector will show content in.
- Optional: Create a viewmodel and set it as the views datacontext.
- Connect the inspector with the view or viewmodel.

[mikas-github-visual-studio-project-1]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-a-fiddler-extension-2/FiddlerXmlPrettifier-1/
[mikas-github-visual-studio-project-2]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-a-fiddler-extension-2/FiddlerXmlPrettifier-2/
