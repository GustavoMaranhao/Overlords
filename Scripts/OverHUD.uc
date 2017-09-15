class OverHUD extends HUD;

var QTEHUD HUDMovie;
var bool debugWeapon;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	HudMovie = new class'QTEHUD'; 
	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init();

	HudMovie.playerHUD = self;
}

function drawThicker(vector v1, vector v2, color c, int PosFromCenter) {
	local vector start;
	local vector end;
	
	//so we can modify
	start = v1;
	end = v2;
	
	start.x += PosFromCenter;
	end.x += PosFromCenter;
	draw3DLine(start, end, c);
	
	start.y += PosFromCenter;
	end.y += PosFromCenter;
	draw3DLine(start, end, c);
	
	start.z += PosFromCenter;
	end.z += PosFromCenter;
	draw3DLine(start, end, c);
	
	start.x -= PosFromCenter*2;
	end.x -= PosFromCenter*2;
	draw3DLine(start, end, c);
	
	start.y -= PosFromCenter*2;
	end.y -= PosFromCenter*2;
	draw3DLine(start, end, c);
	
	start.z -= PosFromCenter*2;
	end.z -= PosFromCenter*2;
	draw3DLine(start, end, c);
}
function drawThickLine(vector v1, vector v2, color c, int thickness) {
	local int thickIncrement;
	
	//center of line
	draw3DLine(v1, v2, c);
	
	//draw surrounding layers of thickness from center
	for (thickIncrement = 1; thickIncrement <= thickness; thickIncrement++ ) {
		drawThicker(v1, v2, c, thickIncrement);
	}
}

event PostRender(){
	local vector traceStart, traceEnd;
	super.PostRender();
	if(debugWeapon){
		SkeletalMeshComponent(OverPlayerController(PlayerOwner).Pawn.Weapon.Mesh).GetSocketWorldLocationAndRotation(OverWeaponBase(OverPlayerController(PlayerOwner).Pawn.Weapon).Trace_Start, traceStart);
		SkeletalMeshComponent(OverPlayerController(PlayerOwner).Pawn.Weapon.Mesh).GetSocketWorldLocationAndRotation(OverWeaponBase(OverPlayerController(PlayerOwner).Pawn.Weapon).Trace_End, traceEnd);
		drawThickLine(traceStart,traceEnd,MakeColor(255,0,0,255),3);
	}
}

//GFXTimers
function Failure(){
	local array<int> outputsToActivate;

	outputsToActivate.length = 0;
	outputsToActivate.addItem(6);
	TriggerRemoteKismetEvent(name("QTE Sequence Outputs"), HUDMovie.targetPawn, playerOwner, outputsToActivate);
	HUDMovie.flashFailure();
	HUDMovie.unlockQTEs();
	HUDMovie.bAlreadyAdded = true;

	HUDMovie.targetPawn.QTEParticle.DeactivateSystem();
	HUDMovie.targetPawn.Health += HUDMovie.targetPawn.QTEParams.EnemyRegenOnFailure;
	OverMonsterController(HUDMovie.targetPawn.Controller).bOnlyOnce = false;
	HUDMovie.targetPawn = none;
}

function Success(){
	local array<int> outputsToActivate;

	outputsToActivate.length = 0;
	outputsToActivate.addItem(5);
	TriggerRemoteKismetEvent(name("QTE Sequence Outputs"), HUDMovie.targetPawn, playerOwner, outputsToActivate);
	HUDMovie.flashSuccess();
	HUDMovie.unlockQTEs();

	HUDMovie.targetPawn.DefendParticle.DeactivateSystem();
	HUDMovie.targetPawn.QTEParticle.DeactivateSystem();
	HUDMovie.targetPawn.KilledBy(PlayerOwner.Pawn);
	HUDMovie.targetPawn = none;
}

function disableQTActive(){
	PlayerOwner.SetCinematicMode(false, false, false, true, true, false);
	HUDMovie.QTActive = false;	
}

function TriggerRemoteKismetEvent(name EventName, actor originator, actor instigator, array<int> outputs){
	local array<SequenceObject> AllSeqEvents;
	local Sequence GameSeq;
	local int i;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None){
		// reset the game sequence
		GameSeq.Reset();

		// find any Level Reset events that exist
		GameSeq.FindSeqObjectsByClass(class'SeqEvent_RemoteEvent', true, AllSeqEvents);

		// activate them
		for (i = 0; i < AllSeqEvents.Length; i++){
			if(SeqEvent_RemoteEvent(AllSeqEvents[i]).EventName == EventName)
				SeqEvent_RemoteEvent(AllSeqEvents[i]).CheckActivate(originator, instigator, false, outputs);
		}
	}
}

DefaultProperties
{
	debugWeapon = false
}
