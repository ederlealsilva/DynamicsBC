codeunit 1636 "Office Contact Handler"
{
    // version NAVW113.00

    TableNo = "Office Add-in Context";

    trigger OnRun()
    begin
        if Email <> '' then
          RedirectContact(Rec)
        else
          ShowContactSelection(Rec);
    end;

    var
        SelectAContactTxt: Label 'Select a contact';

    local procedure RedirectContact(TempOfficeAddinContext: Record "Office Add-in Context" temporary)
    var
        Contact: Record Contact;
        TempOfficeContactAssociations: Record "Office Contact Associations" temporary;
    begin
        if TempOfficeAddinContext."Contact No." <> '' then
          Contact.SetRange("No.",TempOfficeAddinContext."Contact No.")
        else
          Contact.SetRange("Search E-Mail",UpperCase(TempOfficeAddinContext.Email));

        if not Contact.FindFirst then
          PAGE.Run(PAGE::"Office New Contact Dlg")
        else
          with TempOfficeContactAssociations do begin
            CollectMultipleContacts(Contact,TempOfficeContactAssociations,TempOfficeAddinContext);
            if (Count > 1) and (TempOfficeAddinContext.Command <> '') then
              SetRange("Associated Table",TempOfficeAddinContext.CommandType);

            if Count = 1 then begin
              FindFirst;
              ShowCustomerVendor(TempOfficeAddinContext,Contact,"Associated Table",GetContactNo);
              exit;
            end;

            SetRange(Type,Type::"Contact Person");
            if Count = 1 then begin
              FindFirst;
              ShowCustomerVendor(TempOfficeAddinContext,Contact,"Associated Table",GetContactNo);
              exit;
            end;

            SetRange(Type);
            if Count > 1 then
              PAGE.Run(PAGE::"Office Contact Associations",TempOfficeContactAssociations);
          end;
    end;

    [Scope('Personalization')]
    procedure ShowContactSelection(OfficeAddinContext: Record "Office Add-in Context")
    var
        Contact: Record Contact;
        ContactList: Page "Contact List";
    begin
        FilterContacts(OfficeAddinContext,Contact);
        ContactList.SetTableView(Contact);
        ContactList.LookupMode(true);
        ContactList.Caption(SelectAContactTxt);
        if ContactList.LookupMode then;
        ContactList.Run;
    end;

    [Scope('Personalization')]
    procedure ShowCustomerVendor(TempOfficeAddinContext: Record "Office Add-in Context" temporary;Contact: Record Contact;AssociatedTable: Option;LinkNo: Code[20])
    var
        OfficeContactAssociations: Record "Office Contact Associations";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        case AssociatedTable of
          OfficeContactAssociations."Associated Table"::Customer:
            begin
              if TempOfficeAddinContext.CommandType = OfficeContactAssociations."Associated Table"::Vendor then
                PAGE.Run(PAGE::"Office No Vendor Dlg",Contact)
              else
                if Customer.Get(LinkNo) then
                  RedirectCustomer(Customer,TempOfficeAddinContext);
              exit;
            end;
          OfficeContactAssociations."Associated Table"::Vendor:
            begin
              if TempOfficeAddinContext.CommandType = OfficeContactAssociations."Associated Table"::Customer then
                PAGE.Run(PAGE::"Office No Customer Dlg",Contact)
              else
                if Vendor.Get(LinkNo) then
                  RedirectVendor(Vendor,TempOfficeAddinContext);
              exit;
            end;
          else
            if TempOfficeAddinContext.CommandType = OfficeContactAssociations."Associated Table"::Customer then begin
              PAGE.Run(PAGE::"Office No Customer Dlg",Contact);
              exit;
            end;
            if TempOfficeAddinContext.CommandType = OfficeContactAssociations."Associated Table"::Vendor then begin
              PAGE.Run(PAGE::"Office No Vendor Dlg",Contact);
              exit;
            end;
        end;

        Contact.Get(LinkNo);
        PAGE.Run(PAGE::"Contact Card",Contact)
    end;

    local procedure CollectMultipleContacts(var Contact: Record Contact;var TempOfficeContactAssociations: Record "Office Contact Associations" temporary;TempOfficeAddinContext: Record "Office Add-in Context" temporary)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        FilterContactBusinessRelations(Contact,ContactBusinessRelation);
        if TempOfficeAddinContext.IsAppointment then
          ContactBusinessRelation.SetRange("Link to Table",ContactBusinessRelation."Link to Table"::Customer);
        if ContactBusinessRelation.FindSet then
          repeat
            ContactBusinessRelation.CalcFields("Business Relation Description");
            with TempOfficeContactAssociations do
              if not Get(ContactBusinessRelation."Contact No.",Contact.Type,ContactBusinessRelation."Link to Table") then begin
                Clear(TempOfficeContactAssociations);
                Init;
                TransferFields(ContactBusinessRelation);
                "Contact Name" := Contact.Name;
                Type := Contact.Type;
                "Business Relation Description" := ContactBusinessRelation."Business Relation Description";
                if ContactBusinessRelation."Link to Table" = TempOfficeAddinContext.CommandType then begin
                  "Contact No." := Contact."No.";
                  "Associated Table" := TempOfficeAddinContext.CommandType;
                end;
                Insert;
              end;
          until ContactBusinessRelation.Next = 0
        else
          if Contact.FindSet then
            repeat
              CreateUnlinkedContactAssociation(TempOfficeContactAssociations,Contact);
            until Contact.Next = 0;
    end;

    local procedure CreateUnlinkedContactAssociation(var TempOfficeContactAssociations: Record "Office Contact Associations" temporary;Contact: Record Contact)
    begin
        Clear(TempOfficeContactAssociations);
        with TempOfficeContactAssociations do begin
          SetRange("No.",Contact."Company No.");
          if FindFirst and (Type = Contact.Type::Company) then
            Delete;

          if IsEmpty then begin
            Init;
            "No." := Contact."Company No.";
            if "No." = '' then
              "No." := Contact."No.";
            "Contact No." := Contact."No.";
            "Contact Name" := Contact.Name;
            Type := Contact.Type;
            Insert;
          end;

          SetRange("No.");
        end;
    end;

    local procedure FilterContactBusinessRelations(var Contact: Record Contact;var ContactBusinessRelation: Record "Contact Business Relation")
    var
        ContactFilter: Text;
    begin
        // Filter contact business relations based on the specified list of contacts
        if Contact.FindSet then
          repeat
            if StrPos(ContactFilter,Contact."No.") = 0 then
              ContactFilter += Contact."No." + '|';
            if (StrPos(ContactFilter,Contact."Company No.") = 0) and (Contact."Company No." <> '') then
              ContactFilter += Contact."Company No." + '|';
          until Contact.Next = 0;

        ContactBusinessRelation.SetFilter("Contact No.",DelChr(ContactFilter,'>','|'));
    end;

    local procedure FilterContacts(OfficeAddinContext: Record "Office Add-in Context";var Contact: Record Contact)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        with ContactBusinessRelation do
          case true of
            OfficeAddinContext.Command <> '':
              SetRange("Link to Table",OfficeAddinContext.CommandType);
            OfficeAddinContext.IsAppointment:
              SetRange("Link to Table","Link to Table"::Customer);
            else
              exit;
          end;

        if ContactBusinessRelation.FindSet then begin
          Contact.FilterGroup(-1);
          repeat
            Contact.SetRange("Company No.",ContactBusinessRelation."Contact No.");
            Contact.SetRange("No.",ContactBusinessRelation."Contact No.");
            if Contact.FindSet then
              repeat
                Contact.Mark(true);
              until Contact.Next = 0;
          until ContactBusinessRelation.Next = 0;

          Contact.MarkedOnly(true);
        end;
    end;

    local procedure RedirectCustomer(Customer: Record Customer;var TempOfficeAddinContext: Record "Office Add-in Context" temporary)
    var
        OfficeDocumentHandler: Codeunit "Office Document Handler";
    begin
        PAGE.Run(PAGE::"Customer Card",Customer);
        OfficeDocumentHandler.HandleSalesCommand(Customer,TempOfficeAddinContext);
    end;

    local procedure RedirectVendor(Vendor: Record Vendor;var TempOfficeAddinContext: Record "Office Add-in Context" temporary)
    var
        OfficeDocumentHandler: Codeunit "Office Document Handler";
    begin
        PAGE.Run(PAGE::"Vendor Card",Vendor);
        OfficeDocumentHandler.HandlePurchaseCommand(Vendor,TempOfficeAddinContext);
    end;

    [EventSubscriber(ObjectType::Page, 5052, 'OnClosePageEvent', '', false, false)]
    local procedure OnContactSelected(var Rec: Record Contact)
    var
        TempOfficeAddinContext: Record "Office Add-in Context" temporary;
        OfficeMgt: Codeunit "Office Management";
    begin
        if OfficeMgt.IsAvailable then begin
          OfficeMgt.GetContext(TempOfficeAddinContext);
          if TempOfficeAddinContext.Email = '' then begin
            TempOfficeAddinContext.Name := Rec.Name;
            TempOfficeAddinContext.Email := Rec."E-Mail";
            TempOfficeAddinContext."Contact No." := Rec."No.";
            OfficeMgt.AddRecipient(Rec.Name,Rec."E-Mail");
            OfficeMgt.InitializeContext(TempOfficeAddinContext);
          end;
        end;
    end;
}

