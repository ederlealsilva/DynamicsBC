query 774 "Users in Plans"
{
    // version NAVW113.00

    Caption = 'Users in Plans';

    elements
    {
        dataitem(User_Plan;"User Plan")
        {
            SqlJoinType = InnerJoin;
            column(User_Security_ID;"User Security ID")
            {
            }
            column(User_Name;"User Name")
            {
            }
            column(Plan_ID;"Plan ID")
            {
            }
            column(Plan_Name;"Plan Name")
            {
            }
            dataitem(User;User)
            {
                DataItemLink = "User Security ID"=User_Plan."User Security ID";
                column(User_State;State)
                {
                    Caption = 'User State';
                }
            }
        }
    }
}

