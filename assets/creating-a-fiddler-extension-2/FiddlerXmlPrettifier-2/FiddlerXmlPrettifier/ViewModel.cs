using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace FiddlerXmlPrettifier
{
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
}
