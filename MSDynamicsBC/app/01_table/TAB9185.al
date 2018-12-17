table 9185 "Generic Chart Captions Buffer"
{
    // version NAVW113.00

    Caption = 'Generic Chart Captions Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(2;"Language Code";Code[10])
        {
            Caption = 'Language Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = Language.Code;
        }
        field(3;Caption;Text[250])
        {
            Caption = 'Caption';
            DataClassification = SystemMetadata;
        }
        field(4;"Language Name";Text[50])
        {
            CalcFormula = Lookup(Language.Name WHERE (Code=FIELD("Language Code")));
            Caption = 'Language Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code","Language Code")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetCaption(CodeIn: Code[10];LanguageCode: Code[10]): Text[250]
    begin
        if Get(CodeIn,LanguageCode) then
          exit(Caption)
    end;

    [Scope('Personalization')]
    procedure SetCaption(CodeIn: Code[10];LanguageCode: Code[10];CaptionIn: Text[250])
    begin
        if Get(CodeIn,LanguageCode) then begin
          Caption := CaptionIn;
          Modify
        end else begin
          Code := CodeIn;
          "Language Code" := LanguageCode;
          Caption := CaptionIn;
          Insert
        end
    end;
}

