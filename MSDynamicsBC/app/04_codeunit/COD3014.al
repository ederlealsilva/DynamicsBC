codeunit 3014 DotNet_StringBuilder
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetStringBuilder: DotNet StringBuilder;

    [Scope('Personalization')]
    procedure InitStringBuilder(Value: Text)
    begin
        DotNetStringBuilder := DotNetStringBuilder.StringBuilder(Value)
    end;

    [Scope('Personalization')]
    procedure Append(Value: Text)
    begin
        DotNetStringBuilder.Append(Value)
    end;

    [Scope('Personalization')]
    procedure AppendFormat(Format: Text;Value: Variant)
    begin
        DotNetStringBuilder.AppendFormat(Format,Value);
    end;

    [Scope('Personalization')]
    procedure ToString(): Text
    begin
        exit(DotNetStringBuilder.ToString())
    end;

    [Scope('Personalization')]
    procedure AppendLine()
    begin
        DotNetStringBuilder.AppendLine
    end;

    procedure GetStringBuilder(var DotNetStringBuilder2: DotNet StringBuilder)
    begin
        DotNetStringBuilder2 := DotNetStringBuilder
    end;

    procedure SetStringBuilder(DotNetStringBuilder2: DotNet StringBuilder)
    begin
        DotNetStringBuilder := DotNetStringBuilder2
    end;
}

