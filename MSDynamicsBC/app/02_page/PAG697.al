page 697 "Manage Style Sheets - Pages"
{
    // version NAVW113.00

    ApplicationArea = Advanced;
    Caption = 'Manage Style Sheets';
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Style Sheet";
    SourceTableView = SORTING("Object Type","Object ID","Program ID")
                      ORDER(Ascending);
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(AppliesTo;AppliesTo)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Show';
                    OptionCaption = 'All style sheets,Style sheets common to all pages,Style sheets for a specific page';
                    ToolTip = 'Specifies if the selected value is shown in the window.';

                    trigger OnValidate()
                    begin
                        if AppliesTo = AppliesTo::"Style sheets for a specific page" then
                          StylesheetsfortAppliesToOnVali;
                        if AppliesTo = AppliesTo::"Style sheets common to all pages" then
                          StylesheetscommAppliesToOnVali;
                        if AppliesTo = AppliesTo::"All style sheets" then
                          AllstylesheetsAppliesToOnValid;
                    end;
                }
                field(PageNo;ObjectID)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Page No.';
                    Enabled = PageNoEnable;
                    ToolTip = 'Specifies the number of the page from which you want to export data.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Objects: Page Objects;
                    begin
                        AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Page);
                        Objects.SetTableView(AllObjWithCaption);
                        if ObjectID <> 0 then begin
                          AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,ObjectID);
                          Objects.SetRecord(AllObjWithCaption);
                        end;
                        Objects.LookupMode := true;
                        if Objects.RunModal = ACTION::LookupOK then begin
                          Objects.GetRecord(AllObjWithCaption);
                          ObjectID := AllObjWithCaption."Object ID";
                          SetObjectFilters;
                          Text := Format(ObjectID);
                          exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        SetObjectFilters;
                        ObjectIDOnAfterValidate;
                    end;
                }
                field(PageName;ObjectName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Page Name';
                    Editable = false;
                    Enabled = PageNameEnable;
                    ToolTip = 'Specifies the name of the page from which you want to export data.';
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object ID";"Object ID")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Object No.';
                    Editable = false;
                    ToolTip = 'Specifies the ID of the object that the style sheet applies to.';
                    Visible = false;
                }
                field("AllObjWithCaption.""Object Caption""";AllObjWithCaption."Object Caption")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Object Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the object on the line.';
                }
                field(SendToProgramName;SendToProgramName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Send-to Program';
                    Editable = false;
                    ToolTip = 'Specifies which program you want to send the pages to, such as Microsoft Excel, Microsoft Word, or Internet Explorer.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Style Sheet Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the style sheet that you want to import to another program.';
                }
                field(HasStyleSheet;"Style Sheet".HasValue)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Has Style Sheet';
                    Editable = false;
                    ToolTip = 'Specifies that a stylesheet exists for the page.';
                    Visible = false;
                }
                field(Date;Date)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date that a style sheet was added to the table.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Import)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import';
                    Ellipsis = true;
                    Image = Import;
                    ToolTip = 'Import a stylesheet that defines the layout of excel files that you use to import or export data.';

                    trigger OnAction()
                    begin
                        AddStyleSheet;
                    end;
                }
                action("E&xport")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'E&xport';
                    Ellipsis = true;
                    Image = Export;
                    ToolTip = 'Export the style sheets that you apply to data that you export to another program, such as Microsoft Office Word or Excel.';

                    trigger OnAction()
                    var
                        AppLaunchMgt: Codeunit "Application Launch Management";
                    begin
                        AppLaunchMgt.ExportStylesheet(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if SendToProgram."Program ID" <> "Program ID" then
          if SendToProgram.Get("Program ID") then;
        SendToProgramName := SendToProgram.Name;

        if "Object ID" = 0 then begin
          AllObjWithCaption."Object ID" := 0;
          AllObjWithCaption."Object Caption" := Text001;
        end else
          if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,"Object ID") then;
    end;

    trigger OnInit()
    begin
        PageNameEnable := true;
        PageNoEnable := true;
    end;

    trigger OnOpenPage()
    begin
        if ObjectID = 0 then
          AppliesTo := AppliesTo::"All style sheets"
        else
          AppliesTo := AppliesTo::"Style sheets for a specific page";
        SetObjectFilters;
    end;

    var
        SendToProgram: Record "Send-To Program";
        AllObjWithCaption: Record AllObjWithCaption;
        ObjectID: Integer;
        ObjectName: Text[80];
        SendToProgramName: Text[250];
        Text001: Label '<Common to all objects>';
        Text002: Label 'No style sheet has been selected.';
        Text003: Label 'No application has been selected.';
        AppliesTo: Option "All style sheets","Style sheets common to all pages","Style sheets for a specific page";
        Text004: Label 'You must select either Style sheets for this object only or Style sheets common to all objects.';
        [InDataSet]
        PageNoEnable: Boolean;
        [InDataSet]
        PageNameEnable: Boolean;

    [Scope('Personalization')]
    procedure SetObject(NewObjectID: Integer)
    begin
        ObjectID := NewObjectID;
    end;

    local procedure SetObjectFilters()
    begin
        PageNoEnable := AppliesTo = AppliesTo::"Style sheets for a specific page";
        PageNameEnable := PageNoEnable;

        FilterGroup(2);
        SetRange("Object Type","Object Type"::Page);
        case AppliesTo of
          AppliesTo::"All style sheets":
            SetRange("Object ID");
          AppliesTo::"Style sheets common to all pages":
            SetRange("Object ID",0);
          AppliesTo::"Style sheets for a specific page":
            SetRange("Object ID",ObjectID);
        end;
        FilterGroup(0);
    end;

    local procedure AddStyleSheet()
    var
        StyleSheet: Record "Style Sheet";
        ImportStyleSheet: Page "Import Style Sheet";
    begin
        case AppliesTo of
          AppliesTo::"Style sheets for a specific page":
            ImportStyleSheet.SetObjectID("Object Type"::Page,ObjectID,"Program ID");
          AppliesTo::"Style sheets common to all pages":
            ImportStyleSheet.SetObjectID("Object Type"::Page,0,"Program ID");
          AppliesTo::"All style sheets":
            Error(Text004);
        end;

        if ImportStyleSheet.RunModal = ACTION::OK then begin
          ImportStyleSheet.GetStyleSheet(StyleSheet);
          if IsNullGuid(StyleSheet."Program ID") then
            Error(Text003);
          StyleSheet.Insert;
          StyleSheet.CalcFields("Style Sheet");
          if not StyleSheet."Style Sheet".HasValue then
            Error(Text002);
        end;
    end;

    local procedure AllstylesheetsAppliesToOnAfter()
    begin
        CurrPage.Update;
    end;

    local procedure StylesheetscommAppliesToOnAfte()
    begin
        CurrPage.Update;
    end;

    local procedure StylesheetsfortAppliesToOnAfte()
    begin
        CurrPage.Update;
    end;

    local procedure ObjectIDOnAfterValidate()
    begin
        CurrPage.Update;
    end;

    local procedure AllstylesheetsAppliesToOnValid()
    begin
        SetObjectFilters;
        AllstylesheetsAppliesToOnAfter;
    end;

    local procedure StylesheetscommAppliesToOnVali()
    begin
        SetObjectFilters;
        StylesheetscommAppliesToOnAfte;
    end;

    local procedure StylesheetsfortAppliesToOnVali()
    begin
        SetObjectFilters;
        StylesheetsfortAppliesToOnAfte;
    end;
}

