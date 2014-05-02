/*
 * Author: KoffeinFlummi
 *
 * Start carrying the given unit.
 * 
 * Argument:
 * 0: Unit to be carried (Object)
 * 
 * Return value:
 * none
 */

#define CARRYINGMOVE "AcinPercMstpSnonWnonDnon"
#define CARRIEDMOVE "AinjPfalMstpSnonWnonDf_carried_dead"

_this spawn {
  _unit = _this select 0;
  
  _unit setVariable ["AGM_Treatable", false, true];
  player setVariable ["AGM_Carrying", _unit, false];
  player setVariable ["AGM_CanTreat", false, false];

  player playMoveNow CARRYINGMOVE;
  waitUntil {animationState player == CARRYINGMOVE};

  _unit attachTo [player, [0.1, -0.1, -1.25], "LeftShoulder"];
  [-2, {
    _this setDir 15;
  }, _unit] call CBA_fnc_globalExecute;
  _unit setPos (getPos _unit); // force Arma to synchronize direction

  [-2, {
    _this switchMove CARRIEDMOVE;
  }, _unit] call CBA_fnc_globalExecute;

  waitUntil {sleep 1; vehicle player != player or isNull (player getVariable "AGM_Carrying") or damage player >= 1 or damage _unit >= 1};
  if (isNull (player getVariable "AGM_Carrying")) exitWith {};

  detach _unit;
  [-2, {
    _this switchMove "Unconscious";
  }, _unit] call CBA_fnc_globalExecute;

  if (vehicle player == player) then {
    [-2, {
      _this switchMove "";
    }, player] call CBA_fnc_globalExecute;
  };

  _unit setVariable ["AGM_Treatable", true, true];

  [-2, {
    if (local _this) then {
      0 spawn {
        _this enableSimulation true;
        sleep 3.8;
        _this enableSimulation false;
      };
    };
  }, _unit] call CBA_fnc_globalExecute;
  
};