table 8618 "Config. Template Header"
{
    // version NAVW113.00

    Caption = 'Config. Template Header';
    LookupPageID = "Config. Template List";
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Table ID";Integer)
        {
            Caption = 'Table ID';

            trigger OnLookup()
            begin
                ConfigValidateMgt.LookupTable("Table ID");
                if "Table ID" <> 0 then
                  Validate("Table ID");
            end;

            trigger OnValidate()
            begin
                TestXRec;
                CalcFields("Table Name");
            end;
        }
        field(4;"Table Name";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Name" WHERE ("Object Type"=CONST(Table),
                                                                        "Object ID"=FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"Used In Hierarchy";Boolean)
        {
            CalcFormula = Exist("Config. Template Line" WHERE ("Data Template Code"=FIELD(Code),
                                                               Type=CONST(Template)));
            Caption = 'Used In Hierarchy';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7;Enabled;Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
        }
        field(8;"Instance No. Series";Code[20])
        {
            Caption = 'Instance No. Series';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
    begin
        CalcFields("Used In Hierarchy");
        if not "Used In Hierarchy" then begin
          ConfigTemplateLine.SetRange("Data Template Code",Code);
          ConfigTemplateLine.DeleteAll;
        end;

        ConfigTmplSelectionRules.SetRange("Template Code",Code);
        ConfigTmplSelectionRules.DeleteAll;
    end;

    trigger OnRename()
    begin
        CalcFields("Used In Hierarchy");
        if not "Used In Hierarchy" then begin
          ConfigTemplateLine.SetRange("Data Template Code",xRec.Code);
          ConfigTemplateLine.Find('-');
          repeat
            ConfigTemplateLine.Rename(Code,ConfigTemplateLine."Line No.");
          until ConfigTemplateLine.Next = 0;
        end;
    end;

    var
        Text000: Label 'Template lines that relate to %1 exists. Delete the lines to change the Table ID.';
        ConfigTemplateLine: Record "Config. Template Line";
        Text001: Label 'A new instance %1 has been created in table %2 %3.', Comment='%2 = Table ID, %3 = Table Caption';
        ConfigValidateMgt: Codeunit "Config. Validate Management";

    local procedure TestXRec()
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code",Code);
        if ConfigTemplateLine.FindFirst then
          if xRec."Table ID" <> "Table ID" then
            Error(Text000,xRec."Table ID");
    end;

    [Scope('Personalization')]
    procedure ConfirmNewInstance(var RecRef: RecordRef)
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyFieldCount: Integer;
        MessageString: Text[1024];
    begin
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
          FieldRef := KeyRef.FieldIndex(KeyFieldCount);
          MessageString := MessageString + ' ' + Format(FieldRef.Value);
          MessageString := DelChr(MessageString,'<');
          Message(StrSubstNo(Text001,MessageString,RecRef.Number,RecRef.Caption));
        end;
    end;

    [Scope('Personalization')]
    procedure SetTemplateEnabled(IsEnabled: Boolean)
    begin
        Validate(Enabled,IsEnabled);
        Modify(true);
    end;

    [Scope('Personalization')]
    procedure SetNoSeries(NoSeries: Code[20])
    begin
        Validate("Instance No. Series",NoSeries);
        Modify(true);
    end;
}

