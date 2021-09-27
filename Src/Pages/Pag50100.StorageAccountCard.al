page 50100 "Azure Blob Storage Setup"
{
    PageType = Card;
    SourceTable = "Blob Storage Account";
    Caption = 'Azure Blob Storage Setup';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = All;
                }
                field("Account Url"; Rec."Account Url")
                {
                    ApplicationArea = All;
                }
                field("SaS Token"; Rec."SaS Token")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

}
