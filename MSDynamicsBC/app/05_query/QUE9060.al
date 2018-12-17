query 9060 "Count Sales Orders"
{
    // version NAVW110.0

    Caption = 'Count Sales Orders';

    elements
    {
        dataitem(Sales_Header;"Sales Header")
        {
            DataItemTableFilter = "Document Type"=CONST(Order);
            filter(Status;Status)
            {
            }
            filter(Shipped;Shipped)
            {
            }
            filter(Completely_Shipped;"Completely Shipped")
            {
            }
            filter(Responsibility_Center;"Responsibility Center")
            {
            }
            filter(Ship;Ship)
            {
            }
            filter(Invoice;Invoice)
            {
            }
            filter(Date_Filter;"Date Filter")
            {
            }
            filter(Late_Order_Shipping;"Late Order Shipping")
            {
            }
            filter(Shipment_Date;"Shipment Date")
            {
            }
            column(Count_Orders)
            {
                Method = Count;
            }
        }
    }
}

