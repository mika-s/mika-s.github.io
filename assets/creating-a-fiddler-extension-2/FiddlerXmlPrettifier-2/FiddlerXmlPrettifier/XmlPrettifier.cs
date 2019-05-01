using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using Fiddler;
using FiddlerXmlBeautyfier;

[assembly: RequiredVersion("5.0.0.0")]

namespace FiddlerXmlPrettifier
{
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
                        xmlPrettifierView.ViewModel.PrettifiedXml = XmlUtil.FormatXml(maybeXml);

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
}
