report 9171 "Export Profiles"
{
    // version NAVW113.00

    ApplicationArea = #Basic,#Suite;
    Caption = 'Export Profiles';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("All Profile";"All Profile")
        {
            DataItemTableView = SORTING("Profile ID");
            RequestFilterFields = "Profile ID";
        }
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

    trigger OnPostReport()
    var
        ConfPersMgt: Codeunit "Conf./Personalization Mgt.";
        ToFile: Text[1024];
    begin
        ConfPersMgt.ExportProfiles(FileName,"All Profile");

        ToFile := "All Profile"."Profile ID" + '.xml';
        Download(FileName,Text001,'',Text002,ToFile);
    end;

    trigger OnPreReport()
    var
        FileMgt: Codeunit "File Management";
    begin
        FileName := FileMgt.ServerTempFileName('xml');
    end;

    var
        FileName: Text;
        Text001: Label 'Export to XML File';
        Text002: Label 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*';
}

