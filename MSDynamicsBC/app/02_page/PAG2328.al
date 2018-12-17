page 2328 "BC O365 Email Settings Part"
{
    // version NAVW113.00

    Caption = ' ';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "O365 Email Setup";
    SourceTableView = SORTING(Email)
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            group(Control7)
            {
                InstructionalText = 'You can add email addresses to include your accountant or yourself for all sent invoices and estimates.';
                ShowCaption = false;
            }
            repeater(Group)
            {
                field(Email;Email)
                {
                    ApplicationArea = Basic,Suite,Invoicing;

                    trigger OnValidate()
                    begin
                        if (Email = '') and (xRec.Email <> '') then
                          CurrPage.Update(false);
                    end;
                }
                field(RecipientTypeValue;RecipientTypeValue)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'CC/BCC';

                    trigger OnValidate()
                    begin
                        Validate(RecipientType,RecipientTypeValue);
                    end;
                }
                field(RemoveAddressControl;RemoveLbl)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        if Confirm(RemoveConfirmQst) then
                          if Find then
                            Delete(true);
                    end;
                }
            }
            field(EditDefaultMessages;EditDefaultEmailMessageLbl)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = false;
                ShowCaption = false;
                Style = StandardAccent;
                StyleExpr = TRUE;

                trigger OnDrillDown()
                begin
                    PAGE.RunModal(PAGE::"BC O365 Default Email Messages");
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        RecipientTypeValue := RecipientType;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        RecipientTypeValue := RecipientTypeValue::CC;
    end;

    var
        RecipientTypeValue: Option CC,BCC;
        EditDefaultEmailMessageLbl: Label 'Change default email messages';
        RemoveLbl: Label 'Remove';
        RemoveConfirmQst: Label 'Do you want to remove the address?';
}

