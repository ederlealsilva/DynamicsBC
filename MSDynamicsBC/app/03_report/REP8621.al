report 8621 "Config. Package - Process"
{
    // version NAVW113.00

    Caption = 'Config. Package - Process';
    ProcessingOnly = true;
    TransactionType = UpdateNoLocks;

    dataset
    {
        dataitem("Config. Package Table";"Config. Package Table")
        {
            DataItemTableView = SORTING("Package Code","Table ID") ORDER(Ascending);

            trigger OnAfterGetRecord()
            begin
                Message(StrSubstNo(ImplementProcessingLogicMsg,"Table ID"));

                // Code sample of the text transformation on package data
                // ProcessCustomRulesExample("Config. Package Table");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        SourceTable = "Config. Package Table";

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

    var
        ImplementProcessingLogicMsg: Label 'Implement processing logic for Table %1 in Report 8621 - Config. Package - Process.', Comment='%1 - a table Id.';

    local procedure ApplyTextTransformation(ConfigPackageTable: Record "Config. Package Table";FieldNo: Integer;TransformationRule: Record "Transformation Rule")
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        if GetConfigPackageData(ConfigPackageData,ConfigPackageTable,FieldNo) then
          repeat
            ConfigPackageData.Value := CopyStr(TransformationRule.TransformText(ConfigPackageData.Value),1,250);
            ConfigPackageData.Modify;
          until ConfigPackageData.Next = 0;
    end;

    local procedure GetConfigPackageData(var ConfigPackageData: Record "Config. Package Data";ConfigPackageTable: Record "Config. Package Table";FieldId: Integer): Boolean
    begin
        ConfigPackageData.SetRange("Package Code",ConfigPackageTable."Package Code");
        ConfigPackageData.SetRange("Table ID",ConfigPackageTable."Table ID");
        ConfigPackageData.SetRange("Field ID",FieldId);
        exit(ConfigPackageData.FindSet(true,false));
    end;

    procedure ProcessCustomRulesExample(ConfigPackageTable: Record "Config. Package Table")
    var
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        PaymentTerms: Record "Payment Terms";
        TransformationRule: Record "Transformation Rule";
    begin
        case ConfigPackageTable."Table ID" of
          DATABASE::"Payment Terms":
            begin
              TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::"Title Case";
              ApplyTextTransformation(ConfigPackageTable,PaymentTerms.FieldNo(Description),TransformationRule);
            end;
          DATABASE::"Bank Account":
            begin
              TransformationRule."Transformation Type" :=
                TransformationRule."Transformation Type"::"Remove Non-Alphanumeric Characters";
              ApplyTextTransformation(ConfigPackageTable,BankAccount.FieldNo("SWIFT Code"),TransformationRule);
              ApplyTextTransformation(ConfigPackageTable,BankAccount.FieldNo(IBAN),TransformationRule);
            end;
          DATABASE::Customer:
            begin
              TransformationRule."Transformation Type" := TransformationRule."Transformation Type"::Replace;
              TransformationRule."Find Value" := 'Mister';
              TransformationRule."Replace Value" := 'Mr.';
              ApplyTextTransformation(ConfigPackageTable,Customer.FieldNo(Name),TransformationRule);
            end;
        end;
    end;
}

