---
layout: post
title:  "Creating a Fiddler extension - part 3 (custom request inspector)"
date:   2019-06-08 12:00:00 +0200
categories: fiddler extension
---

In [the previous post]({% post_url 2019-04-28-creating-a-fiddler-extension-2 %}) I showed how we
can create response inspectors, and in this post I'll take a look at how we can create request
inspectors. To be more specific, I'm going to create a inspector that makes it possible to log
requests to a log file with a button click.

I would advice you to look at the previous post if you haven't already. There are things written
there that I won't repeat here.

![Final GUI for the request inspector]({{ "/assets/creating-a-fiddler-extension-3/request-inspector-final-gui.png" | absolute_url }})


# Creating a custom request inspector

## Basic setup

```cs
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using Fiddler;

[assembly: RequiredVersion("5.0.0.0")]

namespace FiddlerRequestInspector
{
  public class RequestInspector : Inspector2, IRequestInspector2
  {
    private readonly LogFileService logFileService;
    private readonly RequestInspectorView requestInspectorView;
    private readonly ElementHost host = new ElementHost();

    public RequestInspector()
    {
      logFileService = new LogFileService();
      requestInspectorView = new RequestInspectorView();

      requestInspectorView.ViewModel.AddToLogEvent +=
        ViewModel_AddToLogEvent;
    }

    #region In IRequestInspector2

    public HTTPRequestHeaders headers { get; set; }

    public byte[] body { get; set; }

    public bool bDirty { get { return false; } }

    public bool bReadOnly { get; set; }

    public void Clear() { }

    #endregion

    #region In Inspector2

    public override void AddToTab(TabPage o)
    {
      host.Dock = DockStyle.Fill;
      host.Child = requestInspectorView;
      o.Text = "Log requests";
      o.Controls.Add(host);
    }

    public override int GetOrder()
    {
      return 150;
    }

    #endregion

    private void ViewModel_AddToLogEvent(object source, AddToLogEventArgs e)
    {
      LogToFile(e.IsPrettyPrint, e.PathToLogFile);
    }

    private void LogToFile(bool isPrettyPrint, string pathToLogFile)
    {
      string bodyAsStr = Encoding.UTF8.GetString(body);
      string usedBody = isPrettyPrint && XmlUtil.IsXml(bodyAsStr)
        ? XmlUtil.FormatXml(bodyAsStr) : bodyAsStr;
      logFileService.AddToLog(pathToLogFile, headers, usedBody);
    }
  }
}
```

### Creating a viewmodel

```cs
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Forms;
using System.Windows.Input;

namespace FiddlerRequestInspector
{
  public sealed class ViewModel : INotifyPropertyChanged
  {
    private string pathToLogFile;

    public ViewModel()
    {
      BrowseCommand = new SimpleCommand(Browse);
      AddToLogCommand = new SimpleCommand(AddToLog);
      PrettifyAndAddToLogCommand = new SimpleCommand(PrettifyAndAddToLog);
    }

    public ICommand BrowseCommand { get; }

    public ICommand AddToLogCommand { get; }

    public ICommand PrettifyAndAddToLogCommand { get; }

    public string PathToLogFile
    {
      get
      {
        return pathToLogFile;
      }

      set
      {
        pathToLogFile = value;
        NotifyPropertyChanged();
      }
    }

    public event PropertyChangedEventHandler PropertyChanged;

    public event AddToLogEventHandler AddToLogEvent;

    public delegate void AddToLogEventHandler(object source, AddToLogEventArgs e);

    public void Browse()
    {
      using (var openFileDialog = new OpenFileDialog())
      {
        openFileDialog.InitialDirectory = "c:\\";
        openFileDialog.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*";
        openFileDialog.FilterIndex = 2;
        openFileDialog.RestoreDirectory = true;

        if (openFileDialog.ShowDialog() == DialogResult.OK)
          PathToLogFile = openFileDialog.FileName;
      }
    }

    private void AddToLog()
    {
      if (string.IsNullOrWhiteSpace(PathToLogFile))
      {
        MessageBox.Show("Choose a log file.");
        return;
      }

      OnAddToLog(false);
    }

    private void PrettifyAndAddToLog()
    {
      if (string.IsNullOrWhiteSpace(PathToLogFile))
      {
        MessageBox.Show("Choose a log file.");
        return;
      }

      OnAddToLog(true);
    }

    private void OnAddToLog(bool isPrettyPrint)
    {
      AddToLogEvent?.Invoke(this, new AddToLogEventArgs(PathToLogFile, isPrettyPrint));
    }

    private void NotifyPropertyChanged([CallerMemberName]string propertyName = null)
    {
      PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
  }
}
```

### Creating a command class

```cs
using System;
using System.Windows.Input;

namespace FiddlerRequestInspector
{
  public sealed class SimpleCommand : ICommand
  {
    private readonly Action execute;

    public SimpleCommand(Action execute)
    {
      this.execute = execute ?? throw new ArgumentNullException("execute");
    }

    public event EventHandler CanExecuteChanged;

    public bool CanExecute(object parameter)
    {
      return true;
    }

    public void Execute(object parameter)
    {
      execute();
    }
  }
}
```

### Creating AddToLogEventArgs

```cs
using System;

namespace FiddlerRequestInspector
{
  public sealed class AddToLogEventArgs : EventArgs
  {
    public AddToLogEventArgs(string pathToLogFile, bool isPrettyPrint)
    {
      PathToLogFile = pathToLogFile;
      IsPrettyPrint = isPrettyPrint;
    }

    public string PathToLogFile { get; }

    public bool IsPrettyPrint { get; }
  }
}
```

### Creating an XML utility class

```cs
using System;
using System.Xml.Linq;

namespace FiddlerRequestInspector
{
  public static class XmlUtil
  {
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
  }
}
```

### Creating a logging service

```cs
using System;
using System.IO;
using Fiddler;

namespace FiddlerRequestInspector
{
  public sealed class LogFileService
  {

    private readonly string doubleLineShift =
        Environment.NewLine + Environment.NewLine;

    private readonly string quadLineShift =
        Environment.NewLine + Environment.NewLine +
        Environment.NewLine + Environment.NewLine;

    private const string horizontalBar =
        "---------------------------------------------------";

    public void AddToLog(string path, HTTPRequestHeaders headers, string body)
    {
      string content =
         DateTime.Now.ToString()
         + doubleLineShift
         + FormatHeaders(headers)
         + doubleLineShift
         + body
         + doubleLineShift
         + horizontalBar
         + quadLineShift;

      File.AppendAllText(path, content);
    }

    private string FormatHeaders(HTTPRequestHeaders headers)
    {
      string headersStr = headers.HTTPMethod
        + " " + headers.RequestPath + " "
        + headers.HTTPVersion;

      headersStr += Environment.NewLine;
      
      foreach (var header in headers)
        headersStr += header.Name + ": "
            + header.Value + Environment.NewLine;

      return headersStr;
    }
  }
}
```


## Setup the inspector

## Create a proper view



Here is a small summary of what’s needed to create a request inspector:

- Create a main inspector class. It has to inherit from `Inspector2` and `IRequestInspector2`.
- Implement the properties and methods in the inherited class/interface. The business logic
  lies here.
- Create a view that the inspector will show content in.
- Optional: Create a viewmodel and set it as the views datacontext.
- Connect the inspector with the view or viewmodel.
