page 8614 "Config. Package Card"
{
    // version NAVW113.00

    Caption = 'Config. Package Card';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Manage,Package';
    SourceTable = "Config. Package";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                    ApplicationArea = Basic,Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code for the configuration package.';
                }
                field("Package Name";"Package Name")
                {
                    ApplicationArea = Basic,Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the package.';
                }
                field("Product Version";"Product Version")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the version of the product that you are configuring. You can use this field to help differentiate among various versions of a solution.';
                }
                field("Language ID";"Language ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the Windows language to use for the configuration package. Choose the field and select a language ID from the list.';
                }
                field("Processing Order";"Processing Order")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the order in which the package is to be processed.';
                }
                field("Exclude Config. Tables";"Exclude Config. Tables")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether to exclude configuration tables from the package. Select the check box to exclude these types of tables.';
                }
            }
            part(Control10;"Config. Package Subform")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Package Code"=FIELD(Code);
                SubPageView = SORTING("Package Code","Table ID");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Package)
            {
                Caption = 'Package';
                action("Export Package")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export Package';
                    Ellipsis = true;
                    Enabled = AditionalOptionsEnabled;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Create a .rapidstart file that which delivers the package contents in a compressed format. Configuration questionnaires, configuration templates, and the configuration worksheet are added to the package automatically unless you specifically decide to exclude them.';

                    trigger OnAction()
                    begin
                        TestField(Code);
                        ConfigXMLExchange.ExportPackage(Rec);
                    end;
                }
                action("Import Package")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import Package';
                    Ellipsis = true;
                    Enabled = AditionalOptionsEnabled;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Import a .rapidstart package file.';

                    trigger OnAction()
                    begin
                        ConfigXMLExchange.ImportPackageXMLFromClient;
                    end;
                }
                action("Export to Excel")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export to Excel';
                    Enabled = AditionalOptionsEnabled;
                    Image = ExportToExcel;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Export the data in the package to Excel.';

                    trigger OnAction()
                    var
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
                    begin
                        TestField(Code);

                        ConfigPackageTable.SetRange("Package Code",Code);
                        if Confirm(Text004,true,Code,ConfigPackageTable.Count) then
                          ConfigExcelExchange.ExportExcelFromTables(ConfigPackageTable);
                    end;
                }
                action("Import from Excel")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Import from Excel';
                    Enabled = AditionalOptionsEnabled;
                    Image = ImportExcel;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Begin the migration of legacy data.';

                    trigger OnAction()
                    var
                        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
                    begin
                        ConfigExcelExchange.ImportExcelFromPackage;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Get Tables")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Get Tables';
                    Ellipsis = true;
                    Image = GetLines;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ToolTip = 'Select tables that you want to add to the configuration package.';

                    trigger OnAction()
                    var
                        GetPackageTables: Report "Get Package Tables";
                    begin
                        CurrPage.SaveRecord;
                        GetPackageTables.Set(Code);
                        GetPackageTables.RunModal;
                        Clear(GetPackageTables);
                    end;
                }
                action("Apply Package")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Apply Package';
                    Image = Apply;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Import the configuration package and apply the package database data at the same time.';

                    trigger OnAction()
                    var
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigPackageMgt: Codeunit "Config. Package Management";
                    begin
                        TestField(Code);
                        if Confirm(Text003,true,Code) then begin
                          ConfigPackageTable.SetRange("Package Code",Code);
                          ConfigPackageMgt.ApplyPackage(Rec,ConfigPackageTable,true);
                        end;
                    end;
                }
                action("Copy Package")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Copy Package';
                    Image = CopyWorksheet;
                    ToolTip = 'Copy an existing configuration package to create a new package based on the same content.';

                    trigger OnAction()
                    var
                        CopyPackage: Report "Copy Package";
                    begin
                        TestField(Code);
                        CopyPackage.Set(Rec);
                        CopyPackage.RunModal;
                        Clear(CopyPackage);
                    end;
                }
                action("Validate Package")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Validate Package';
                    Image = CheckRulesSyntax;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Determine if you have introduced errors, such as not including tables that the configuration relies on.';

                    trigger OnAction()
                    var
                        ConfigPackageTable: Record "Config. Package Table";
                        TempConfigPackageTable: Record "Config. Package Table" temporary;
                        ConfigPackageMgt: Codeunit "Config. Package Management";
                    begin
                        if Confirm(Text002,true,"Package Name") then begin
                          ConfigPackageTable.SetRange("Package Code",Code);
                          ConfigPackageMgt.ValidatePackageRelations(ConfigPackageTable,TempConfigPackageTable,true);
                        end;
                    end;
                }
                separator(Separator7)
                {
                }
                action("Export to Translation")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Export to Translation';
                    Image = Export;
                    ToolTip = 'Export the data to a file that is suited for translation.';
                    Visible = false;

                    trigger OnAction()
                    var
                        ConfigPackageTable: Record "Config. Package Table";
                    begin
                        TestField(Code);

                        ConfigXMLExchange.SetAdvanced(true);
                        ConfigPackageTable.SetRange("Package Code",Code);
                        if Confirm(Text004,true,Code,ConfigPackageTable.Count) then
                          ConfigXMLExchange.ExportPackageXML(ConfigPackageTable,'');
                    end;
                }
                action(ProcessData)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Process Data';
                    Image = DataEntry;
                    ToolTip = 'Process data in the configuration package before you apply it to the database. For example, convert dates and decimals to the format required by the regional settings on a user''s computer and remove leading/trailing spaces or special characters.';

                    trigger OnAction()
                    begin
                        ProcessPackageTablesWithDefaultProcessingReport;
                        ProcessPackageTablesWithCustomProcessingReports;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfigPackage: Record "Config. Package";
    begin
        AditionalOptionsEnabled := ConfigPackage.WritePermission;
    end;

    var
        ConfigXMLExchange: Codeunit "Config. XML Exchange";
        Text002: Label 'Validate package %1?';
        Text003: Label 'Apply data from package %1?';
        Text004: Label 'Export package %1 with %2 tables?';
        AditionalOptionsEnabled: Boolean;

    local procedure ProcessPackageTablesWithDefaultProcessingReport()
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.SetRange("Package Code",Code);
        ConfigPackageTable.SetRange("Processing Report ID",0);
        if not ConfigPackageTable.IsEmpty then
          REPORT.RunModal(REPORT::"Config. Package - Process",false,false,ConfigPackageTable);
    end;

    local procedure ProcessPackageTablesWithCustomProcessingReports()
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.SetRange("Package Code",Code);
        ConfigPackageTable.SetFilter("Processing Report ID",'<>0',0);
        if ConfigPackageTable.FindSet then
          repeat
            REPORT.RunModal(ConfigPackageTable."Processing Report ID",false,false,ConfigPackageTable)
          until ConfigPackageTable.Next = 0;
    end;
}

