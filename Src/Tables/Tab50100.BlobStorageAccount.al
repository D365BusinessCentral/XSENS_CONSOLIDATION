table 50100 "Blob Storage Account"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Account Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }

        field(3; "Account Url"; Text[250])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }

        field(4; "SaS Token"; Text[2000])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}