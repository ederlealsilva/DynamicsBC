table 130406 "CAL Test Coverage Map"
{
    // version NAVW111.00

    Caption = 'CAL Test Coverage Map';
    DrillDownPageID = "CAL Test Coverage Map";
    LookupPageID = "CAL Test Coverage Map";

    fields
    {
        field(1;"Test Codeunit ID";Integer)
        {
            Caption = 'Test Codeunit ID';
        }
        field(2;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query';
            OptionMembers = ,"Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query";
        }
        field(3;"Object ID";Integer)
        {
            Caption = 'Object ID';
        }
        field(4;"Object Name";Text[250])
        {
            CalcFormula = Lookup(Object.Name WHERE (Type=FIELD("Object Type"),
                                                    ID=FIELD("Object ID")));
            Caption = 'Object Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"Hit by Test Codeunits";Integer)
        {
            CalcFormula = Count("CAL Test Coverage Map" WHERE ("Object Type"=FIELD("Object Type"),
                                                               "Object ID"=FIELD("Object ID")));
            Caption = 'Hit by Test Codeunits';
            FieldClass = FlowField;
        }
        field(6;"Test Codeunit Name";Text[250])
        {
            CalcFormula = Lookup(Object.Name WHERE (Type=CONST(Codeunit),
                                                    ID=FIELD("Test Codeunit ID")));
            Caption = 'Test Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Test Codeunit ID","Object Type","Object ID")
        {
        }
        key(Key2;"Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure Show()
    begin
        PAGE.RunModal(PAGE::"CAL Test Coverage Map",Rec);
    end;

    [Scope('Personalization')]
    procedure ShowHitObjects(TestCodeunitID: Integer)
    var
        CALTestCoverageMap: Record "CAL Test Coverage Map";
    begin
        CALTestCoverageMap.SetRange("Test Codeunit ID",TestCodeunitID);
        CALTestCoverageMap.Show;
    end;

    [Scope('Personalization')]
    procedure ShowTestCodeunits()
    var
        CALTestCoverageMap: Record "CAL Test Coverage Map";
    begin
        CALTestCoverageMap.SetRange("Object Type","Object Type");
        CALTestCoverageMap.SetRange("Object ID","Object ID");
        CALTestCoverageMap.Show;
    end;
}

