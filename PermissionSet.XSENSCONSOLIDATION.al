permissionset 50100 XSENS_CONSOLIDATION
{
    Assignable = true;
    Caption = 'XSENS_CONSOLIDATION', MaxLength = 30;
    Permissions =
        table "Blob Storage Account" = X,
        tabledata "Blob Storage Account" = RMID,
        table "Blob Storage Containers" = X,
        tabledata "Blob Storage Containers" = RMID,
        table "Blob Storage Blob Lists" = X,
        tabledata "Blob Storage Blob Lists" = RMID,
        codeunit "Blob Service API" = X,
        codeunit Consolidate_LT = X,
        page "Azure Blob Storage Setup" = X,
        page "BlobStorage Container List" = X,
        page "MME BlobStorage Blob List" = X,
        report "Export Consolidation LT" = X,
        report "Import Consolidation LT" = X;
}
