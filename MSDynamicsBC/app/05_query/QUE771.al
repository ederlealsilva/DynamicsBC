query 771 "Analysis Column Header Count"
{
    // version NAVW17.00

    Caption = 'Analysis Column Header Count';

    elements
    {
        dataitem(Analysis_Column;"Analysis Column")
        {
            column(Analysis_Area;"Analysis Area")
            {
            }
            column(Analysis_Column_Template;"Analysis Column Template")
            {
            }
            column(Column_Header;"Column Header")
            {
            }
            column(Count_)
            {
                ColumnFilter = Count_=FILTER(>1);
                Method = Count;
            }
        }
    }
}

