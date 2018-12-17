table 5800 "Item Charge"
{
    // version NAVW113.00

    Caption = 'Item Charge';
    DataCaptionFields = "No.",Description;
    DrillDownPageID = "Item Charges";
    LookupPageID = "Item Charges";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                  "Search Description" := Description;
            end;
        }
        field(3;"Gen. Prod. Posting Group";Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            var
                GenProdPostingGrp: Record "Gen. Product Posting Group";
            begin
                if xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                  if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp,"Gen. Prod. Posting Group") then
                    Validate("VAT Prod. Posting Group",GenProdPostingGrp."Def. VAT Prod. Posting Group");
            end;
        }
        field(4;"Tax Group Code";Code[20])
        {
            Caption = 'Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(5;"VAT Prod. Posting Group";Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(6;"Search Description";Code[50])
        {
            Caption = 'Search Description';
        }
        field(7;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(8;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Search Description")
        {
        }
        key(Key3;"Gen. Prod. Posting Group")
        {
        }
        key(Key4;Description)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"Item Charge","No.");
    end;

    trigger OnModify()
    begin
        DimMgt.UpdateDefaultDim(
          DATABASE::"Item Charge","No.",
          "Global Dimension 1 Code","Global Dimension 2 Code");
    end;

    trigger OnRename()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        SalesLine.RenameNo(SalesLine.Type::"Charge (Item)",xRec."No.","No.");
        PurchaseLine.RenameNo(PurchaseLine.Type::"Charge (Item)",xRec."No.","No.");
    end;

    var
        DimMgt: Codeunit DimensionManagement;

    [Scope('Personalization')]
    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Item Charge","No.",FieldNumber,ShortcutDimCode);
        Modify;
    end;
}

