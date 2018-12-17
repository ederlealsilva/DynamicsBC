page 2148 "O365 Address"
{
    // version NAVW113.00

    Caption = 'Address';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Standard Address";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(Address;Address)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                ToolTip = 'Specifies the address.';
            }
            field("Address 2";"Address 2")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                ToolTip = 'Specifies additional address information.';
            }
            field("Post Code";"Post Code")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                Lookup = false;
                ToolTip = 'Specifies the postal code.';
            }
            field(City;City)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                Lookup = false;
                ToolTip = 'Specifies the address city.';
            }
            field(County;County)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                ToolTip = 'Specifies the address county.';
            }
            field("Country/Region Code";"Country/Region Code")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Editable = IsPageEditable;
                QuickEntry = false;
                TableRelation = "Country/Region".Code;
                ToolTip = 'Specifies the country/region of the address.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    O365SalesManagement: Codeunit "O365 Sales Management";
                begin
                    "Country/Region Code" := O365SalesManagement.LookupCountryCodePhone;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        RecID: RecordID;
    begin
        RecID := "Related RecordID";
        IsPageEditable := RecID.TableNo <> DATABASE::"Sales Invoice Header";
        if IsPageEditable then
          CurrPage.Caption := EnterAddressPageCaptionLbl
        else
          CurrPage.Caption := AddressPageCaptionLbl;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then begin
          PostCode.UpdateFromStandardAddress(Rec,"Post Code" <> xRec."Post Code");
          SaveToRecord;
        end;
    end;

    var
        PostCode: Record "Post Code";
        IsPageEditable: Boolean;
        EnterAddressPageCaptionLbl: Label 'Enter address';
        AddressPageCaptionLbl: Label 'Address';
}

