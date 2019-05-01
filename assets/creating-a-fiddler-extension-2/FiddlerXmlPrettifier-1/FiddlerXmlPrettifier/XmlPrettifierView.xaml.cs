using System.Windows.Controls;

namespace FiddlerXmlPrettifier
{
    public partial class XmlPrettifierView : UserControl
    {
        public XmlPrettifierView()
        {
            InitializeComponent();
            ViewModel = new ViewModel();
            DataContext = ViewModel;
        }

        public ViewModel ViewModel { get; }
    }
}
