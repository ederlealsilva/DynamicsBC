codeunit 5200 "Employee/Resource Update"
{
    // version NAVW111.00

    Permissions = TableData Resource=rimd;

    trigger OnRun()
    begin
    end;

    var
        Res: Record Resource;

    [Scope('Personalization')]
    procedure HumanResToRes(OldEmployee: Record Employee;Employee: Record Employee)
    begin
        if (Employee."Resource No." <> '') and
           ((OldEmployee."Resource No." <> Employee."Resource No.") or
            (OldEmployee."Job Title" <> Employee."Job Title") or
            (OldEmployee."First Name" <> Employee."First Name") or
            (OldEmployee."Last Name" <> Employee."Last Name") or
            (OldEmployee.Address <> Employee.Address) or
            (OldEmployee."Address 2" <> Employee."Address 2") or
            (OldEmployee."Post Code" <> Employee."Post Code") or
            (OldEmployee."Social Security No." <> Employee."Social Security No.") or
            (OldEmployee."Employment Date" <> Employee."Employment Date"))
        then
          ResUpdate(Employee)
        else
          exit;
    end;

    [Scope('Personalization')]
    procedure ResUpdate(Employee: Record Employee)
    begin
        Res.Get(Employee."Resource No.");
        Res."Job Title" := Employee."Job Title";
        Res.Name := CopyStr(Employee.FullName,1,30);
        Res.Address := Employee.Address;
        Res."Address 2" := Employee."Address 2";
        Res.Validate("Post Code",Employee."Post Code");
        Res."Social Security No." := Employee."Social Security No.";
        Res."Employment Date" := Employee."Employment Date";
        Res.Modify(true)
    end;
}

