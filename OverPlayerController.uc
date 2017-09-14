class OverPlayerController extends GamePlayerController;

var OverHUD HUDVar;

var string weaponType;
var bool bAttackCooldown;
var bool bDefending, bShouldAttack;
var array<Name> ScytheAnims;
var array<Name> SwordAnims;
var array<Name> BowAnims;

var bool bShiftToggle;

var OverMonsterPawn targetedEnemy;


struct buttonsBeingPressed
{
  var bool buttonW;
  var bool buttonA;
  var bool buttonS;
  var bool buttonD;
  var bool buttonMouseLeft;
  var bool buttonMouseRight;

  structdefaultproperties{
	  buttonW = false
	  buttonA = false
	  buttonS = false
	  buttonD = false
	  buttonMouseLeft = false
	  buttonMouseRight = false
  }
};
var buttonsBeingPressed playerInput;

simulated event PostBeginPlay(){
	super.PostBeginPlay();	
	SetTimer(0.5,false);
}

function Timer(){
	local int i;
	for(i=0;i<OverPlayer(Pawn).ScytheAnims.length;i++)
		ScytheAnims[i] = OverPlayer(Pawn).ScytheAnims[i].name;
	for(i=0;i<OverPlayer(Pawn).SwordAnims.length;i++)
		SwordAnims[i] = OverPlayer(Pawn).SwordAnims[i].name;
	for(i=0;i<OverPlayer(Pawn).BowAnims.length;i++)
		BowAnims[i] = OverPlayer(Pawn).BowAnims[i].name;

	HUDVar = OverHUD(myHUD);
}

function OverMonsterPawn GetNearestEnemy(){
	local OverMonsterPawn target;
	local array<OverMonsterPawn> enemies;
	local int i;

	enemies = OverGameInfo(WorldInfo.Game).enemies;
	for(i=0; i<enemies.Length; i++){
		if((WorldInfo.TimeSeconds-enemies[i].LastRenderTime < 0.09) && (VSize(Pawn.Location - enemies[i].Location) <= OverPlayer(Pawn).LockDistance))
			if(target != none){
				if(VSize(Pawn.Location - enemies[i].Location) < VSize(Pawn.Location - target.Location))
					target = enemies[i];
			}
			else
				target = enemies[i];
	}
	`log("Shift"@target);
	return target;
}

function OverMonsterPawn GetNextEnemy(){
	local OverMonsterPawn target;
	local array<OverMonsterPawn> enemies;
	local int i;

	enemies = OverGameInfo(WorldInfo.Game).enemies;
	for(i=0; i<enemies.Length; i++){
		if((WorldInfo.TimeSeconds-enemies[i].LastRenderTime < 0.09)  && (VSize(Pawn.Location - enemies[i].Location) <= OverPlayer(Pawn).LockDistance))
			if(targetedEnemy != none){
				if(enemies.Find(targetedEnemy) < i){
					target = enemies[i];
					return target;
				}
				if((i == enemies.Length - 1)  && (target == none)){
					i = 0;
					target = enemies[i];
				}
			}
			else{
				target = GetNearestEnemy();
				return target;
			}
	}
	`log("Control"@target);
	return target;
}

exec function LeftShiftPressed(){	
	`log("Shift Pressed");
	bShiftToggle = !bShiftToggle;
	if(bShiftToggle)
		targetedEnemy = GetNearestEnemy();
	if(targetedEnemy != none){
		if(bShiftToggle){
			`log("Activated");
			targetedEnemy.LockParticle.ActivateSystem();
			targetedEnemy.SetLockRotation(true);
			OverCamera(PlayerCamera).ChangeCameraStyle("Lock");			
		} else {
			`log("Deactivated");
			targetedEnemy.LockParticle.DeactivateSystem();
			targetedEnemy.SetLockRotation(false);
			OverCamera(PlayerCamera).ChangeCameraStyle("FreeCam");
			targetedEnemy = none;
		}
	}
}

exec function LeftShiftReleased(){
	`log("Shift Released");
}

exec function LeftControlPressed(){
	`log("Control Pressed");
}

exec function LeftControlReleased(){
	`log("Changing Enemy");
	bShiftToggle = true;
	if(targetedEnemy != none)
		targetedEnemy.LockParticle.DeactivateSystem();
	targetedEnemy = GetNextEnemy();
	if(targetedEnemy != none){
		`log("Changed");
		targetedEnemy.LockParticle.ActivateSystem();
		targetedEnemy.SetLockRotation(true);
		OverCamera(PlayerCamera).ChangeCameraStyle("Lock");	
	}
}

exec function LeftMousePressed(){
   if(!bDefending && !HUDVar.HUDmovie.QTActive) bShouldAttack = true;
   playerInput.buttonMouseLeft = true;
   HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function LeftMouseReleased(){
   bShouldAttack = false;
   playerInput.buttonMouseLeft = false;
   HUDVar.HUDmovie.bShouldCheckInput = false;
}

exec function RightMousePressed(){
  if(!HUDVar.HUDmovie.QTActive) Defend();
  playerInput.buttonMouseRight = true;
  HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function RightMouseReleased(){
  if(!HUDVar.HUDmovie.QTActive) Undefend();
  playerInput.buttonMouseRight = false;
  HUDVar.HUDmovie.bShouldCheckInput = false;
}

exec function MiddleMouseScrollUp(){
  NextWeapon();
}

exec function MiddleMouseScrollDown(){
  PrevWeapon();
}

exec function WPressed(){
	playerInput.buttonW = true;
	HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function WReleased(){
	playerInput.buttonW = false;
	HUDVar.HUDmovie.bShouldCheckInput = false;
}

exec function APressed(){
	playerInput.buttonA = true;
	HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function AReleased(){
	playerInput.buttonA = false;
	HUDVar.HUDmovie.bShouldCheckInput = false;
}

exec function SPressed(){
	playerInput.buttonS = true;
	HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function SReleased(){
	playerInput.buttonS = false;
	HUDVar.HUDmovie.bShouldCheckInput = false;
}

exec function DPressed(){
	playerInput.buttonD = true;
	HUDVar.HUDmovie.bShouldCheckInput = true;
}

exec function DReleased(){
	playerInput.buttonD = false;
	HUDVar.HUDmovie.bShouldCheckInput = false;
}


event PlayerTick(float DeltaTime){
	super.PlayerTick(DeltaTime);
	if(bShouldAttack && !bAttackCooldown) Attack(weaponType);
	if(HUDVar != none) HUDVar.HudMovie.TickGfx(DeltaTime);
	if(bShiftToggle && targetedEnemy!=none) Pawn.setRotation(Rotator(targetedEnemy.Location - Pawn.Location));
}

function Attack(string attackType){
	local name AnimSequence;
	local int index;
	local float Duration;
	if (!bAttackCooldown){
		bAttackCooldown = true;
		switch(attackType){
			case "Scythe":	index = Rand(ScytheAnims.length); AnimSequence = ScytheAnims[index]; break;
			case "Sword":	index = Rand(SwordAnims.length); AnimSequence = SwordAnims[index]; break;//AnimSequence = OverPlayer(Pawn).Mesh.FindAnimSequence(SwordAnims[0]); break;//'SwordAnim'; break;
			case "Bow":	index = Rand(BowAnims.length); AnimSequence = BowAnims[index]; break;
			default: index = Rand(ScytheAnims.length); AnimSequence = ScytheAnims[index]; break;
		}
		Pawn.StartFire(0);
		Duration = OverPlayer(Pawn).TopHalfAnimSlot.PlayCustomAnim(AnimSequence, 1.0, , , false) + 0.2; 
		SetTimer(Duration,false,'AttackCooldown');
	}
}

function AttackCooldown(){
	bAttackCooldown = false;
	Pawn.StopFire(0);
}

function Defend(){
	bDefending = true;
	OverPlayer(Pawn).Mesh.GlobalAnimRateScale = 0.5;
	OverPlayer(Pawn).TopHalfAnimSlot.PlayCustomAnim('humana_fireball', 2.0, , -1.f, false, , , 0.6);
	OverPlayer(Pawn).GroundSpeed = OverPlayer(Pawn).GroundSpeed/2;
	OverPlayer(Pawn).DefendParticle.ActivateSystem();
}

function Undefend(){
	bDefending = false;
	OverPlayer(Pawn).Mesh.GlobalAnimRateScale = 1;
	OverPlayer(Pawn).TopHalfAnimSlot.PlayCustomAnim('humana_fireball', 1.5, , , false, , 0.6, );
	OverPlayer(Pawn).GroundSpeed = OverPlayer(Pawn).Default.GroundSpeed;
	OverPlayer(Pawn).DefendParticle.DeactivateSystem();
}

function Tool(){

}

DefaultProperties
{
	CameraClass=class'Overlords.OverCamera'
	weaponType = "Sword"
	bDefending = false
	bShouldAttack = false
	bShiftToggle = false
}
