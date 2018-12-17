table 130400 "CAL Test Suite"
{
    // version NAVW113.00

    Caption = 'CAL Test Suite';
    DataCaptionFields = Name,Description;
    LookupPageID = "CAL Test Suites";

    fields
    {
        field(1;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(3;"Tests to Execute";Integer)
        {
            CalcFormula = Count("CAL Test Line" WHERE ("Test Suite"=FIELD(Name),
                                                       "Line Type"=CONST(Function),
                                                       Run=CONST(true)));
            Caption = 'Tests to Execute';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;"Tests not Executed";Integer)
        {
            CalcFormula = Count("CAL Test Line" WHERE ("Test Suite"=FIELD(Name),
                                                       "Line Type"=CONST(Function),
                                                       Run=CONST(true),
                                                       Result=CONST(" ")));
            Caption = 'Tests not Executed';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;Failures;Integer)
        {
            CalcFormula = Count("CAL Test Line" WHERE ("Test Suite"=FIELD(Name),
                                                       "Line Type"=CONST(Function),
                                                       Run=CONST(true),
                                                       Result=CONST(Failure)));
            Caption = 'Failures';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"Last Run";DateTime)
        {
            Caption = 'Last Run';
            Editable = false;
        }
        field(8;Export;Boolean)
        {
            Caption = 'Export';
        }
        field(21;Attachment;BLOB)
        {
            Caption = 'Attachment';
        }
        field(23;"Update Test Coverage Map";Boolean)
        {
            Caption = 'Update Test Coverage Map';
        }
    }

    keys
    {
        key(Key1;Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        CALTestLine: Record "CAL Test Line";
    begin
        CALTestLine.SetRange("Test Suite",Name);
        CALTestLine.DeleteAll(true);
    end;

    var
        CouldNotExportErr: Label 'Could not export Unit Test XML definition.', Locked=true;
        UTTxt: Label 'UT', Locked=true;
        CALTestSuiteXML: XMLport "CAL Test Suite";
        CALTestResultsXML: XMLport "CAL Test Results";

    procedure ExportTestSuiteSetup()
    var
        CALTestSuite: Record "CAL Test Suite";
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        OStream: OutStream;
    begin
        TempBlob.Blob.CreateOutStream(OStream);
        CALTestSuite.SetRange(Name,Name);

        CALTestSuiteXML.SetDestination(OStream);
        CALTestSuiteXML.SetTableView(CALTestSuite);

        if not CALTestSuiteXML.Export then
          Error(CouldNotExportErr);

        FileMgt.ServerTempFileName('*.xml');
        FileMgt.BLOBExport(TempBlob,UTTxt + Name,true);
    end;

    procedure ImportTestSuiteSetup()
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
    begin
        FileMgt.BLOBImport(TempBlob,'*.xml');
        TempBlob.Blob.CreateInStream(IStream);
        CALTestSuiteXML.SetSource(IStream);
        CALTestSuiteXML.Import;
    end;

    procedure ExportTestSuiteResult()
    var
        CALTestSuite: Record "CAL Test Suite";
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        OStream: OutStream;
    begin
        TempBlob.Blob.CreateOutStream(OStream);
        CALTestSuite.SetRange(Name,Name);

        CALTestResultsXML.SetDestination(OStream);
        CALTestResultsXML.SetTableView(CALTestSuite);

        if not CALTestResultsXML.Export then
          Error(CouldNotExportErr);

        FileMgt.ServerTempFileName('*.xml');
        FileMgt.BLOBExport(TempBlob,UTTxt + Name,true);
    end;

    procedure ImportTestSuiteResult()
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
    begin
        FileMgt.BLOBImport(TempBlob,'*.xml');
        TempBlob.Blob.CreateInStream(IStream);
        CALTestResultsXML.SetSource(IStream);
        CALTestResultsXML.Import;
    end;
}

