/*
	server/weapons/weapon_elements.qc

	What a wonder weapon leaves behind.

	The category table (shared/weapon_categories.qc) says *which* element a weapon carries;
	this file is the only place that decides what an element *does*, so the tuning of every
	family lives in one block and damage.qc only has to call WeaponElement_Apply() once per
	hit. Arsenal weapons carry WELEM_NONE and never reach any of it.

	Element effects deliberately reuse machinery the game already has instead of growing
	parallel systems:

	  fire   hands the victim to the flamethrower's existing burning state, which
	         Zombie_Think ticks - this file only owns the ignition timeout.
	  cryo   publishes a speed debuff through the generic entity fields speed_penalty /
	         speed_penalty_time; zombie movement honours them (server/ai/ai_core.qc), so
	         movement stays the AI's business and the strength/duration stay ours.
	  shock  arcs a weaker hit into the crowd around the impact.
	  heavy  detonates where it lands.

	Copyright (C) 2021-2024 NZ:P Team

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA.

*/

float(float weapon) WepDef_GetElement;
void(entity inflictor, entity attacker, float damage2, float mindamage, float radius) DamgageExplode;
void(vector org) CallExplosion;

// --- element tuning -------------------------------------------------------------------
#define WELEM_FIRE_BURN_TIME        4.0     // how long a fresh ignition keeps burning

#define WELEM_CRYO_SLOW_SCALE       0.55    // walk speed while chilled
#define WELEM_CRYO_SLOW_TIME        3.0     // how long the chill lasts

#define WELEM_SHOCK_DAMAGE_SCALE    0.5     // share of the hit that arcs onwards
#define WELEM_SHOCK_RADIUS          120     // how far the arc reaches

#define WELEM_HEAVY_DAMAGE_SCALE    0.6     // share of the hit that detonates
#define WELEM_HEAVY_RADIUS          200     // blast radius

// Set while element-generated damage is being applied, so a chain cannot cascade: the
// arc/detonation damage re-enters DamageHandler, which calls back into this file.
float weapon_element_resolving;

// WeaponElement_Splash(inflictor, damage, attacker, radius)
// Applies a scaled hit to everything hostile standing around an impact. The inflictor is
// the body that was hit, because DamgageExplode detonates at its origin; the call is
// suppressed so the damage it causes cannot trigger another element.
void(entity inflictor, float damage, entity attacker, float radius) WeaponElement_Splash =
{
	weapon_element_resolving = true;
	DamgageExplode(inflictor, attacker, damage, 1, radius);
	weapon_element_resolving = false;
};

// WeaponElement_Apply(victim, attacker, damage)
// The single entry point: called by DamageHandler for zombie and dog victims, with the
// weapon that fired the shot still on the attacker.
void(entity victim, entity attacker, float damage) WeaponElement_Apply =
{
	if (weapon_element_resolving || attacker == world || attacker.weapon == 0)
		return;

	float element = WepDef_GetElement(attacker.weapon);

	if (element == WELEM_NONE || damage <= 0)
		return;

	weapon_element_resolving = true;

	if (element == WELEM_FIRE) {
		// The flamethrower's own burn ticks arrive here too, carrying the same owner, so a
		// victim already alight is not re-ignited by them: its fire would never go out.
		if (!victim.onfire || victim.firer != attacker) {
			victim.onfire = true;
			victim.firer = attacker;
			victim.fire_timeout = time + WELEM_FIRE_BURN_TIME;
		}
	}
	else if (element == WELEM_CRYO) {
		victim.speed_penalty = WELEM_CRYO_SLOW_SCALE;
		victim.speed_penalty_time = time + WELEM_CRYO_SLOW_TIME;
	}
	else if (element == WELEM_SHOCK) {
		WeaponElement_Splash(victim, damage * WELEM_SHOCK_DAMAGE_SCALE, attacker,
		                     WELEM_SHOCK_RADIUS);
	}
	else if (element == WELEM_HEAVY) {
		WeaponElement_Splash(victim, damage * WELEM_HEAVY_DAMAGE_SCALE, attacker,
		                     WELEM_HEAVY_RADIUS);
		CallExplosion(victim.origin);
	}

	weapon_element_resolving = false;
};
