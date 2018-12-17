table 9058 "Warehouse Worker WMS Cue"
{
    // version NAVW111.00

    Caption = 'Warehouse Worker WMS Cue';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Unassigned Picks";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER(Pick),
                                                                   "Assigned User ID"=FILTER(''),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'Unassigned Picks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3;"My Picks";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER(Pick),
                                                                   "Assigned User ID"=FIELD("User ID Filter"),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'My Picks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;"Unassigned Put-aways";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER("Put-away"),
                                                                   "Assigned User ID"=FILTER(''),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'Unassigned Put-aways';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5;"My Put-aways";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER("Put-away"),
                                                                   "Assigned User ID"=FIELD("User ID Filter"),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'My Put-aways';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6;"Unassigned Movements";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER(Movement),
                                                                   "Assigned User ID"=FILTER(''),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'Unassigned Movements';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7;"My Movements";Integer)
        {
            CalcFormula = Count("Warehouse Activity Header" WHERE (Type=FILTER(Movement),
                                                                   "Assigned User ID"=FIELD("User ID Filter"),
                                                                   "Location Code"=FIELD("Location Filter")));
            Caption = 'My Movements';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22;"User ID Filter";Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }
        field(23;"Location Filter";Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
        }
        field(24;"Pending Tasks";Integer)
        {
            CalcFormula = Count("User Task" WHERE ("Assigned To User Name"=FIELD("User ID Filter"),
                                                   "Percent Complete"=FILTER(<>100)));
            Caption = 'Pending Tasks';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

