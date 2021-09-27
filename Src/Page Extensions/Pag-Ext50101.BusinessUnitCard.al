pageextension 50102 BusinessUnitCardExtLT extends "Business Unit Card"
{
    actions
    {
        addlast("F&unctions")
        {
            action("Import Consolidation LT")
            {
                ApplicationArea = Suite;
                Caption = 'Import Consolidation';
                Ellipsis = true;
                Image = Import;
                RunObject = Report "Import Consolidation LT";
                ToolTip = 'Run customized consolidation for the file that you import.';
            }
            action("Export Consolidation LT")
            {
                ApplicationArea = Suite;
                Caption = 'Export Consolidation';
                Image = Export;
                RunObject = Report "Export Consolidation LT";
                ToolTip = 'Export customized transactions from the business units to a file.';
            }
        }
    }
}
