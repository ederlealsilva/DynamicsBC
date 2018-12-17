report 9172 "Import Profiles"
{
    // version NAVW113.00

    ApplicationArea = #Basic,#Suite;
    Caption = 'Import Profiles';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = false;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    var
        ConfPersMgt: Codeunit "Conf./Personalization Mgt.";
        TempFile: File;
    begin
        TempFile.CreateTempFile;
        FileName := TempFile.Name + '.xml';
        TempFile.Close;
        if Upload(Text001,'',Text002,'',FileName) then
          ConfPersMgt.ImportProfiles(FileName);
        CurrReport.Quit;
    end;

    var
        FileName: Text[250];
        Text001: Label 'Import from XML File';
        Text002: Label 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*';
}

