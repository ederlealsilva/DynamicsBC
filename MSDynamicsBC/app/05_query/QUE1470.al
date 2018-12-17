query 1470 "Product Videos with Category"
{
    // version NAVW111.00

    Caption = 'Product Videos with Category';
    OrderBy = Ascending(Category);

    elements
    {
        dataitem(Product_Video_Category;"Product Video Category")
        {
            column(Category;Category)
            {
            }
            column(Alternate_Title;"Alternate Title")
            {
            }
            column(Assisted_Setup_ID;"Assisted Setup ID")
            {
            }
            dataitem(Assisted_Setup;"Assisted Setup")
            {
                DataItemLink = "Page ID"=Product_Video_Category."Assisted Setup ID";
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Video Url"=FILTER(<>'');
                column(Name;Name)
                {
                }
                column(Video_Url;"Video Url")
                {
                }
            }
        }
    }
}

