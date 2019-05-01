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
