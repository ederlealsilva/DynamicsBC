table 2155 "O365 Payment Instructions"
{
    // version NAVW113.00

    Caption = 'O365 Payment Instructions';

    fields
    {
        field(1;Id;Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(5;Name;Text[20])
        {
            Caption = 'Name';
        }
        field(6;"Payment Instructions";Text[250])
        {
            Caption = 'Payment Instruction';
        }
        field(7;"Payment Instructions Blob";BLOB)
        {
            Caption = 'Payment Instructions Blob';
        }
        field(8;Default;Boolean)
        {
            Caption = 'Default';

            trigger OnValidate()
            var
                O365PaymentInstructions: Record "O365 Payment Instructions";
            begin
                if Default then begin
                  O365PaymentInstructions.SetFilter(Id,'<>%1',Id);
                  O365PaymentInstructions.ModifyAll(Default,false,false);
                end;
            end;
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DocumentDescription: Text;
    begin
        if Default then
          Error(CannotDeleteDefaultErr);

        DocumentDescription := FindDraftsUsingInstructions;
        if DocumentDescription <> '' then
          Error(PaymentIsUsedErr,FindDraftsUsingInstructions);

        if GuiAllowed then
          if not Confirm(DoYouWantToDeleteQst) then
            Error('');

        DeleteTranslationsForRecord;
    end;

    var
        DocumentDescriptionTxt: Label '%1 %2', Comment='%1=Document description (e.g. Invoice, Estimate,...); %2=Document Number';
        PaymentIsUsedErr: Label 'You cannot delete the Payment Instructions because at least one invoice (%1) is using them.', Comment='%1: Document type and number';
        CannotDeleteDefaultErr: Label 'You cannot delete the default Payment Instructions.';
        LanguageManagement: Codeunit LanguageManagement;
        DoYouWantToDeleteQst: Label 'Are you sure you want to delete the payment instructions?';

    procedure GetPaymentInstructions(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CalcFields("Payment Instructions Blob");
        if not "Payment Instructions Blob".HasValue then
          exit("Payment Instructions");
        CR[1] := 10;
        TempBlob.Blob := "Payment Instructions Blob";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;

    procedure SetPaymentInstructions(NewInstructions: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Payment Instructions Blob");
        "Payment Instructions" := CopyStr(NewInstructions,1,MaxStrLen("Payment Instructions"));
        if StrLen(NewInstructions) <= MaxStrLen("Payment Instructions") then
          exit; // No need to store anything in the blob
        if NewInstructions = '' then
          exit;
        TempBlob.WriteAsText(NewInstructions,TEXTENCODING::Windows);
        "Payment Instructions Blob" := TempBlob.Blob;
        Modify;
    end;

    procedure FindDraftsUsingInstructions() DocumentDescription: Text
    var
        SalesHeader: Record "Sales Header";
    begin
        DocumentDescription := '';
        SalesHeader.SetRange("Payment Instructions Id",Id);

        if SalesHeader.FindFirst then
          DocumentDescription := StrSubstNo(DocumentDescriptionTxt,SalesHeader.GetDocTypeTxt,SalesHeader."No.");
    end;

    procedure GetNameInCurrentLanguage(): Text[20]
    var
        O365PaymentInstrTransl: Record "O365 Payment Instr. Transl.";
        LanguageCode: Code[10];
    begin
        LanguageCode := LanguageManagement.GetLanguageCodeFromLanguageID(GlobalLanguage);

        if not O365PaymentInstrTransl.Get(Id,LanguageCode) then
          exit(Name);

        exit(O365PaymentInstrTransl."Transl. Name");
    end;

    procedure GetPaymentInstructionsInCurrentLanguage(): Text
    var
        O365PaymentInstrTransl: Record "O365 Payment Instr. Transl.";
        LanguageCode: Code[10];
    begin
        LanguageCode := LanguageManagement.GetLanguageCodeFromLanguageID(GlobalLanguage);

        if not O365PaymentInstrTransl.Get(Id,LanguageCode) then
          exit(GetPaymentInstructions);

        exit(O365PaymentInstrTransl.GetTransPaymentInstructions);
    end;

    procedure DeleteTranslationsForRecord()
    var
        O365PaymentInstrTransl: Record "O365 Payment Instr. Transl.";
    begin
        O365PaymentInstrTransl.SetRange(Id,Id);
        O365PaymentInstrTransl.DeleteAll(true);
    end;

    procedure CopyInstructionsInCurrentLanguageToBlob(var TempBlob: Record TempBlob)
    begin
        TempBlob.WriteAsText(GetPaymentInstructionsInCurrentLanguage,TEXTENCODING::Windows);
    end;
}

