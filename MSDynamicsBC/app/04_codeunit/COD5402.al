codeunit 5402 "Unit of Measure Management"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        Text001: Label 'Quantity per unit of measure must be defined.';

    [Scope('Personalization')]
    procedure GetQtyPerUnitOfMeasure(Item: Record Item;UnitOfMeasureCode: Code[10]): Decimal
    begin
        Item.TestField("No.");
        if UnitOfMeasureCode in [Item."Base Unit of Measure",''] then
          exit(1);
        if (Item."No." <> ItemUnitOfMeasure."Item No.") or
           (UnitOfMeasureCode <> ItemUnitOfMeasure.Code)
        then
          ItemUnitOfMeasure.Get(Item."No.",UnitOfMeasureCode);
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    [Scope('Personalization')]
    procedure GetResQtyPerUnitOfMeasure(Resource: Record Resource;UnitOfMeasureCode: Code[10]): Decimal
    begin
        Resource.TestField("No.");
        if UnitOfMeasureCode in [Resource."Base Unit of Measure",''] then
          exit(1);
        if (Resource."No." <> ResourceUnitOfMeasure."Resource No.") or
           (UnitOfMeasureCode <> ResourceUnitOfMeasure.Code)
        then
          ResourceUnitOfMeasure.Get(Resource."No.",UnitOfMeasureCode);
        ResourceUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(ResourceUnitOfMeasure."Qty. per Unit of Measure");
    end;

    [Scope('Personalization')]
    procedure CalcBaseQty(Qty: Decimal;QtyPerUOM: Decimal): Decimal
    begin
        if QtyPerUOM = 0 then
          Error(Text001);

        exit(RoundQty(Qty * QtyPerUOM));
    end;

    [Scope('Personalization')]
    procedure CalcQtyFromBase(QtyBase: Decimal;QtyPerUOM: Decimal): Decimal
    begin
        if QtyPerUOM = 0 then
          Error(Text001);

        exit(RoundQty(QtyBase / QtyPerUOM));
    end;

    [Scope('Personalization')]
    procedure RoundQty(Qty: Decimal): Decimal
    begin
        exit(Round(Qty,QtyRndPrecision));
    end;

    [Scope('Personalization')]
    procedure QtyRndPrecision(): Decimal
    begin
        exit(0.00001);
    end;
}

