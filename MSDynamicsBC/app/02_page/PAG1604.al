page 1604 "Office New Contact Dlg"
{
    // version NAVW111.00

    Caption = 'Do you want to add a new contact?';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = Contact;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control2)
            {
                InstructionalText = 'The sender of this email is not among your contacts.';
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                ShowCaption = false;
                field(NewPersonContact;StrSubstNo(CreatePersonContactLbl,TempOfficeAddinContext.Name))
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies a new person contact.';

                    trigger OnDrillDown()
                    begin
                        CreateNewContact(Type::Person);
                    end;
                }
                field(LinkContact;LinkContactLbl)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies the contacts in your company.';

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(PAGE::"Contact List");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        OfficeMgt: Codeunit "Office Management";
    begin
        OfficeMgt.GetContext(TempOfficeAddinContext);
    end;

    var
        CreatePersonContactLbl: Label 'Add %1 as a contact', Comment='%1 = Contact name';
        LinkContactLbl: Label 'View existing contacts';
        TempOfficeAddinContext: Record "Office Add-in Context" temporary;

    local procedure NotLinked(Contact: Record Contact): Boolean
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        // Person could be linked directly or through Company No.
        ContBusRel.SetFilter("Contact No.",'%1|%2',Contact."No.",Contact."Company No.");
        ContBusRel.SetFilter("No.",'<>''''');
        exit(ContBusRel.IsEmpty);
    end;

    local procedure CreateNewContact(ContactType: Option)
    var
        TempContact: Record Contact temporary;
        Contact: Record Contact;
        NameLength: Integer;
    begin
        Contact.SetRange("Search E-Mail",TempOfficeAddinContext.Email);
        if not Contact.FindFirst then begin
          NameLength := 50;
          if StrPos(TempOfficeAddinContext.Name,' ') = 0 then
            NameLength := 30;
          TempContact.Init;
          TempContact.Validate(Type,ContactType);
          TempContact.Validate(Name,CopyStr(TempOfficeAddinContext.Name,1,NameLength));
          TempContact.Validate("E-Mail",TempOfficeAddinContext.Email);
          TempContact.Insert;
          Commit;
        end;

        if ACTION::LookupOK = PAGE.RunModal(PAGE::"Office Contact Details Dlg",TempContact) then begin
          Clear(Contact);
          Contact.TransferFields(TempContact);
          Contact.Insert(true);
          Commit;
          if NotLinked(Contact) then
            PAGE.Run(PAGE::"Contact Card",Contact)
          else
            Contact.ShowCustVendBank;
          CurrPage.Close;
        end;
    end;
}

