tableextension 50100 CompanyInformationTableExtLT extends "Company Information"
{
    fields
    {
        field(50100; "Root Container"; Text[250])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Blob Storage Containers";
        }
        field(50101; "Success Container"; Text[250])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Blob Storage Containers";
        }
        field(50102; "Failed Container"; Text[250])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Blob Storage Containers";
        }
        field(50103; "Import Consol. No. Series"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
