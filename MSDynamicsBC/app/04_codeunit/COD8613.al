codeunit 8613 "Config. Try Validate"
{
    // version NAVW111.00


    trigger OnRun()
    begin
        FieldRefToValidate.Validate(Value);
    end;

    var
        FieldRefToValidate: FieldRef;
        Value: Variant;

    [Scope('Personalization')]
    procedure SetValidateParameters(var SourceFieldRef: FieldRef;SourceValue: Variant)
    begin
        FieldRefToValidate := SourceFieldRef;
        Value := SourceValue;
    end;
}

