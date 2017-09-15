class QTEHUD extends GFxMoviePlayer;

var bool QTActive;
var float progress;
var array<string> NextButton;
var OverMonsterPawn targetPawn;
var OverHUD playerHUD;
var bool bAlreadyAdded, bShouldCheckInput;
var int isInStep;
var int tempCounterF, tempCounterS;

function Init( optional LocalPlayer LocPlay ){
	super.Init (LocPlay);

	Start(); 
	Advance(0.f);

	tempCounterF = 0;
	tempCounterS = 0;
}


//General Functions
function TickGfx(float DeltaTime){
	local buttonsBeingPressed playerInput;

	if(QTActive && bShouldCheckInput){
		playerInput = OverPlayerController(GetPC()).playerInput;
		if(NextButton.length>=1){
			tempCounterF++;
			if(playerInput.buttonW && NextButton[0] == "buttonW"){
				activateKismetOutputs();				
			}
			else if(playerInput.buttonA && NextButton[0] == "buttonA"){
				activateKismetOutputs();
			}
			else if(playerInput.buttonS && NextButton[0] == "buttonS"){
				activateKismetOutputs();
			}
			else if(playerInput.buttonD && NextButton[0] == "buttonD"){
				activateKismetOutputs();
			}
			else if(playerInput.buttonMouseLeft && NextButton[0] == "buttonMouseLeft"){
				activateKismetOutputs();
			}
			else if(playerInput.buttonMouseRight && NextButton[0] == "buttonMouseRight"){
				activateKismetOutputs();
			}
			else if((playerInput.buttonW || playerInput.buttonA || playerInput.buttonS ||playerInput.buttonD || playerInput.buttonMouseLeft ||playerInput.buttonMouseRight) && !bAlreadyAdded){
				playerHUD.ClearTimer('Failure'); 
				playerHUD.Failure();
			}
		}
		else if(targetPawn!=none){
			tempCounterS++;
			playerHUD.Success();
		}
	}	
	//`log("F:"@tempCounterF@"S:"@tempCounterS);
}

function activateKismetOutputs(){
	local array<int> outputsToActivate;

	outputsToActivate.length = 0;
	outputsToActivate.addItem(isInStep);
	playerHUD.TriggerRemoteKismetEvent(name("QTE Sequence Outputs"), targetPawn, playerHUD.playerOwner, outputsToActivate);
	isInStep++;

	playerHUD.ClearTimer('Failure'); 
	NextButton.remove(0,1);
	if(NextButton.length>=1) playerHUD.SetTimer(targetPawn.QTEParams.StepDuration, false, 'Failure');
}

function lockQTEs(){
	QTActive = true;
	bAlreadyAdded = false;
	GetPC().SetCinematicMode(true, false, false, true, true, false);
}

function unlockQTEs(){
	//GetPC().SetCinematicMode(false, false, false, true, true, false);
	playerHUD.SetTimer(targetPawn.QTEParams.timeToNextAction, false, 'disableQTActive');
}

//Flash Functions
function flashSuccess(){
	ActionScriptVoid("_root.Success");
}

function flashFailure(){
	ActionScriptVoid("_root.Failure");
}

function flashCleanUp(){
	ActionScriptVoid("_root.CleanUp");
}

function flashUpdateProgress(){
	SetVariableNumber("_root.fProgress", progress);
	ActionScriptVoid("_root.UpdateProgress");
}

function flashResetProgress(){
	progress = 0.00;
	flashUpdateProgress();
}

function flashAddButton(string whichButton){
	ActionScriptObject("_root.AddIndicator");
}

//QTE Initialization
function QTE_SimpleButton(OverMonsterPawn target){
	if(!QTActive && target!=none){
		NextButton.length = 0;
		lockQTEs();
		targetPawn = target;
		isInStep = 1;

		NextButton.addItem(String(GetEnum(Enum'QTEButtons', target.QTEParams.Buttons[0])));
		//flashAddButton(NextButton[0]);
		flashAddButton("Button X Animated");

		playerHUD.SetTimer(target.QTEParams.StepDuration, false, 'Failure');
	}
}

function QTE_DoubleButtonMash(OverMonsterPawn target){

}

function QTE_DoubleButtonMashOverload(OverMonsterPawn target){

}

function QTE_SingleMashResistance(OverMonsterPawn target){

}

function QTE_ButtonSequence(OverMonsterPawn target){

}

function QTE_AnalogStickShake(OverMonsterPawn target){

}

function QTE_AnalogStickRotate(OverMonsterPawn target){

}

function QTE_AnalogRotateAndButton(OverMonsterPawn target){

}

DefaultProperties
{
	MovieInfo=SwfMovie'QTEPlayer.Indicators'
	bDisplayWithHudOff=false
	bIgnoreMouseInput=true
	bAutoPlay=true
	bCaptureInput=false

	QTActive = false
	progress = 0.00
	NextButton = ""
	targetPawn = none
	bAlreadyAdded = false
	bShouldCheckInput = false

	isInStep = 1
}
