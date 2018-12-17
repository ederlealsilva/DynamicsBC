page 1751 "Data Classification Worksheet"
{
    // version NAVW113.00

    AccessByPermission = TableData "Data Sensitivity"=R;
    ApplicationArea = All;
    Caption = 'Data Classification Worksheet';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Manage,View';
    RefreshOnActivate = true;
    SourceTable = "Data Sensitivity";
    SourceTableView = WHERE("Field Caption"=FILTER(<>''));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No";"Table No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Field No";"Field No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
                field("Table Caption";"Table Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                }
                field("Field Caption";"Field Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    Style = Standard;
                    StyleExpr = TRUE;
                }
                field("Field Type";"Field Type")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    Style = Standard;
                    StyleExpr = TRUE;
                }
                field("Data Sensitivity";"Data Sensitivity")
                {
                    ApplicationArea = All;
                    OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';

                    trigger OnValidate()
                    begin
                        Validate("Last Modified By",UserSecurityId);
                        Validate("Last Modified",CurrentDateTime);
                        SetLastMidifiedBy;
                    end;
                }
                field("Data Classification";"Data Classification")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    Visible = false;
                }
                field(LastModifiedBy;LastModifiedBy)
                {
                    ApplicationArea = All;
                    Caption = 'Last Modified By';
                    Editable = false;
                    Enabled = false;
                }
                field("Last Modified";"Last Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Edit)
            {
                Caption = 'Edit';
                action("Set Up Data Classifications")
                {
                    ApplicationArea = All;
                    Caption = 'Set Up Data Classifications';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Open the Data Classification Assisted Setup Guide';

                    trigger OnAction()
                    begin
                        PAGE.Run(PAGE::"Data Classification Wizard");
                    end;
                }
                action("Find New Fields")
                {
                    ApplicationArea = All;
                    Caption = 'Find New Fields';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Search for new fields and add them in the data classification worksheet';

                    trigger OnAction()
                    var
                        DataClassificationMgt: Codeunit "Data Classification Mgt.";
                    begin
                        DataClassificationMgt.SyncAllFields;
                    end;
                }
                action("Set as Sensitive")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Sensitive';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the Data Sensitivity of the selected fields to Sensitive';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Sensitive);
                    end;
                }
                action("Set as Personal")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Personal';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the Data Sensitivity of the selected fields to Personal';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Personal);
                    end;
                }
                action("Set as Normal")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Normal';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the Data Sensitivity of the selected fields to Normal';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Normal);
                    end;
                }
                action("Set as Company Confidential")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Company Confidential';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the Data Sensitivity of the selected fields to Company Confidential';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::"Company Confidential");
                    end;
                }
            }
            group(View)
            {
                Caption = 'View';
                action("View Similar Fields")
                {
                    ApplicationArea = All;
                    Caption = 'View Similar Fields';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View the fields of the related records that have similar name with one of the fields selected.';

                    trigger OnAction()
                    var
                        DataClassificationMgt: Codeunit "Data Classification Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Rec);
                        if not FindSet then
                          Error(NoRecordsErr);
                        DataClassificationMgt.FindSimilarFields(Rec);
                        CurrPage.Update;
                    end;
                }
                action("View Unclassified")
                {
                    ApplicationArea = All;
                    Caption = 'View Unclassified';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View only unclassified fields';

                    trigger OnAction()
                    begin
                        SetRange("Data Sensitivity","Data Sensitivity"::Unclassified);
                        CurrPage.Update;
                    end;
                }
                action("View Sensitive")
                {
                    ApplicationArea = All;
                    Caption = 'View Sensitive';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Sensitive';

                    trigger OnAction()
                    begin
                        SetRange("Data Sensitivity","Data Sensitivity"::Sensitive);
                        CurrPage.Update;
                    end;
                }
                action("View Personal")
                {
                    ApplicationArea = All;
                    Caption = 'View Personal';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Personal';

                    trigger OnAction()
                    begin
                        SetRange("Data Sensitivity","Data Sensitivity"::Personal);
                        CurrPage.Update;
                    end;
                }
                action("View Normal")
                {
                    ApplicationArea = All;
                    Caption = 'View Normal';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Normal';

                    trigger OnAction()
                    begin
                        SetRange("Data Sensitivity","Data Sensitivity"::Normal);
                        CurrPage.Update;
                    end;
                }
                action("View Company Confidential")
                {
                    ApplicationArea = All;
                    Caption = 'View Company Confidential';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Company Confidential';

                    trigger OnAction()
                    begin
                        SetRange("Data Sensitivity","Data Sensitivity"::"Company Confidential");
                        CurrPage.Update;
                    end;
                }
                action("View All")
                {
                    ApplicationArea = All;
                    Caption = 'View All';
                    Image = ClearFilter;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View all fields';

                    trigger OnAction()
                    begin
                        Reset;
                        SetRange("Company Name",CompanyName);
                        SetFilter("Field Caption",'<>%1','');
                    end;
                }
                action("Show Field Content")
                {
                    ApplicationArea = All;
                    Caption = 'Show Field Content';
                    Enabled = FieldContentEnabled;
                    Image = "Table";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Show all the unique values of the selected field';

                    trigger OnAction()
                    var
                        TempFieldContentBuffer: Record "Field Content Buffer" temporary;
                        DataClassificationMgt: Codeunit "Data Classification Mgt.";
                        RecordRef: RecordRef;
                        FieldRef: FieldRef;
                    begin
                        RecordRef.Open("Table No");
                        if RecordRef.FindSet then
                          repeat
                            FieldRef := RecordRef.Field("Field No");
                            DataClassificationMgt.PopulateFieldValue(FieldRef,TempFieldContentBuffer);
                          until RecordRef.Next = 0;
                        PAGE.RunModal(PAGE::"Field Content Buffer",TempFieldContentBuffer);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        CurrPage.SetSelectionFilter(DataSensitivity);
        FieldContentEnabled :=
          (("Field Type" = "Field Type"::Code) or
           ("Field Type" = "Field Type"::Text)) and
          (DataSensitivity.Count = 1);
    end;

    trigger OnAfterGetRecord()
    begin
        SetLastMidifiedBy;
    end;

    trigger OnOpenPage()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
        Notification: Notification;
    begin
        Notification.Message := DataClassificationMgt.GetLegalDisclaimerTxt;
        Notification.Send;
        SetRange("Company Name",CompanyName);
        Company.Get(CompanyName);
        if IsEmpty and Company."Evaluation Company" then
          DataClassificationEvalData.CreateEvaluationData;
        DataClassificationMgt.ShowSyncFieldsNotification;
    end;

    var
        NoRecordsErr: Label 'No record has been selected.';
        FieldContentEnabled: Boolean;
        LastModifiedBy: Text;
        DeletedUserTok: Label 'Deleted User';
        ClassifyAllfieldsQst: Label 'Do you want to set data sensitivity to %1 on %2 fields?', Comment='%1=Choosen sensitivity %2=total number of fields';

    local procedure SetSensitivityToSelection(Sensitivity: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        CurrPage.SetSelectionFilter(DataSensitivity);
        if DataSensitivity.Count > 20 then
          if not Confirm(StrSubstNo(
                 ClassifyAllfieldsQst,
                 SelectStr(Sensitivity + 1,DataClassificationMgt.GetDataSensitivityOptionString),
                 DataSensitivity.Count))
          then
            exit;

        DataClassificationMgt.SetSensitivities(DataSensitivity,Sensitivity);
        CurrPage.Update;
    end;

    local procedure SetLastMidifiedBy()
    var
        User: Record User;
    begin
        LastModifiedBy := '';
        if User.Get("Last Modified By") then
          LastModifiedBy := User."User Name"
        else
          if not IsNullGuid("Last Modified By") then
            LastModifiedBy := DeletedUserTok;
    end;
}

