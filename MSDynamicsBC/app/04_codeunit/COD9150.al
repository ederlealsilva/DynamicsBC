codeunit 9150 "My Records Update Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateMyCustomerAfterCustomerModify(var Rec: Record Customer;var xRec: Record Customer;RunTrigger: Boolean)
    var
        MyCustomer: Record "My Customer";
    begin
        if Rec.IsTemporary then
          exit;

        MyCustomer.SetRange("Customer No.",Rec."No.");

        // xRec will be = Rec if called from code
        MyCustomer.SetFilter(Name,'<>%1',Rec.Name);
        MyCustomer.ModifyAll(Name,Rec.Name);
        MyCustomer.SetRange(Name);

        MyCustomer.SetFilter("Phone No.",'<>%1',Rec."Phone No.");
        MyCustomer.ModifyAll("Phone No.",Rec."Phone No.");
    end;

    [EventSubscriber(ObjectType::Table, 23, 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateMyVendorAfterVendorModify(var Rec: Record Vendor;var xRec: Record Vendor;RunTrigger: Boolean)
    var
        MyVendor: Record "My Vendor";
    begin
        if Rec.IsTemporary then
          exit;

        MyVendor.SetRange("Vendor No.",Rec."No.");

        MyVendor.SetFilter(Name,'<>%1',Rec.Name);
        MyVendor.ModifyAll(Name,Rec.Name);
        MyVendor.SetRange(Name);

        MyVendor.SetFilter("Phone No.",'<>%1',Rec."Phone No.");
        MyVendor.ModifyAll("Phone No.",Rec."Phone No.");
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateMyItemAfterItemModify(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    var
        MyItem: Record "My Item";
    begin
        if Rec.IsTemporary then
          exit;

        MyItem.SetRange("Item No.",Rec."No.");

        MyItem.SetFilter(Description,'<>%1',Rec.Description);
        MyItem.ModifyAll(Description,Rec.Description);
        MyItem.SetRange(Description);

        MyItem.SetFilter("Unit Price",'<>%1',Rec."Unit Price");
        MyItem.ModifyAll("Unit Price",Rec."Unit Price");
    end;

    [EventSubscriber(ObjectType::Table, 15, 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateMyAccountAfterAcountModify(var Rec: Record "G/L Account";var xRec: Record "G/L Account";RunTrigger: Boolean)
    var
        MyAccount: Record "My Account";
    begin
        if Rec.IsTemporary then
          exit;

        MyAccount.SetRange("Account No.",Rec."No.");

        MyAccount.SetFilter(Name,'<>%1',Rec.Name);
        MyAccount.ModifyAll(Name,Rec.Name);
    end;
}

