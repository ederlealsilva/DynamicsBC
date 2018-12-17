query 773 "Users in User Groups"
{
    // version NAVW110.0

    Caption = 'Users in User Groups';

    elements
    {
        dataitem(User_Group_Member;"User Group Member")
        {
            column(UserGroupCode;"User Group Code")
            {
            }
            column(NumberOfUsers)
            {
                Method = Count;
            }
        }
    }
}

