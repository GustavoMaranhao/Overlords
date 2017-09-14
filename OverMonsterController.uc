class OverMonsterController extends GameAIController;

var int tempEnum;
var bool bOnlyOnce;

function int HasPlayerInput(String toSearch){
	local array<String> pInput;
	local OverPlayerController PlayerCont;
	
	PlayerCont = OverGameInfo(WorldInfo.Game).PlayerController;
	pInput.Length=0;

	if(PlayerCont.playerInput.buttonW) pInput.AddItem("W");
	if(PlayerCont.playerInput.buttonA) pInput.AddItem("A");
	if(PlayerCont.playerInput.buttonS) pInput.AddItem("S");
	if(PlayerCont.playerInput.buttonD) pInput.AddItem("D");
	if(PlayerCont.playerInput.buttonMouseLeft) pInput.AddItem("MouseLeft");
	if(PlayerCont.playerInput.buttonMouseRight) pInput.AddItem("MouseRight");

	return pInput.Find(toSearch);
}

event Tick(float DeltaTime){
	local float DistanceToPlayer;
	local array<int> outputsToActivate;

	super.Tick(DeltaTime);
	if(OverMonsterPawn(Pawn).QTEBeatable){
		DistanceToPlayer = Vsize(Pawn.Location - OverGameInfo(WorldInfo.Game).PlayerController.Pawn.Location);

		if(Pawn.Health<=Pawn.HealthMax/OverMonsterPawn(Pawn).QTEParams.QTEHealthTreshold && 
			DistanceToPlayer<=OverMonsterPawn(Pawn).QTEParams.MinDistanceToTriggerQTE && 
			HasPlayerInput(OverMonsterPawn(Pawn).QTEParams.QTETriggerButton)!=-1 && !bOnlyOnce){
				bOnlyOnce = true;
				//SetTimer(10.0,false,'OnlyOnceTimer');

				outputsToActivate.length = 0;
				outputsToActivate.addItem(0);
				OverGameInfo(WorldInfo.Game).PlayerController.HUDVar.TriggerRemoteKismetEvent(name("QTE Sequence Outputs"), OverMonsterPawn(Pawn), OverGameInfo(WorldInfo.Game).PlayerController, outputsToActivate);

				OverMonsterPawn(Pawn).ClearTimer('DeactivateQTEPart');	

				OverGameInfo(WorldInfo.Game).PlayerController.SetCinematicMode(true, false, false, true, true, false);

				if(!IsTimerActive('StartQTE')) SetTimer(OverMonsterPawn(Pawn).QTEParams.timeToNextAction,false,'StartQTE');
		}
	}
}

function StartQTE(){
	local QTEHUD PlayerGfx;

	PlayerGfx = OverGameInfo(WorldInfo.Game).PlayerController.HUDVar.HUDmovie;
	PlayerGfx.bShouldCheckInput = false;
	if(PlayerGfx!=none){					
		switch(tempEnum){
		case 0:
			PlayerGfx.QTE_SimpleButton(OverMonsterPawn(Pawn));
			break;
		case 1:
			PlayerGfx.QTE_DoubleButtonMash(OverMonsterPawn(Pawn));
			break;
		case 2:
			PlayerGfx.QTE_DoubleButtonMashOverload(OverMonsterPawn(Pawn));
			break;
		case 3:
			PlayerGfx.QTE_SingleMashResistance(OverMonsterPawn(Pawn));
			break;
		case 4:
			PlayerGfx.QTE_ButtonSequence(OverMonsterPawn(Pawn));
			break;
		case 5:
			PlayerGfx.QTE_AnalogStickShake(OverMonsterPawn(Pawn));
			break;
		case 6:
			PlayerGfx.QTE_AnalogStickRotate(OverMonsterPawn(Pawn));
			break;
		case 7:
			PlayerGfx.QTE_AnalogRotateAndButton(OverMonsterPawn(Pawn));
			break;
		}
	}
}

DefaultProperties
{
	bOnlyOnce = false
}
