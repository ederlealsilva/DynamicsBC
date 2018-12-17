table 5615 "FA Allocation"
{
    // version NAVW113.00

    Caption = 'FA Allocation';
    DrillDownPageID = "FA Allocations";
    LookupPageID = "FA Allocations";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "FA Posting Group";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(4;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                if "Account No." = '' then
                  exit;
                GLAcc.Get("Account No.");
                GLAcc.CheckGLAcc;
                if "Allocation Type" < "Allocation Type"::Gain then
                  GLAcc.TestField("Direct Posting");
                Description := GLAcc.Name;
            end;
        }
        field(5;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(6;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(7;"Allocation %";Decimal)
        {
            Caption = 'Allocation %';
            DecimalPlaces = 1:1;
            MaxValue = 100;
            MinValue = 0;
        }
        field(8;"Allocation Type";Option)
        {
            Caption = 'Allocation Type';
            OptionCaption = 'Acquisition,Depreciation,Write-Down,Appreciation,Custom 1,Custom 2,Disposal,Maintenance,Gain,Loss,Book Value (Gain),Book Value (Loss)';
            OptionMembers = Acquisition,Depreciation,"Write-Down",Appreciation,"Custom 1","Custom 2",Disposal,Maintenance,Gain,Loss,"Book Value (Gain)","Book Value (Loss)";
        }
        field(9;"Account Name";Text[50])
        {
            CalcFormula = Lookup("G/L Account".Name WHERE ("No."=FIELD("Account No.")));
            Caption = 'Account Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(480;"Dimension Set ID";Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID","Global Dimension 1 Code","Global Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1;"Code","Allocation Type","Line No.")
        {
            SumIndexFields = "Allocation %";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Dimension Set ID" := 0;
        "Global Dimension 1 Code" := '';
        "Global Dimension 2 Code" := '';
    end;

    trigger OnRename()
    begin
        Error(Text000,TableCaption);
    end;

    var
        Text000: Label 'You cannot rename a %1.';
        GLAcc: Record "G/L Account";
        DimMgt: Codeunit DimensionManagement;

    [Scope('Personalization')]
    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber,ShortcutDimCode,"Dimension Set ID");
    end;

    [Scope('Personalization')]
    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet2(
            "Dimension Set ID",StrSubstNo('%1 %2 %3',Code,"Allocation Type","Line No."),
            "Global Dimension 1 Code","Global Dimension 2 Code");
    end;
}

