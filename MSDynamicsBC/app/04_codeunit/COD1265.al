codeunit 1265 "Bank Data Conv. Serv. Mgt."
{
    // version NAVW113.00

    Permissions = TableData "Bank Data Conv. Service Setup"=r;

    trigger OnRun()
    begin
    end;

    var
        MissingCredentialsQst: Label 'The %1 is missing the user name or password. Do you want to open the %1 page?';
        MissingCredentialsErr: Label 'The user name and password must be filled in %1 page.';
        ResultPathTxt: Label '/amc:%1/return/syslog[syslogtype[text()="error"]]', Locked=true;
        FinstaPathTxt: Label '/amc:%1/return/finsta/transactions', Locked=true;
        HeaderErrPathTxt: Label '/amc:%1/return/header/result[text()="error"]', Locked=true;
        ConvErrPathTxt: Label '/amc:%1/return/pack/convertlog[syslogtype[text()="error"]]', Locked=true;
        DataPathTxt: Label '/amc:%1/return/pack/data/text()', Locked=true;
        ApiVersionTxt: Label 'nav02', Locked=true;

    [Scope('Personalization')]
    procedure InitDefaultURLs(var BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup")
    begin
        BankDataConvServiceSetup."Sign-up URL" := 'https://amcbanking.com/store/amc-banking/microsoft-dynamics-nav/version-2015-2016/';
        BankDataConvServiceSetup."Service URL" := 'https://nav.amcbanking.com/' + BankDataConvApiVersion;
        BankDataConvServiceSetup."Support URL" := 'http://www.amcbanking.dk/nav/support';
        BankDataConvServiceSetup."Namespace API Version" := BankDataConvApiVersion;
    end;

    [Scope('Personalization')]
    procedure SetURLsToDefault(var BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup")
    begin
        InitDefaultURLs(BankDataConvServiceSetup);
        BankDataConvServiceSetup.Modify;
    end;

    [Scope('Personalization')]
    procedure GetNamespace(): Text
    begin
        exit('http://' + BankDataConvApiVersion + '.soap.xml.link.amc.dk/');
    end;

    [Scope('Personalization')]
    procedure GetSupportURL(XmlNode: DotNet XmlNode): Text
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        XMLDOMMgt: Codeunit "XML DOM Management";
        SupportURL: Text;
    begin
        SupportURL := XMLDOMMgt.FindNodeText(XmlNode,'url');
        if SupportURL <> '' then
          exit(SupportURL);

        BankDataConvServiceSetup.Get;
        exit(BankDataConvServiceSetup."Support URL");
    end;

    [Scope('Personalization')]
    procedure CheckCredentials()
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if not BankDataConvServiceSetup.Get or (not BankDataConvServiceSetup.HasPassword) or (not BankDataConvServiceSetup.HasUserName)
        then begin
          if CompanyInformationMgt.IsDemoCompany then begin
            BankDataConvServiceSetup.DeleteAll(true);
            BankDataConvServiceSetup.Init;
            BankDataConvServiceSetup.Insert(true);
          end else
            if Confirm(StrSubstNo(MissingCredentialsQst,BankDataConvServiceSetup.TableCaption),true) then begin
              Commit;
              PAGE.RunModal(PAGE::"Bank Data Conv. Service Setup",BankDataConvServiceSetup);
            end;

          if not BankDataConvServiceSetup.Get or not BankDataConvServiceSetup.HasPassword then
            Error(MissingCredentialsErr,BankDataConvServiceSetup.TableCaption);
        end;
    end;

    [Scope('Personalization')]
    procedure GetErrorXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ResultPathTxt,ResponseNode));
    end;

    [Scope('Personalization')]
    procedure GetFinstaXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(FinstaPathTxt,ResponseNode));
    end;

    [Scope('Personalization')]
    procedure GetHeaderErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(HeaderErrPathTxt,ResponseNode));
    end;

    [Scope('Personalization')]
    procedure GetConvErrXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(ConvErrPathTxt,ResponseNode));
    end;

    [Scope('Personalization')]
    procedure GetDataXPath(ResponseNode: Text): Text
    begin
        exit(StrSubstNo(DataPathTxt,ResponseNode));
    end;

    [EventSubscriber(ObjectType::Table, 1400, 'OnRegisterServiceConnection', '', false, false)]
    [Scope('Personalization')]
    procedure HandleBankDataConvRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        RecRef: RecordRef;
    begin
        if not BankDataConvServiceSetup.Get then
          BankDataConvServiceSetup.Insert(true);
        RecRef.GetTable(BankDataConvServiceSetup);

        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        with BankDataConvServiceSetup do begin
          if "Service URL" = '' then
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

          ServiceConnection.InsertServiceConnection(
            ServiceConnection,RecRef.RecordId,TableName,"Service URL",PAGE::"Bank Data Conv. Service Setup");
        end;
    end;

    [Scope('Personalization')]
    procedure BankDataConvApiVersion(): Text[10]
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
    begin
        if BankDataConvServiceSetup.Get then
          if BankDataConvServiceSetup."Namespace API Version" <> '' then
            exit(BankDataConvServiceSetup."Namespace API Version");

        exit(ApiVersionTxt);
    end;
}

