table 1650 "Curr. Exch. Rate Update Setup"
{
    // version NAVW113.00

    Caption = 'Curr. Exch. Rate Update Setup';
    DataCaptionFields = "Code",Description;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            var
                DataExchCode: Code[20];
            begin
                if "Data Exch. Def Code" = '' then begin
                  DataExchCode := SuggestDataExchangeCode;
                  CreateDataExchangeDefinition(DataExchCode);
                  Validate("Data Exch. Def Code",DataExchCode);
                end;
            end;
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(3;"Web Service URL";BLOB)
        {
            Caption = 'Service URL';
        }
        field(5;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup";
            begin
                if Enabled then begin
                  VerifyServiceURL;
                  VerifyDataExchangeLineDefinition;
                  AutoUpdateExchangeRates;
                  CurrExchRateUpdateSetup.SetRange(Enabled,true);
                  CurrExchRateUpdateSetup.SetFilter(Code,'<> %1',Code);
                  if CurrExchRateUpdateSetup.FindFirst then begin
                    CurrExchRateUpdateSetup.Enabled := false;
                    CurrExchRateUpdateSetup.Modify;
                  end;
                end
            end;
        }
        field(10;"Service Provider";Text[30])
        {
            Caption = 'Service Provider';
        }
        field(11;"Terms of Service";Text[250])
        {
            Caption = 'Terms of Service';
            ExtendedDatatype = URL;
        }
        field(20;"Data Exch. Def Code";Code[20])
        {
            Caption = 'Data Exch. Def Code';
            TableRelation = "Data Exch. Def".Code;
        }
        field(21;"Log Web Requests";Boolean)
        {
            Caption = 'Log Web Requests';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        if DataExchDef.Get("Data Exch. Def Code") then
          DataExchDef.Delete(true);
    end;

    var
        DataExchangeCurrencyNosTxt: Label 'CURRENCY0001', Comment='Used to populate the Code field in Table 1222. It''s value must start or end with a number';
        DataExchangeLineDefCodeTxt: Label 'CurrExchange', Locked=true;
        DataExchangeLineDefNameTxt: Label 'Parent Node for Currency Code';
        DataExchangeMappingDefNameTxt: Label 'Mapping for Currency Exchange';
        MissingDataLineTagErr: Label '%1 for %2 must not be blank.', Comment='%1 - source XML node; %2 - parent node for caption code';
        MissingServiceURLErr: Label 'The %1 field must not be blank.', Comment='%1 - Service URL';
        DailyUpdateQst: Label 'A job queue entry for daily update of exchange rates has been created.\\Do you want to open the Job Queue Entries window?';

    [Scope('Personalization')]
    procedure GetWebServiceURL(var ServiceURL: Text): Text
    var
        InStream: InStream;
    begin
        CalcFields("Web Service URL");
        if "Web Service URL".HasValue then begin
          "Web Service URL".CreateInStream(InStream);
          InStream.Read(ServiceURL);
        end;
    end;

    [Scope('Personalization')]
    procedure SetWebServiceURL(ServiceURL: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        OutStream: OutStream;
    begin
        WebRequestHelper.IsValidUri(ServiceURL);
        WebRequestHelper.IsHttpUrl(ServiceURL);

        "Web Service URL".CreateOutStream(OutStream);
        OutStream.Write(ServiceURL);
        Modify;
    end;

    local procedure SuggestDataExchangeCode() NewDataExchCode: Code[20]
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        NewDataExchCode := DataExchangeCurrencyNosTxt;
        while DataExchDef.Get(NewDataExchCode) do begin
          if NewDataExchCode = IncStr(NewDataExchCode) then
            exit(Code);
          NewDataExchCode := IncStr(NewDataExchCode);
        end;
    end;

    local procedure CreateDataExchangeDefinition(DataExchCode: Code[20])
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        if DataExchDef.Get(DataExchCode) then
          exit;

        DataExchDef.Init;
        DataExchDef.Code := DataExchCode;
        DataExchDef.Name := Code;
        DataExchDef.Type := DataExchDef.Type::"Generic Import";
        DataExchDef."Reading/Writing Codeunit" := CODEUNIT::"Import XML File to Data Exch.";
        DataExchDef.Insert(true);

        DataExchLineDef.Init;
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code := DataExchangeLineDefCodeTxt;
        DataExchLineDef.Name := DataExchangeLineDefNameTxt;
        DataExchLineDef.Insert(true);

        DataExchMapping.Init;
        DataExchMapping."Data Exch. Def Code" := DataExchDef.Code;
        DataExchMapping."Data Exch. Line Def Code" := DataExchangeLineDefCodeTxt;
        DataExchMapping.Name := DataExchangeMappingDefNameTxt;
        DataExchMapping."Table ID" := DATABASE::"Currency Exchange Rate";
        DataExchMapping."Mapping Codeunit" := CODEUNIT::"Map Currency Exchange Rate";
        DataExchMapping.Insert(true);
    end;

    [TryFunction]
    procedure GetXMLStructure(var XMLBuffer: Record "XML Buffer";ServiceURL: Text)
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.GenerateStructureFromPath(XMLBuffer,ServiceURL);
    end;

    local procedure AutoUpdateExchangeRates()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordID;
    begin
        if Enabled then begin
          JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
            CODEUNIT::"Update Currency Exchange Rates",DummyRecId);
          if Confirm(DailyUpdateQst) then
            PAGE.Run(PAGE::"Job Queue Entry Card",JobQueueEntry);
        end else
          if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
               CODEUNIT::"Update Currency Exchange Rates")
          then
            JobQueueEntry.Cancel;
    end;

    [Scope('Personalization')]
    procedure VerifyDataExchangeLineDefinition()
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchFieldMappingBuf: Record "Data Exch. Field Mapping Buf.";
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code","Data Exch. Def Code");
        DataExchLineDef.SetRange("Parent Code",'');
        DataExchLineDef.FindFirst;

        if DataExchLineDef."Data Line Tag" = '' then
          Error(MissingDataLineTagErr,DataExchFieldMappingBuf.FieldCaption(Source),DataExchangeLineDefNameTxt);
    end;

    [Scope('Personalization')]
    procedure VerifyServiceURL()
    begin
        if not "Web Service URL".HasValue then
          Error(MissingServiceURLErr,FieldCaption("Web Service URL"));
    end;

    [Scope('Personalization')]
    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run",JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run",CODEUNIT::"Update Currency Exchange Rates");
        if JobQueueEntry.FindFirst then
          PAGE.Run(PAGE::"Job Queue Entry Card",JobQueueEntry);
    end;

    [Scope('Personalization')]
    procedure SetupService()
    begin
        OnBeforeSetupCurrencyExchRateService(Rec);
        if IsEmpty then
          CODEUNIT.Run(CODEUNIT::"Set Up Curr Exch Rate Service");
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnBeforeSetupCurrencyExchRateService(var CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup")
    begin
    end;
}

