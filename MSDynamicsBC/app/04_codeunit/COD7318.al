codeunit 7318 "Bin Create"
{
    // version NAVW19.00

    TableNo = "Bin Creation Worksheet Line";

    trigger OnRun()
    begin
        BinCreateLine.Copy(Rec);
        Code;
        Rec := BinCreateLine;
    end;

    var
        BinCreateLine: Record "Bin Creation Worksheet Line";
        Bin: Record Bin;
        Text000: Label 'Do you want to create the bin?';
        Text001: Label 'There is nothing to create.';
        Location: Record Location;

    local procedure "Code"()
    begin
        if not Confirm(Text000,false) then
          exit;

        if BinCreateLine.Find('-') then begin
          repeat
            BinCreate(BinCreateLine);
          until BinCreateLine.Next = 0;
          BinCreateLine.DeleteAll;
        end else
          Message(Text001);
    end;

    local procedure BinCreate(BinCreateLine2: Record "Bin Creation Worksheet Line")
    begin
        with BinCreateLine2 do begin
          if EmptyLine then
            exit;

          Bin.Init;
          Bin.Code := "Bin Code";
          Bin.Description := Description;
          Bin."Location Code" := "Location Code";
          Bin.Dedicated := Dedicated;
          GetLocation("Location Code");
          if Location."Directed Put-away and Pick" then begin
            Bin."Zone Code" := "Zone Code";
            Bin."Bin Type Code" := "Bin Type Code";
            Bin."Warehouse Class Code" := "Warehouse Class Code";
            Bin."Block Movement" := "Block Movement";
            Bin."Special Equipment Code" := "Special Equipment Code";
            Bin."Bin Ranking" := "Bin Ranking";
            Bin."Maximum Cubage" := "Maximum Cubage";
            Bin."Maximum Weight" := "Maximum Weight";
            Bin."Cross-Dock Bin" := "Cross-Dock Bin";
          end;
          Bin.Insert(true);
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode <> Location.Code then
          Location.Get(LocationCode);
    end;
}

