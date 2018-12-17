table 880 "Excel Template Storage"
{
    // version NAVW113.00

    Caption = 'Excel Template Storage';
    ReplicateData = false;

    fields
    {
        field(1;TemplateName;Text[250])
        {
            Caption = 'TemplateName';
        }
        field(2;TemplateFile;BLOB)
        {
            Caption = 'TemplateFile';
        }
        field(3;TemplateFileName;Text[250])
        {
            Caption = 'TemplateFileName';
        }
    }

    keys
    {
        key(Key1;TemplateName)
        {
        }
    }

    fieldgroups
    {
    }
}

