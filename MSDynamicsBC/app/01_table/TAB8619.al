table 8619 "Config. Template Line"
{
    // version NAVW113.00

    Caption = 'Config. Template Line';
    ReplicateData = false;

    fields
    {
        field(1;"Data Template Code";Code[10])
        {
            Caption = 'Data Template Code';
            Editable = false;
            TableRelation = "Config. Template Header";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            InitValue = "Field";
            OptionCaption = 'Field,Template,Related Template';
            OptionMembers = "Field",Template,"Related Template";

            trigger OnValidate()
            begin
                case Type of
                  Type::Field:
                    Clear("Template Code");
                  Type::Template:
                    begin
                      Clear("Field Name");
                      Clear("Field ID");
                    end;
                end;
            end;
        }
        field(4;"Field ID";Integer)
        {
            Caption = 'Field ID';
            TableRelation = IF (Type=CONST(Field)) Field."No." WHERE (TableNo=FIELD("Table ID"),
                                                                      Class=CONST(Normal));
        }
        field(5;"Field Name";Text[30])
        {
            Caption = 'Field Name';
            Editable = false;
            FieldClass = Normal;

            trigger OnLookup()
            begin
                SelectFieldName;
            end;

            trigger OnValidate()
            var
                ConfigTemplateLine: Record "Config. Template Line";
                ConfigTemplateMgt: Codeunit "Config. Template Management";
            begin
                ConfigTemplateLine.SetRange("Data Template Code","Data Template Code");
                ConfigTemplateLine.SetRange("Field Name","Field Name");
                if not ConfigTemplateLine.IsEmpty then
                  Error(Text004,"Field Name");

                ConfigTemplateMgt.TestHierarchy(Rec);
            end;
        }
        field(6;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(7;"Table Name";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Name" WHERE ("Object Type"=FILTER(Table),
                                                                        "Object ID"=FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8;"Template Code";Code[10])
        {
            Caption = 'Template Code';
            TableRelation = "Config. Template Header";

            trigger OnLookup()
            var
                ConfigTemplateHeader: Record "Config. Template Header";
                ConfigTemplateList: Page "Config. Template List";
            begin
                if Type = Type::Field then
                  exit;

                ConfigTemplateHeader.Get("Data Template Code");
                if ConfigTemplateHeader."Table ID" = 0 then
                  exit;

                ConfigTemplateHeader.SetRange("Table ID",ConfigTemplateHeader."Table ID");
                ConfigTemplateList.SetTableView(ConfigTemplateHeader);
                ConfigTemplateList.LookupMode := true;
                ConfigTemplateList.Editable := false;
                if ConfigTemplateList.RunModal = ACTION::LookupOK then begin
                  ConfigTemplateList.GetRecord(ConfigTemplateHeader);
                  if ConfigTemplateHeader.Code = "Data Template Code" then
                    Error(Text000);
                  CalcFields("Template Description");
                  Validate("Template Code",ConfigTemplateHeader.Code);
                end;
            end;

            trigger OnValidate()
            var
                ConfigTemplateHeader: Record "Config. Template Header";
                ConfigTemplateHeader2: Record "Config. Template Header";
                ConfigTemplateLine: Record "Config. Template Line";
                ConfigTemplateMgt: Codeunit "Config. Template Management";
            begin
                if Type = Type::Field then
                  Error(Text005);

                if "Template Code" = "Data Template Code" then
                  Error(Text000);

                if ConfigTemplateHeader.Get("Template Code") then
                  if ConfigTemplateHeader2.Get("Data Template Code") then
                    if ConfigTemplateHeader."Table ID" <> ConfigTemplateHeader2."Table ID" then
                      Error(Text002,ConfigTemplateHeader.Code,ConfigTemplateHeader2."Table ID");

                ConfigTemplateMgt.TestHierarchy(Rec);

                ConfigTemplateLine.SetRange("Data Template Code","Data Template Code");
                ConfigTemplateLine.SetRange("Template Code","Template Code");
                if not ConfigTemplateLine.IsEmpty then
                  Error(Text003,"Template Code");
            end;
        }
        field(9;"Template Description";Text[50])
        {
            CalcFormula = Lookup("Config. Template Header".Description WHERE (Code=FIELD("Data Template Code")));
            Caption = 'Template Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10;Mandatory;Boolean)
        {
            Caption = 'Mandatory';

            trigger OnValidate()
            begin
                if Mandatory and ("Default Value" = '') then
                  Error(EmptyDefaultValueErr);
            end;
        }
        field(11;Reference;Text[250])
        {
            Caption = 'Reference';
            ExtendedDatatype = URL;
        }
        field(12;"Default Value";Text[250])
        {
            Caption = 'Default Value';

            trigger OnValidate()
            var
                TempConfigPackageField: Record "Config. Package Field" temporary;
                ConfigPackageManagement: Codeunit "Config. Package Management";
                ConfigValidateMgt: Codeunit "Config. Validate Management";
                RecRef: RecordRef;
                FieldRef: FieldRef;
                ValidationError: Text[250];
            begin
                if Mandatory and ("Default Value" = '') then
                  Error(EmptyDefaultValueErr);
                if ("Field ID" <> 0) and ("Default Value" <> '') then begin
                  RecRef.Open("Table ID",true);
                  FieldRef := RecRef.Field("Field ID");
                  ValidationError := ConfigValidateMgt.EvaluateValue(FieldRef,"Default Value",false);
                  if ValidationError <> '' then
                    Error(ValidationError);

                  "Default Value" := Format(FieldRef.Value);

                  if not "Skip Relation Check" then begin
                    ConfigPackageManagement.GetFieldsOrder(RecRef,'',TempConfigPackageField);
                    ConfigValidateMgt.TransferRecordDefaultValues("Data Template Code",RecRef,"Field ID","Default Value");
                    ValidationError := ConfigValidateMgt.ValidateFieldRefRelationAgainstCompanyData(FieldRef,TempConfigPackageField);

                    if ValidationError <> '' then
                      Error(ValidationError);
                  end;

                  if GlobalLanguage <> "Language ID" then
                    Validate("Language ID",GlobalLanguage);
                end
            end;
        }
        field(13;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=FILTER(Table),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15;"Skip Relation Check";Boolean)
        {
            Caption = 'Skip Relation Check';
        }
        field(16;"Language ID";Integer)
        {
            Caption = 'Language ID';
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1;"Data Template Code","Line No.")
        {
        }
        key(Key2;"Data Template Code",Type)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        if ConfigTemplateHeader.Get("Data Template Code") then begin
          "Table ID" := ConfigTemplateHeader."Table ID";
          if "Language ID" = 0 then
            "Language ID" := GlobalLanguage;
        end;
    end;

    var
        Text000: Label 'A template cannot relate to itself. Specify a different template.';
        Text002: Label 'The template %1 does not relate to table %2.';
        Text003: Label 'The template %1 is already in this hierarchy.';
        Text004: Label 'Field %1 is already in the template.';
        Text005: Label 'The template line cannot be edited if type is Field.';
        EmptyDefaultValueErr: Label 'The Default Value field must be filled in if the Mandatory check box is selected.';

    procedure SelectFieldName()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        "Field": Record "Field";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        FieldList: Page "Field List";
    begin
        if Type = Type::Template then
          exit;

        ConfigTemplateHeader.Get("Data Template Code");

        if ConfigTemplateHeader."Table ID" = 0 then
          exit;

        Clear(FieldList);
        ConfigPackageMgt.SetFieldFilter(Field,ConfigTemplateHeader."Table ID",0);
        FieldList.SetTableView(Field);
        FieldList.LookupMode := true;
        if FieldList.RunModal = ACTION::LookupOK then begin
          FieldList.GetRecord(Field);
          "Table ID" := Field.TableNo;
          Validate("Field ID",Field."No.");
          Validate("Field Name",Field.FieldName);
        end;
    end;

    procedure GetLine(var ConfigTemplateLine: Record "Config. Template Line";DataTemplateCode: Code[10];FieldID: Integer): Boolean
    begin
        ConfigTemplateLine.SetRange("Data Template Code",DataTemplateCode);
        ConfigTemplateLine.SetRange("Field ID",FieldID);
        if not ConfigTemplateLine.FindFirst then
          exit(false);
        exit(true)
    end;
}

