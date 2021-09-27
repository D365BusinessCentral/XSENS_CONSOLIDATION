pageextension 50101 CompanyInfoPageExtLT extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group("Azure Blob Storage")
            {
                field("Root Container"; Rec."Root Container")
                {
                    ApplicationArea = All;
                }
                field("Success Container"; Rec."Success Container")
                {
                    ApplicationArea = All;
                }
                field("Failed Container"; Rec."Failed Container")
                {
                    ApplicationArea = All;
                }
                field("Import Consol. No. Series"; Rec."Import Consol. No. Series")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
