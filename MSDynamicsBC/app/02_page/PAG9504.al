page 9504 "Debugger Code Viewer"
{
    // version NAVW113.00

    Caption = 'Debugger Code Viewer';
    Editable = false;
    LinksAllowed = false;
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Debugger Call Stack";

    layout
    {
        area(content)
        {
            usercontrol(CodeViewer;"Microsoft.Dynamics.Nav.Client.CodeViewer")
            {
                ApplicationArea = All;

                trigger AddWatch(variablePath: Text)
                begin
                    DebuggerManagement.AddWatch(variablePath,true);
                end;

                trigger GetVariableValue(variableName: Text;leftContext: Text)
                begin
                    ShowTooltip(variableName,leftContext);
                end;

                trigger SetBreakpoint(lineNo: Integer)
                begin
                    UpdateBreakpoint(lineNo);
                    CurrPage.Update;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        ObjectMetadata: Record "Object Metadata";
        NAVAppObjectMetadata: Record "NAV App Object Metadata";
        NAVApp: Record "NAV App";
        AllObj: Record AllObj;
        CodeStream: InStream;
        BreakpointCollection: DotNet BreakpointCollection;
        "Code": BigText;
        NewObjectType: Option;
        NewObjectId: Integer;
        NewCallstackId: Integer;
        IsBreakAfterRunningCodeAction: Boolean;
        NewLineNo: Integer;
    begin
        NewObjectType := "Object Type";
        NewObjectId := "Object ID";
        NewCallstackId := ID;
        NewLineNo := "Line No.";

        if DebuggerManagement.IsBreakAfterCodeTrackingAction then begin
          DebuggerManagement.ResetActionState;
          BreakpointCollection := CurrBreakpointCollection;
        end else
          GetBreakpointCollection(NewObjectType,NewObjectId,BreakpointCollection);

        IsBreakAfterRunningCodeAction := DebuggerManagement.IsBreakAfterRunningCodeAction;

        if (ObjType <> NewObjectType) or
           (ObjectId <> NewObjectId) or (CallstackId <> NewCallstackId) or IsBreakAfterRunningCodeAction
        then begin
          CallstackId := NewCallstackId;

          if (ObjType <> NewObjectType) or (ObjectId <> NewObjectId) or IsBreakAfterRunningCodeAction then begin
            ObjType := NewObjectType;
            ObjectId := NewObjectId;

            ObjectMetadata.Init;
            NAVAppObjectMetadata.Init;

            if AllObj.Get(ObjType,ObjectId) and not IsNullGuid(AllObj."App Package ID") then begin
              if NAVAppObjectMetadata.Get(AllObj."App Package ID",ObjType,ObjectId) then
                if NAVApp.Get(AllObj."App Package ID") then
                  if NAVApp."Show My Code" then begin
                    NAVAppObjectMetadata.CalcFields("User AL Code");
                    NAVAppObjectMetadata."User AL Code".CreateInStream(CodeStream,TEXTENCODING::UTF8);
                    Code.Read(CodeStream);

                    LineNo := NewLineNo;
                    CurrBreakpointCollection := BreakpointCollection;
                    CurrPage.CodeViewer.LoadCode(Code,NewLineNo,BreakpointCollection,(NewCallstackId = 1));
                  end else begin
                    NewLineNo := 0;
                    LineNo := NewLineNo;
                    CurrBreakpointCollection := BreakpointCollection;
                    CurrPage.CodeViewer.LoadCode('',NewLineNo,BreakpointCollection,(NewCallstackId = 1));
                  end
            end else
              if ObjectMetadata.Get(ObjType,ObjectId) then begin
                ObjectMetadata.CalcFields("User AL Code");
                ObjectMetadata."User AL Code".CreateInStream(CodeStream,TEXTENCODING::UTF8);
                Code.Read(CodeStream);

                LineNo := NewLineNo;
                CurrBreakpointCollection := BreakpointCollection;
                CurrPage.CodeViewer.LoadCode(Code,NewLineNo,BreakpointCollection,(NewCallstackId = 1));
              end;

            if IsBreakAfterRunningCodeAction then
              DebuggerManagement.ResetActionState;

            // Refresh to update data caption on debugger page

            DebuggerManagement.RefreshDebuggerTaskPage;

            exit;
          end;
        end;

        if NewLineNo <> LineNo then begin
          LineNo := NewLineNo;
          if IsNull(BreakpointCollection) then
            if IsNull(CurrBreakpointCollection) then
              CurrPage.CodeViewer.UpdateLine(NewLineNo,(NewCallstackId = 1))
            else
              CurrPage.CodeViewer.Update(NewLineNo,BreakpointCollection,(NewCallstackId = 1))
          else
            if not BreakpointCollection.Equals(CurrBreakpointCollection) then
              CurrPage.CodeViewer.Update(NewLineNo,BreakpointCollection,(NewCallstackId = 1))
            else
              CurrPage.CodeViewer.UpdateLine(NewLineNo,(NewCallstackId = 1))
        end else
          PaintBreakpoints(BreakpointCollection);

        CurrBreakpointCollection := BreakpointCollection;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        CallStack: Record "Debugger Call Stack";
        BreakpointCollection: DotNet BreakpointCollection;
    begin
        if CallStack.IsEmpty then begin
          GetBreakpointCollection(ObjType,ObjectId,BreakpointCollection);
          PaintBreakpoints(BreakpointCollection);
          CurrBreakpointCollection := BreakpointCollection;

          if LineNo <> -1 then begin
            // Set line to -1 to remove the current line marker
            LineNo := -1;
            CurrPage.CodeViewer.UpdateLine(LineNo,true);
          end;
          exit(false);
        end;

        exit(Find(Which));
    end;

    var
        DebuggerManagement: Codeunit "Debugger Management";
        CurrBreakpointCollection: DotNet BreakpointCollection;
        Variables: DotNet VariableCollection;
        ObjType: Option;
        ObjectId: Integer;
        CallstackId: Integer;
        Text001: Label 'The name ''%1'' does not exist in the current context.', Comment='Shown when hovering over text in the code viewer that has no context as a variable.';
        LineNo: Integer;

    local procedure GetBreakpointCollection(ObjType: Integer;ObjectId: Integer;var BreakpointCollection: DotNet BreakpointCollection)
    var
        DebuggerBreakpoint: Record "Debugger Breakpoint";
    begin
        with DebuggerBreakpoint do begin
          SetRange("Object Type",ObjType);
          SetRange("Object ID",ObjectId);

          if FindSet then begin
            BreakpointCollection := BreakpointCollection.BreakpointCollection;
            repeat
              BreakpointCollection.AddBreakpoint("Line No.",Enabled,Condition);
            until Next = 0;
          end;
        end;
    end;

    procedure ToggleBreakpoint()
    begin
        UpdateBreakpoint(CurrPage.CodeViewer.CaretLine);
    end;

    local procedure UpdateBreakpoint(LineNo: Integer)
    var
        DebuggerBreakpoint: Record "Debugger Breakpoint";
    begin
        if (ObjType = 0) or (ObjectId = 0) then
          exit;

        with DebuggerBreakpoint do begin
          Init;
          "Object Type" := ObjType;
          "Object ID" := ObjectId;
          "Line No." := LineNo;
          if not Insert(true) then begin
            SetRange("Object Type",ObjType);
            SetRange("Object ID",ObjectId);
            SetRange("Line No.","Line No.");
            SetRange("Column No.","Column No.");

            if FindFirst then begin
              if Enabled then
                Delete(true)
              else begin
                Enabled := true;
                Modify(true);
              end
            end
          end
        end
    end;

    procedure SetBreakpointCondition()
    var
        DebuggerBreakpoint: Record "Debugger Breakpoint";
        DebuggerBreakpointTemp: Record "Debugger Breakpoint" temporary;
        IsNewRecord: Boolean;
    begin
        if (ObjType = 0) or (ObjectId = 0) then
          exit;

        with DebuggerBreakpoint do begin
          Init;
          "Object Type" := ObjType;
          "Object ID" := ObjectId;
          "Line No." := CurrPage.CodeViewer.CaretLine;

          IsNewRecord := Insert(true);

          SetRange("Object Type",ObjType);
          SetRange("Object ID",ObjectId);
          SetRange("Line No.","Line No.");
          SetRange("Column No.","Column No.");

          if FindFirst then begin
            Commit;
            DebuggerBreakpointTemp := DebuggerBreakpoint;
            DebuggerBreakpointTemp.Insert;
            if PAGE.RunModal(PAGE::"Debugger Breakpoint Condition",DebuggerBreakpointTemp) = ACTION::LookupOK then begin
              Condition := DebuggerBreakpointTemp.Condition;
              Modify(true)
            end else
              if IsNewRecord then
                Delete(true);
          end
        end
    end;

    local procedure GetVariables(VariableName: Text;LeftContext: Text;var Variables: DotNet VariableCollection) Found: Boolean
    var
        VariablesRec: Record "Debugger Variable";
        VariableValue: Text[1024];
        VariableWithoutQoutes: Text[1024];
        Global: Boolean;
    begin
        Found := true;
        VariableWithoutQoutes := DebuggerManagement.RemoveQuotes(VariableName);
        Variables := Variables.VariableCollection;

        with VariablesRec do begin
          SetRange("Call Stack ID",CallstackId);
          SetRange(Name,VariableWithoutQoutes);

          if FindSet then
            repeat
              if DebuggerManagement.ShouldBeInTooltip(Path,LeftContext) then begin
                if Value = '' then
                  VariableValue := '<...>'
                else
                  VariableValue := Value;

                Global := StrPos(Path,'"<Globals>"') = 1;

                Variables.AddVariable(VariableName,Path,VariableValue,Type,Global);
              end
            until Next = 0;
        end;

        Found := Variables.Count <> 0;
    end;

    local procedure ShowTooltip(VariableName: Text;LeftContext: Text)
    var
        CallStack: Record "Debugger Call Stack";
        TooltipText: Text;
    begin
        if CallStack.IsEmpty then
          CurrPage.CodeViewer.ShowTooltip('')
        else
          if GetVariables(VariableName,LeftContext,Variables) then
            CurrPage.CodeViewer.ShowTooltip(Variables)
          else begin
            TooltipText := StrSubstNo(Text001,VariableName);
            CurrPage.CodeViewer.ShowTooltip(TooltipText);
          end;
    end;

    local procedure PaintBreakpoints(var BreakpointCollection: DotNet BreakpointCollection)
    begin
        if IsNull(BreakpointCollection) then begin
          if not IsNull(CurrBreakpointCollection) then
            CurrPage.CodeViewer.UpdateBreakpoints(BreakpointCollection);
        end else
          if not BreakpointCollection.Equals(CurrBreakpointCollection) then
            CurrPage.CodeViewer.UpdateBreakpoints(BreakpointCollection);
    end;
}

