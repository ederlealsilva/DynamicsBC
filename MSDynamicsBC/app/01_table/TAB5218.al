table 5218 "Human Resources Setup"
{
    // version NAVW111.00

    Caption = 'Human Resources Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Employee Nos.";Code[20])
        {
            Caption = 'Employee Nos.';
            TableRelation = "No. Series";
        }
        field(3;"Base Unit of Measure";Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "Human Resource Unit of Measure";

            trigger OnValidate()
            var
                ResUnitOfMeasure: Record "Resource Unit of Measure";
                EmployeeAbsence: Record "Employee Absence";
            begin
                if "Base Unit of Measure" <> xRec."Base Unit of Measure" then begin
                  if not EmployeeAbsence.IsEmpty then
                    Error(Text001,FieldCaption("Base Unit of Measure"),EmployeeAbsence.TableCaption);
                end;

                HumanResUnitOfMeasure.Get("Base Unit of Measure");
                ResUnitOfMeasure.TestField("Qty. per Unit of Measure",1);
                ResUnitOfMeasure.TestField("Related to Base Unit of Meas.");
            end;
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

    var
        HumanResUnitOfMeasure: Record "Human Resource Unit of Measure";
        Text001: Label 'You cannot change %1 because there are %2.';
}

