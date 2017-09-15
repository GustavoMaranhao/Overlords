class OverArchetypesManager extends Object placeable;

var() OverPlayer OverPawnTemplate;
var() OverCameraProperties OverCameraTemplate;
var() OverMonsterPawn OverMonsterTemplate;

struct OverWeaponConfig{
  var() OverWeaponScythe ScytheTemplate;
  var() OverWeaponSword SwordTemplate;
  structdefaultproperties{
	ScytheTemplate = OverWeaponScythe'OverlordsPackage.archetypes.OverScythe'
	SwordTemplate = OverWeaponSword'OverlordsPackage.archetypes.OverSword'
  }
};
var() OverWeaponConfig OverWeaponBaseTemplate;


DefaultProperties
{
	OverPawnTemplate = OverPlayer'OverlordsPackage.archetypes.OverPlayerTemplate';
	OverCameraTemplate = OverCameraProperties'OverlordsPackage.archetypes.CameraProperties'
	OverMonsterTemplate = OverMonsterPawn'OverlordsPackage.archetypes.OverMonsterTemplate'
}
