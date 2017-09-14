class QTEOutputs extends SeqEvent_RemoteEvent;

var() string EnemyType;

event Activated(){
	if(OverMonsterPawn(Originator)!=none)
		EnemyType = OverMonsterPawn(Originator).MonsterType;
	Instigator = GamePlayerController(Instigator).Pawn;
}

DefaultProperties
{
  EventName="QTE Sequence Outputs"

  ObjName="QTE Sequence Outputs"
  ObjCategory="Quick Time Events"
   
  bPlayerOnly=false
  MaxTriggerCount=0

  OutputLinks(0)=(LinkDesc="Started")
  OutputLinks(1)=(LinkDesc="First Success")
  OutputLinks(2)=(LinkDesc="Second Success")
  OutputLinks(3)=(LinkDesc="Third Success")
  OutputLinks(4)=(LinkDesc="Fourth Success")
  OutputLinks(5)=(LinkDesc="Completed")
  OutputLinks(6)=(LinkDesc="Failure")

  VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator/PlayerPawn",bWriteable=true,PropertyName=Instigator)
  VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Originator",bWriteable=true,PropertyName=Originator)
  VariableLinks(2)=(ExpectedType=class'SeqVar_String',LinkDesc="Enemy Type",bWriteable=true,PropertyName=EnemyType)
}
