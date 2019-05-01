using System;
using System.Xml.Linq;

namespace FiddlerXmlBeautyfier
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
