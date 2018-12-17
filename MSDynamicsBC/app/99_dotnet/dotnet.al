dotnet
{
    assembly("mscorlib")
    {
        type("System.Globalization.CultureInfo";"CultureInfo"){}
        type("System.Decimal";"Decimal"){}
        type("System.Globalization.NumberStyles";"NumberStyles"){}
        type("System.Int32";"Int32"){}
        type("System.DateTime";"DateTime"){}
        type("System.TimeZoneInfo";"TimeZoneInfo"){}
        type("System.DateTimeOffset";"DateTimeOffset"){}
        type("System.String";"String"){}
        type("System.Convert";"Convert"){}
        type("System.Text.Encoding";"Encoding"){}
        type("System.Environment";"Environment"){}
        type("System.IO.BinaryWriter";"BinaryWriter"){}
        type("System.IO.BinaryReader";"BinaryReader"){}
        type("System.IntPtr";"IntPtr"){}
        type("System.Math";"Math"){}
        type("System.Globalization.NumberFormatInfo";"NumberFormatInfo"){}
        type("System.Text.StringBuilder";"StringBuilder"){}
        type("System.IO.StringReader";"StringReader"){}
        type("System.IO.StringWriter";"StringWriter"){}
        type("System.IO.MemoryStream";"MemoryStream"){}
        type("System.Array";"Array"){}
        type("System.Security.Cryptography.HashAlgorithm";"HashAlgorithm"){}
        type("System.Security.Cryptography.KeyedHashAlgorithm";"KeyedHashAlgorithm"){}
        type("System.Byte";"Byte"){}
        type("System.Security.Cryptography.RNGCryptoServiceProvider";"RNGCryptoServiceProvider"){}
        type("System.Type";"Type"){}
        type("System.Security.Claims.Claim";"Claim"){}
        type("System.IO.File";"File"){}
        type("System.Exception";"Exception"){}
        type("System.FormatException";"FormatException"){}
        type("System.IO.Stream";"Stream"){}
        type("System.IO.StreamWriter";"StreamWriter"){}
        type("System.IO.FileStream";"FileStream"){}
        type("System.IO.FileMode";"FileMode"){}
        type("System.Collections.ArrayList";"ArrayList"){}
        type("System.Collections.Generic.Dictionary`2";"Dictionary_Of_T_U"){}
        type("System.Collections.Generic.KeyValuePair`2";"KeyValuePair_Of_T_U"){}
        type("System.Collections.IEnumerator";"IEnumerator"){}
        type("System.Threading.Thread";"Thread"){}
        type("System.Collections.IList";"IList"){}
        type("System.Text.UTF8Encoding";"UTF8Encoding"){}
        type("System.Activator";"Activator"){}
        type("System.Threading.Tasks.Task`1";"Task_Of_T"){}
        type("System.StringComparison";"StringComparison"){}
        type("System.Globalization.DateTimeStyles";"DateTimeStyles"){}
        type("System.Globalization.DateTimeFormatInfo";"DateTimeFormatInfo"){}
        type("System.IO.StreamReader";"StreamReader"){}
        type("System.IO.Path";"Path"){}
        type("System.IO.Directory";"Directory"){}
        type("System.IO.FileAttributes";"FileAttributes"){}
        type("System.IO.SearchOption";"SearchOption"){}
        type("System.IO.FileInfo";"FileInfo"){}
        type("System.DateTimeKind";"DateTimeKind"){}
        type("System.Collections.IEnumerable";"IEnumerable"){}
        type("System.IO.FileNotFoundException";"FileNotFoundException"){}
        type("System.ArgumentNullException";"ArgumentNullException"){}
        type("System.Collections.Generic.IEnumerable`1";"IEnumerable_Of_T"){}
        type("System.Collections.Generic.IEnumerator`1";"IEnumerator_Of_T"){}
        type("System.Security.Cryptography.RSACryptoServiceProvider";"RSACryptoServiceProvider"){}
        type("System.Nullable`1";"Nullable_Of_T"){}
        type("System.Boolean";"Boolean"){}
        type("System.Globalization.TextInfo";"TextInfo"){}
        type("System.Collections.Generic.List`1";"List_Of_T"){}
        type("System.Object";"Object"){}
        type("System.Collections.IDictionaryEnumerator";"IDictionaryEnumerator"){}
        type("System.IO.DirectoryInfo";"DirectoryInfo"){}
        type("System.EventArgs";"EventArgs"){}
        type("System.Guid";"Guid"){}
        type("Microsoft.Win32.Registry";"Registry"){}
        type("System.TimeSpan";"TimeSpan"){}
        type("System.Collections.Queue";"Queue"){}
        type("System.Char";"Char"){}
        type("System.Version";"Version"){}
        type("System.Security.Cryptography.SHA512Managed";"SHA512Managed"){}
    }

    assembly("Microsoft.Dynamics.Nav.PdfWriter")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.PdfWriter.WordToPdf";"WordToPdf"){}
    }

    assembly("System")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Text.RegularExpressions.Regex";"Regex"){}
        type("System.Text.RegularExpressions.RegexOptions";"RegexOptions"){}
        type("System.Uri";"Uri"){}
        type("System.UriPartial";"UriPartial"){}
        type("System.Net.CredentialCache";"CredentialCache"){}
        type("System.Net.HttpStatusCode";"HttpStatusCode"){}
        type("System.Collections.Specialized.NameValueCollection";"NameValueCollection"){}
        type("System.Net.WebException";"WebException"){}
        type("System.Net.Cookie";"Cookie"){}
        type("System.Net.HttpWebResponse";"HttpWebResponse"){}
        type("System.Net.HttpWebRequest";"HttpWebRequest"){}
        type("System.Net.DecompressionMethods";"DecompressionMethods"){}
        type("System.UriKind";"UriKind"){}
        type("System.Net.WebExceptionStatus";"WebExceptionStatus"){}
        type("System.Net.CookieContainer";"CookieContainer"){}
        type("System.Net.WebProxy";"WebProxy"){}
        type("System.Net.SecurityProtocolType";"SecurityProtocolType"){}
        type("System.Net.ServicePointManager";"ServicePointManager"){}
        type("System.Net.NetworkCredential";"NetworkCredential"){}
        type("System.Net.CookieCollection";"CookieCollection"){}
        type("System.Text.RegularExpressions.Match";"Match"){}
        type("System.Text.RegularExpressions.MatchCollection";"MatchCollection"){}
        type("System.Diagnostics.Stopwatch";"Stopwatch"){}
        type("System.ComponentModel.PropertyChangedEventArgs";"PropertyChangedEventArgs"){}
        type("System.ComponentModel.PropertyChangingEventArgs";"PropertyChangingEventArgs"){}
        type("System.ComponentModel.ListChangedEventArgs";"ListChangedEventArgs"){}
        type("System.ComponentModel.AddingNewEventArgs";"AddingNewEventArgs"){}
        type("System.Collections.Specialized.NotifyCollectionChangedEventArgs";"NotifyCollectionChangedEventArgs"){}
        type("System.Net.WebClient";"WebClient"){}
        type("System.UriBuilder";"UriBuilder"){}
        type("System.IO.Compression.CompressionMode";"CompressionMode"){}
        type("System.IO.Compression.GZipStream";"GZipStream"){}
        type("System.Collections.Specialized.StringCollection";"StringCollection"){}
        type("System.Diagnostics.Process";"Process"){}
        type("System.Diagnostics.FileVersionInfo";"FileVersionInfo"){}
        type("System.Text.RegularExpressions.GroupCollection";"GroupCollection"){}
        type("System.Text.RegularExpressions.Group";"Group"){}
        type("System.Text.RegularExpressions.Capture";"Capture"){}
    }

    assembly("System.Web")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b03f5f7f11d50a3a';

        type("System.Web.HttpUtility";"HttpUtility"){}
        type("System.Web.MimeMapping";"MimeMapping"){}
    }

    assembly("System.Xml")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Xml.XmlDocument";"XmlDocument"){}
        type("System.Xml.XmlNodeList";"XmlNodeList"){}
        type("System.Xml.XmlNamespaceManager";"XmlNamespaceManager"){}
        type("System.Xml.XmlNode";"XmlNode"){}
        type("System.Xml.XmlAttributeCollection";"XmlAttributeCollection"){}
        type("System.Xml.XmlNodeType";"XmlNodeType"){}
        type("System.Xml.XmlReader";"XmlReader"){}
        type("System.Xml.XmlReaderSettings";"XmlReaderSettings"){}
        type("System.Xml.XmlUrlResolver";"XmlUrlResolver"){}
        type("System.Xml.DtdProcessing";"DtdProcessing"){}
        type("System.Xml.XmlAttribute";"XmlAttribute"){}
        type("System.Xml.XmlProcessingInstruction";"XmlProcessingInstruction"){}
        type("System.Xml.XmlNamedNodeMap";"XmlNamedNodeMap"){}
        type("System.Xml.XmlConvert";"XmlConvert"){}
        type("System.Xml.XmlElement";"XmlElement"){}
        type("System.Xml.XmlWriter";"XmlWriter"){}
        type("System.Xml.XmlDeclaration";"XmlDeclaration"){}
        type("System.Xml.XmlDocumentType";"XmlDocumentType"){}
        type("System.Xml.XmlTextReader";"XmlTextReader0"){}
        type("System.Xml.Xsl.XslCompiledTransform";"XslCompiledTransform"){}
        type("System.Xml.XmlTextWriter";"XmlTextWriter0"){}
    }

    assembly("Newtonsoft.Json")
    {
        type("Newtonsoft.Json.JsonTextWriter";"JsonTextWriter"){}
        type("Newtonsoft.Json.Formatting";"Formatting"){}
        type("Newtonsoft.Json.JsonConvert";"JsonConvert"){}
        type("Newtonsoft.Json.Linq.JObject";"JObject"){}
        type("Newtonsoft.Json.Linq.JArray";"JArray"){}
        type("Newtonsoft.Json.Linq.JToken";"JToken"){}
        type("Newtonsoft.Json.Linq.JProperty";"JProperty"){}
        type("Newtonsoft.Json.Linq.JValue";"JValue"){}
        type("Newtonsoft.Json.JsonTextReader";"JsonTextReader"){}
    }

    assembly("Microsoft.Dynamics.Nav.OAuth")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.OAuthHelper.OAuthAuthorization";"OAuthAuthorization"){}
        type("Microsoft.Dynamics.Nav.OAuthHelper.Consumer";"Consumer"){}
        type("Microsoft.Dynamics.Nav.OAuthHelper.Token";"Token"){}
    }

    assembly("System.IdentityModel.Tokens.Jwt")
    {
        type("System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler";"JwtSecurityTokenHandler"){}
        type("System.IdentityModel.Tokens.Jwt.JwtSecurityToken";"JwtSecurityToken"){}
    }

    assembly("Microsoft.Dynamics.Nav.ClientExtensions")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.Hosts.OfficeHost";"OfficeHost"){}
        type("Microsoft.Dynamics.Nav.Client.Hosts.OutlookCommand";"OutlookCommand"){}
        type("Microsoft.Dynamics.Nav.Client.Hosts.OfficeHostType";"OfficeHostType"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.AppSource";"AppSource"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.LocationProvider";"LocationProvider"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.UserTours";"UserTours"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.CameraOptions";"CameraOptions"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.CameraProvider";"CameraProvider"){}
        type("Microsoft.Dynamics.Nav.Client.PageNotifier";"PageNotifier"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.DeviceContactProvider";"DeviceContactProvider"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.DeviceContact";"DeviceContact"){}
        type("Microsoft.Dynamics.Nav.Client.Capabilities.Location";"Location"){}
    }

    assembly("Microsoft.Dynamics.Nav.PowerShellRunner")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.PowerShellRunner";"PowerShellRunner"){}
        type("Microsoft.Dynamics.Nav.PSObjectAdapter";"PSObjectAdapter"){}
    }

    assembly("System.Management.Automation")
    {
        Version='3.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("System.Management.Automation.PSCredential";"PSCredential"){}
    }

    assembly("System.Data.Entity.Design")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Data.Entity.Design.PluralizationServices.PluralizationService";"PluralizationService"){}
    }

    assembly("Microsoft.Dynamics.Nav.NavUserAccount")
    {
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.NavUserAccount.NavUserAccountHelper";"NavUserAccountHelper"){}
        type("Microsoft.Dynamics.Nav.NavUserAccount.NavTenantSettingsHelper";"NavTenantSettingsHelper"){}
        type("Microsoft.Dynamics.Nav.NavDocumentService.NavDocumentServiceHelper";"NavDocumentServiceHelper"){}
    }

    assembly("System.Net.Http")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b03f5f7f11d50a3a';

        type("System.Net.Http.HttpMessageHandler";"HttpMessageHandler"){}
        type("System.Net.Http.HttpClient";"HttpClient"){}
        type("System.Net.Http.StreamContent";"StreamContent"){}
        type("System.Net.Http.HttpResponseMessage";"HttpResponseMessage"){}
        type("System.Net.Http.Headers.HttpRequestHeaders";"HttpRequestHeaders"){}
        type("System.Net.Http.Headers.MediaTypeWithQualityHeaderValue";"MediaTypeWithQualityHeaderValue"){}
        type("System.Net.Http.HttpContent";"HttpContent"){}
        type("System.Net.Http.Headers.HttpContentHeaders";"HttpContentHeaders"){}
        type("System.Net.Http.Headers.HttpHeaderValueCollection`1";"HttpHeaderValueCollection_Of_T"){}
    }

    assembly("Microsoft.Dynamics.Nav.AzureMLWrapper")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureMLWrapper.AzureMLRequest";"AzureMLRequest"){}
        type("Microsoft.Dynamics.Nav.AzureMLWrapper.AzureMLParametersBuilder";"AzureMLParametersBuilder"){}
        type("Microsoft.Dynamics.Nav.AzureMLWrapper.AzureMLInputBuilder";"AzureMLInputBuilder"){}
    }

    assembly("Microsoft.Dynamics.Nav.LicensingService.Model")
    {
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.LicensingService.Model.TenantInfo";"TenantInfo"){}
        type("Microsoft.Dynamics.Nav.LicensingService.Model.UserInfo";"UserInfo"){}
        type("Microsoft.Dynamics.Nav.LicensingService.Model.ServicePlanInfo";"ServicePlanInfo"){}
        type("Microsoft.Dynamics.Nav.LicensingService.Model.RoleInfo";"RoleInfo"){}
    }

    assembly("System.Drawing")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b03f5f7f11d50a3a';

        type("System.Drawing.Image";"Image"){}
        type("System.Drawing.ImageFormatConverter";"ImageFormatConverter"){}
        type("System.Drawing.Imaging.ImageFormat";"ImageFormat"){}
        type("System.Drawing.Printing.PrinterSettings";"PrinterSettings"){}
        type("System.Drawing.Printing.PrinterSettings+StringCollection";"PrinterSettings_StringCollection"){}
        type("System.Drawing.Bitmap";"Bitmap"){}
        type("System.Drawing.Graphics";"Graphics"){}
        type("System.Drawing.Color";"Color0"){}
        type("System.Drawing.ColorTranslator";"ColorTranslator"){}
        type("System.Drawing.SolidBrush";"SolidBrush"){}
    }

    assembly("Microsoft.Dynamics.Nav.Client.BusinessChart")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartAddIn";"BusinessChartAddIn"){}
    }

    assembly("Microsoft.Dynamics.Nav.Ncl")
    {
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Runtime.TenantLicenseStatePeriodProvider";"TenantLicenseStatePeriodProvider"){}
        type("Microsoft.Dynamics.Nav.Runtime.Encryption.IAzureKeyVaultSecretProvider";"IAzureKeyVaultSecretProvider"){}
        type("Microsoft.Dynamics.Nav.Runtime.Apps.NavAppALInstaller";"NavAppALInstaller"){}
        type("Microsoft.Dynamics.Nav.Runtime.ExtensionLicenseInformationProvider";"ExtensionLicenseInformationProvider"){}
        type("Microsoft.Dynamics.Nav.Runtime.Apps.ALNavAppOperationInvoker";"ALNavAppOperationInvoker"){}
        type("Microsoft.Dynamics.Nav.Runtime.Apps.ALPackageDeploymentSchedule";"ALPackageDeploymentSchedule"){}
        type("Microsoft.Dynamics.Nav.Runtime.HybridDeploy.ALHybridDeployManagement";"ALHybridDeployManagement"){}
        type("Microsoft.Dynamics.Nav.Runtime.HybridDeploy.ALGetStatusResponse";"ALGetStatusResponse"){}
        type("Microsoft.Dynamics.Nav.Runtime.Designer.NavDesignerALFunctions";"NavDesignerALFunctions"){}
        type("Microsoft.Dynamics.Nav.Runtime.ALAzureAdCodeGrantFlow";"ALAzureAdCodeGrantFlow"){}
        type("Microsoft.Dynamics.Nav.Runtime.ODataFilterGenerator";"ODataFilterGenerator"){}
        type("Microsoft.Dynamics.Nav.Runtime.WebServiceActionContext";"WebServiceActionContext"){}
        type("Microsoft.Dynamics.Nav.Runtime.WebServiceActionContext+StatusCode";"WebServiceActionContext_StatusCode"){}
        type("Microsoft.Dynamics.Nav.Runtime.Designer.DesignerFieldProperty";"DesignerFieldProperty"){}
        type("Microsoft.Dynamics.Nav.Runtime.Designer.DesignerFieldType";"DesignerFieldType"){}
    }

    assembly("Microsoft.Dynamics.Nav.AzureKeyVaultClient")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureKeyVaultClient.MachineLearningCredentialsHelper";"MachineLearningCredentialsHelper"){}
    }

    assembly("Microsoft.Dynamics.Nav.SMTP")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.SMTP.SmtpMessage";"SmtpMessage"){}
        type("Microsoft.Dynamics.Nav.SMTP.MailHelpers";"MailHelpers"){}
    }

    assembly("Microsoft.Dynamics.Nav.O365ActionableMessageWrapper")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.O365ActionableMessageWrapper.ActionableMessage";"ActionableMessage"){}
    }

    assembly("System.IO.Compression")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.IO.Compression.ZipArchive";"ZipArchive"){}
        type("System.IO.Compression.ZipArchiveMode";"ZipArchiveMode"){}
        type("System.IO.Compression.ZipArchiveEntry";"ZipArchiveEntry"){}
    }

    assembly("System.Windows.Forms")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Windows.Forms.OpenFileDialog";"OpenFileDialog"){}
        type("System.Windows.Forms.DialogResult";"DialogResult"){}
        type("System.Windows.Forms.SaveFileDialog";"SaveFileDialog"){}
        type("System.Windows.Forms.FolderBrowserDialog";"FolderBrowserDialog"){}
        type("System.Resources.ResXResourceReader";"ResXResourceReader"){}
        type("System.Resources.ResXResourceWriter";"ResXResourceWriter"){}
        type("System.Resources.ResXDataNode";"ResXDataNode"){}
        type("System.Windows.Forms.PrintDialog";"PrintDialog"){}
    }

    assembly("System.IO.Compression.FileSystem")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.IO.Compression.ZipFile";"ZipFile"){}
        type("System.IO.Compression.ZipFileExtensions";"ZipFileExtensions"){}
    }

    assembly("Microsoft.Dynamics.Nav.Integration.Office")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.IOutlookMessage";"IOutlookMessage"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Word.WordHelper";"WordHelper"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Word.MergeHandler";"MergeHandler"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Word.WordHandler";"WordHandler"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.IOutlookMessageFactory";"IOutlookMessageFactory"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.OutlookMessageFactory";"OutlookMessageFactory"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.OutlookHelper";"OutlookHelper"){}
        type("Microsoft.Dynamics.Nav.Integration.Office.Outlook.OutlookStatusCode";"OutlookStatusCode"){}
    }

    assembly("Microsoft.Exchange.WebServices")
    {
        Version='15.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Exchange.WebServices.Data.WebCredentials";"WebCredentials"){}
        type("Microsoft.Exchange.WebServices.Data.ExchangeCredentials";"ExchangeCredentials"){}
        type("Microsoft.Exchange.WebServices.Data.ExchangeVersion";"ExchangeVersion"){}
        type("Microsoft.Exchange.WebServices.Data.OAuthCredentials";"OAuthCredentials"){}
    }

    assembly("Microsoft.Office.Interop.Word")
    {
        Version='15.0.0.0';
        Culture='neutral';
        PublicKeyToken='71e9bce111e9429c';

        type("Microsoft.Office.Interop.Word.ApplicationClass";"ApplicationClass"){}
        type("Microsoft.Office.Interop.Word.Document";"Document"){}
        type("Microsoft.Office.Interop.Word.InlineShape";"InlineShape"){}
        type("Microsoft.Office.Interop.Word.OLEFormat";"OLEFormat"){}
        type("Microsoft.Office.Interop.Word.LinkFormat";"LinkFormat"){}
        type("Microsoft.Office.Interop.Word.Shape";"Shape"){}
        type("Microsoft.Office.Interop.Word.WdWindowState";"WdWindowState"){}
    }

    assembly("Microsoft.Dynamics.Nav.ImageProcessing")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.ImageProcessing.ImageHandler";"ImageHandler"){}
    }

    assembly("Microsoft.Dynamics.Nav.OLSync.Common")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.NAV.OLSync.Common.XmlTextWriter";"XmlTextWriter"){}
        type("Microsoft.Dynamics.NAV.OLSync.Common.XmlTextReader";"XmlTextReader"){}
    }

    assembly("Microsoft.Dynamics.NAV.OLSync.OLSyncSupplier")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.NAV.OLSync.OLSyncSupplier.OutlookObjectLibrary";"OutlookObjectLibrary"){}
        type("Microsoft.Dynamics.NAV.OLSync.OLSyncSupplier.OutlookPropertyList";"OutlookPropertyList"){}
        type("Microsoft.Dynamics.NAV.OLSync.OLSyncSupplier.OutlookPropertyInfo";"OutlookPropertyInfo"){}
    }

    assembly("Microsoft.Dynamics.Nav.EwsWrapper")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Exchange.IEmailFolder";"IEmailFolder"){}
        type("Microsoft.Dynamics.Nav.Exchange.IFindEmailsResults";"IFindEmailsResults"){}
        type("Microsoft.Dynamics.Nav.Exchange.IEmailMessage";"IEmailMessage"){}
        type("Microsoft.Dynamics.Nav.Exchange.IEmailAddress";"IEmailAddress"){}
        type("Microsoft.Dynamics.Nav.Exchange.ExchangeServiceWrapper";"ExchangeServiceWrapper"){}
        type("Microsoft.Dynamics.Nav.Exchange.FolderInfo";"FolderInfo"){}
        type("Microsoft.Dynamics.Nav.Exchange.FolderInfoEnumerator";"FolderInfoEnumerator"){}
        type("Microsoft.Dynamics.Nav.Exchange.ServiceWrapperFactory";"ServiceWrapperFactory"){}
        type("Microsoft.Dynamics.Nav.Exchange.IAppointment";"IAppointment"){}
        type("Microsoft.Dynamics.Nav.Exchange.IAttachment";"IAttachment"){}
    }

    assembly("Microsoft.Dynamics.Nav.CrmCustomizationHelper")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.CrmCustomizationHelper.CrmHelper";"CrmHelper"){}
    }

    assembly("System.ServiceModel")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.ServiceModel.FaultException";"FaultException"){}
    }

    assembly("Microsoft.Dynamics.Nav.OpenXml")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.WorksheetHelper";"WorksheetHelper"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.WorksheetWriter";"WorksheetWriter"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.WorkbookWriter";"WorkbookWriter"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.WorksheetReader";"WorksheetReader"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.WorkbookReader";"WorkbookReader"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.CellData";"CellData"){}
        type("Microsoft.Dynamics.Nav.OpenXml.Spreadsheet.CellDecorator";"CellDecorator"){}
    }

    assembly("DocumentFormat.OpenXml")
    {
        Version='2.5.5631.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("DocumentFormat.OpenXml.Packaging.VmlDrawingPart";"VmlDrawingPart"){}
        type("DocumentFormat.OpenXml.Packaging.WorksheetCommentsPart";"WorksheetCommentsPart"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Comments";"Comments"){}
        type("DocumentFormat.OpenXml.StringValue";"StringValue"){}
        type("DocumentFormat.OpenXml.Spreadsheet.LegacyDrawing";"LegacyDrawing"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Worksheet";"Worksheet"){}
        type("DocumentFormat.OpenXml.OpenXmlElement";"OpenXmlElement"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Table";"Table"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TableColumn";"TableColumn"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TableColumns";"TableColumns"){}
        type("DocumentFormat.OpenXml.Spreadsheet.XmlColumnProperties";"XmlColumnProperties"){}
        type("DocumentFormat.OpenXml.Spreadsheet.SingleXmlCell";"SingleXmlCell"){}
        type("DocumentFormat.OpenXml.Spreadsheet.XmlCellProperties";"XmlCellProperties"){}
        type("DocumentFormat.OpenXml.Spreadsheet.XmlProperties";"XmlProperties"){}
        type("DocumentFormat.OpenXml.UInt32Value";"UInt32Value"){}
        type("DocumentFormat.OpenXml.Spreadsheet.XmlDataValues";"XmlDataValues"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TablePart";"TablePart"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TableParts";"TableParts"){}
        type("DocumentFormat.OpenXml.Packaging.TableDefinitionPart";"TableDefinitionPart"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Author";"Author"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Authors";"Authors"){}
        type("DocumentFormat.OpenXml.Spreadsheet.AutoFilter";"AutoFilter"){}
        type("DocumentFormat.OpenXml.BooleanValue";"BooleanValue"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TableStyleInfo";"TableStyleInfo"){}
        type("DocumentFormat.OpenXml.Spreadsheet.MapInfo";"MapInfo"){}
        type("DocumentFormat.OpenXml.Packaging.ConnectionsPart";"ConnectionsPart"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Connections";"Connections"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Connection";"Connection"){}
        type("DocumentFormat.OpenXml.Spreadsheet.WebQueryProperties";"WebQueryProperties"){}
        type("DocumentFormat.OpenXml.ByteValue";"ByteValue"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Workbook";"Workbook"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Stylesheet";"Stylesheet"){}
        type("DocumentFormat.OpenXml.Spreadsheet.TableStyles";"TableStyles"){}
        type("DocumentFormat.OpenXml.Packaging.WorkbookPart";"WorkbookPart"){}
        type("DocumentFormat.OpenXml.Packaging.CustomXmlMappingsPart";"CustomXmlMappingsPart"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Schema";"Schema"){}
        type("DocumentFormat.OpenXml.OpenXmlUnknownElement";"OpenXmlUnknownElement"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Map";"Map"){}
        type("DocumentFormat.OpenXml.Spreadsheet.DataBinding";"DataBinding"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Comment";"Comment"){}
        type("DocumentFormat.OpenXml.Spreadsheet.CommentText";"CommentText"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Run";"Run"){}
        type("DocumentFormat.OpenXml.Int32Value";"Int32Value"){}
        type("DocumentFormat.OpenXml.Spreadsheet.CommentList";"CommentList"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Text";"Text"){}
        type("DocumentFormat.OpenXml.Spreadsheet.RunProperties";"RunProperties"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Bold";"Bold"){}
        type("DocumentFormat.OpenXml.Spreadsheet.FontSize";"FontSize"){}
        type("DocumentFormat.OpenXml.DoubleValue";"DoubleValue"){}
        type("DocumentFormat.OpenXml.Spreadsheet.Color";"Color"){}
        type("DocumentFormat.OpenXml.Spreadsheet.RunFont";"RunFont"){}
        type("DocumentFormat.OpenXml.Spreadsheet.RunPropertyCharSet";"RunPropertyCharSet"){}
        type("DocumentFormat.OpenXml.Spreadsheet.SingleXmlCells";"SingleXmlCells"){}
        type("DocumentFormat.OpenXml.Spreadsheet.OrientationValues";"OrientationValues"){}
    }

    assembly("System.Data")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Data.DataTable";"DataTable"){}
        type("System.Data.DataColumn";"DataColumn"){}
        type("System.Data.DataRow";"DataRow"){}
        type("System.Data.DataSet";"DataSet"){}
    }

    assembly("System.Xml.Linq")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Xml.Linq.XDocument";"XDocument"){}
    }

    assembly("System.Security")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b03f5f7f11d50a3a';

        type("System.Security.Cryptography.Xml.SignedXml";"SignedXml"){}
        type("System.Security.Cryptography.Xml.Reference";"Reference"){}
        type("System.Security.Cryptography.Xml.XmlDsigEnvelopedSignatureTransform";"XmlDsigEnvelopedSignatureTransform"){}
    }

    assembly("Microsoft.Dynamics.Nav.PowerBIEmbedded")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.ServiceWrapper";"ServiceWrapper"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportReportRequest";"ImportReportRequest"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportReportRequestList";"ImportReportRequestList"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportReportResponseList";"ImportReportResponseList"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportReportResponse";"ImportReportResponse"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportedReportRequestList";"ImportedReportRequestList"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportedReportResponseList";"ImportedReportResponseList"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportedReportResponse";"ImportedReportResponse"){}
        type("Microsoft.Dynamics.Nav.PowerBIEmbedded.Models.ImportedReport";"ImportedReport"){}
    }

    assembly("Microsoft.Dynamics.Platform.Integration.Office")
    {
        Version='7.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Platform.Integration.Office.Excel.Export.DataEntityExportInfo";"DataEntityExportInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.Excel.Export.DataEntityExportGenerator";"DataEntityExportGenerator"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.OfficeAppInfo";"OfficeAppInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.Excel.WorkbookSettingsManager";"WorkbookSettingsManager"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.DynamicsExtensionSettings";"DynamicsExtensionSettings"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.Excel.Export.ConnectionInfo";"ConnectionInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.DataEntityInfo";"DataEntityInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.BindingInfo";"BindingInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.FieldInfo";"FieldInfo"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.FilterCollectionNode";"FilterCollectionNode"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.AuthenticationOverrides";"AuthenticationOverrides"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.FilterBinaryNode";"FilterBinaryNode"){}
        type("Microsoft.Dynamics.Platform.Integration.Office.FilterLeftOperand";"FilterLeftOperand"){}
    }

    assembly("Microsoft.Dynamics.Nav.Client.BusinessChart.Model")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.BusinessChart.QueryMetadataReader";"QueryMetadataReader"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.QueryFields";"QueryFields"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartBuilder";"BusinessChartBuilder"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.DataMeasureType";"DataMeasureType"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.DataAggregationType";"DataAggregationType"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartMultiLanguageText";"BusinessChartMultiLanguageText"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartDataPoint";"BusinessChartDataPoint"){}
        type("Microsoft.Dynamics.Nav.Client.BusinessChart.BusinessChartData";"BusinessChartData"){}
    }

    assembly("Microsoft.Dynamics.Nav.Types")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Types.ALConfigSettings";"ALConfigSettings"){}
    }

    assembly("System.Runtime.Serialization")
    {
        Version='4.0.0.0';
        Culture='neutral';
        PublicKeyToken='b77a5c561934e089';

        type("System.Xml.XmlDictionaryReader";"XmlDictionaryReader"){}
        type("System.Xml.XmlDictionaryReaderQuotas";"XmlDictionaryReaderQuotas"){}
    }

    assembly("Microsoft.Dynamics.Nav.EtwListener")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.EtwListener.NavPermissionEventReceiver";"NavPermissionEventReceiver"){}
        type("Microsoft.Dynamics.Nav.EtwListener.PermissionCheckEventArgs";"PermissionCheckEventArgs"){}
        type("Microsoft.Dynamics.Nav.EtwListener.NavEventEventReceiver";"NavEventEventReceiver"){}
        type("Microsoft.Dynamics.Nav.EtwListener.EventCheckEventArgs";"EventCheckEventArgs"){}
    }

    assembly("Microsoft.Dynamics.Nav.DocumentService.Types")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.DocumentService.Types.IDocumentService";"IDocumentService"){}
    }

    assembly("Microsoft.Dynamics.Nav.DocumentService")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.DocumentService.DocumentServiceFactory";"DocumentServiceFactory"){}
    }

    assembly("Microsoft.Dynamics.Nav.DocumentReport")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.DocumentReport.WordReportManager";"WordReportManager"){}
        type("Microsoft.Dynamics.Nav.DocumentReport.RdlcReportManager";"RdlcReportManager"){}
        type("Microsoft.Dynamics.Nav.DocumentReport.ReportUpgradeCollection";"ReportUpgradeCollection"){}
        type("Microsoft.Dynamics.Nav.DocumentReport.ReportUpgradeSet";"ReportUpgradeSet"){}
    }

    assembly("Microsoft.Dynamics.Nav.Types.Report")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Types.Report.IReportChangeLogCollection";"IReportChangeLogCollection"){}
        type("Microsoft.Dynamics.Nav.Types.Report.IReportUpgradeSet";"IReportUpgradeSet"){}
        type("Microsoft.Dynamics.Nav.Types.Report.IReportChangeLog";"IReportChangeLog"){}
        type("Microsoft.Dynamics.Nav.Types.Report.ReportChangeLogCollection";"ReportChangeLogCollection"){}
    }

    assembly("Microsoft.Dynamics.Nav.AzureADGraphClient")
    {
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.AzureADGraphClient.GraphQuery";"GraphQuery"){}
    }

    assembly("Microsoft.Dynamics.Nav.Timer")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Timer";"Timer"){}
        type("Microsoft.Dynamics.Nav.ExceptionOccurredEventArgs";"ExceptionOccurredEventArgs"){}
    }

    assembly("Microsoft.Dynamics.Framework.UI.WinForms.DataVisualization.Timeline")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Framework.UI.WinForms.DataVisualization.TimelineVisualization.DataModel+TransactionDataTable";"DataModel_TransactionDataTable"){}
        type("Microsoft.Dynamics.Framework.UI.WinForms.DataVisualization.TimelineVisualization.DataModel+TransactionChangesDataTable";"DataModel_TransactionChangesDataTable"){}
        type("Microsoft.Dynamics.Framework.UI.WinForms.DataVisualization.TimelineVisualization.DataModel+TransactionRow";"DataModel_TransactionRow"){}
        type("Microsoft.Dynamics.Framework.UI.WinForms.DataVisualization.TimelineVisualization.DataModel+TransactionChangesRow";"DataModel_TransactionChangesRow"){}
    }

    assembly("Microsoft.Dynamics.Nav.Client.TimelineVisualization")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.TimelineVisualization.VisualizationScenarios";"VisualizationScenarios"){}
    }

    assembly("Microsoft.Dynamics.Nav.Client.CodeViewerTypes")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Client.CodeViewerTypes.BreakpointCollection";"BreakpointCollection"){}
        type("Microsoft.Dynamics.Nav.Client.CodeViewerTypes.VariableCollection";"VariableCollection"){}
    }

    assembly("Microsoft.Dynamics.Nav.Management.DSObjectPickerWrapper")
    {
        Version='13.0.0.0';
        Culture='neutral';
        PublicKeyToken='31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Management.DSObjectPicker.DSObjectPickerWrapper";"DSObjectPickerWrapper"){}
    }

}
