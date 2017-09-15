class OverMonsterPawn extends OverPlayer placeable;

var() ParticleSystemComponent QTEParticle;

var bool bRotateLock;

var() String MonsterType;
var() ParticleSystemComponent LockParticle;

var() bool QTEBeatable;
enum QTEButtons{
	buttonW,
	buttonA,
	buttonS,
	buttonD,
	buttonMouseLeft,
	buttonMouseRight,
};
enum QTEBeatType{
	SingleButton,
	DoubleButtonMash,
	DoubleButtonMashOverload,
	SingleMashResistance,
	ButtonSequence,
	AnalogStickShake,
	AnalogStickRotate,
	AnalogRotateAndButton,
};
struct QTEBeatParams{
	var() QTEBeatType QTEBeat;
	var() int StepDuration;
	var() int timeToNextAction;
	var() bool ReachingValueFinishes;
	var() float fStartValue;
	var() float fEndValue;
	var() float fValueStep;
	var() float fValueDecreasePerSec;
	var() bool bRandomizeButtons;
	var() array<QTEButtons> Buttons;
	var() float EnemyRegenOnFailure;
	var() int QTEHealthTreshold;
	var() ParticleSystem QTEParticle;
	var() float QTEParticleZOffset;
	var() float QTEParticleScale;
	var() String QTETriggerButton;
	var() float MinDistanceToTriggerQTE;
	//var() AnimSet QTEStunAnimation;

	structdefaultproperties{
		QTEBeat = 0
		StepDuration = 5.0
		timeToNextAction = 2.0
		ReachingValueFinishes = true
		fStartValue = 0.0
		fEndValue = 1.0
		fValueStep = 1.0
		fValueDecreasePerSec = 0.0
		EnemyRegenOnFailure = 10
		bRandomizeButtons = false
		QTEHealthTreshold = 10
		QTEParticle = ParticleSystem'OverlordsPackage.Particles.ActivateQTE'
		QTEParticleZOffset = 20
		QTEParticleScale = 2
		QTETriggerButton = "D"
		MinDistanceToTriggerQTE = 100.0
		//QTEStunAnimation = 
  }
};
var() QTEBeatParams QTEParams;

simulated event PostBeginPlay(){
	local vector translateVect;
	local float collisionRadius, collisionHeight;
	super.PostBeginPlay();
	SpawnDefaultController();

	GetBoundingCylinder(collisionRadius,collisionHeight);
	translateVect.Z = collisionHeight+QTEParams.QTEParticleZOffset;
	QTEParticle.SetTranslation(translateVect);
	QTEParticle.SetScale(QTEParams.QTEParticleScale);
	QTEParticle.SetTemplate(QTEParams.QTEParticle);

	`log("A Monster Has Been Spawned!");
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser){
	local QTEBeatType tempEnum;

	//if (OverPlayerController(Controller).bDefending) super.TakeDamage(DamageAmount/3,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	//else super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if(QTEBeatable && Health<=HealthMax/QTEParams.QTEHealthTreshold){
		if(QTEParams.bRandomizeButtons) tempEnum = QTEBeatType(Rand(QTEBeatType.EnumCount));
		else tempEnum = QTEBeatType(QTEParams.QTEBeat);
		OverMonsterController(Controller).tempEnum = int(tempEnum);

		QTEParticle.ActivateSystem();

		SetTimer(QTEParams.StepDuration,false,'DeactivateQTEPart');
	}

	if(Health<=0){
		Died(EventInstigator,DamageType,HitLocation); 
		`log(self@"Died");
	}
}

event Tick(float DeltaTime){
	local UDKPawn player;
	local vector distance;
	local rotator rotation;

	super.Tick(DeltaTime);
	if(bRotateLock && (OverGameInfo(WorldInfo.Game).PlayerController.Pawn != none)){
		player = UDKPawn(OverGameInfo(WorldInfo.Game).PlayerController.Pawn);
		distance = player.location - self.location;
		rotation = Rotator(distance);
		rotation.Pitch = 16384;
		LockParticle.SetRotation(rotation);
	}
}

function DeactivateQTEPart(){
	QTEParticle.DeactivateSystem();
	Health += QTEParams.EnemyRegenOnFailure;
}

function SetLockRotation(bool check){
	bRotateLock = check;
}

DefaultProperties
{
	ControllerClass = class 'Overlords.OverMonsterController'

	bRotateLock = false;

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1                   //Particle used for an Undefined Amount of Time
        bAutoActivate=false
		Scale=5
	End Object
	QTEParticle=ParticleSystemComponent1
	Components.Add(ParticleSystemComponent1)

	MonsterType = "Minion"

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent2                    //Particle used for an Undefined Amount of Time
        Template=ParticleSystem'OverlordsPackage.Particles.DefendParticle'
        bAutoActivate=false
		Translation=(X=0,Y=0,Z=0)
		Rotation=(Yaw=0,Roll=0,Pitch=16384)
		Scale=0.25
	End Object
	LockParticle=ParticleSystemComponent2
	Components.Add(ParticleSystemComponent2)
}
