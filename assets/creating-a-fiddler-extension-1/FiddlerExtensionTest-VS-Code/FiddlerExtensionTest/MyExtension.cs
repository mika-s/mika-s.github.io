using System.Windows.Forms;
using Fiddler;

[assembly: RequiredVersion("5.0.0.0")]

public class MyExtension : IFiddlerExtension
{
    public MyExtension() { }

    public void OnLoad()
    {
        MessageBox.Show("MyExtension -- OnLoad");
    }

    public void OnBeforeUnload()
    {
        MessageBox.Show("MyExtension -- OnBeforeUnload");
    }
}