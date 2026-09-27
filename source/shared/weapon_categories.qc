/*
	shared/weapon_categories.qc

	The weapon category table: one place that says what every weapon *is*.

	An arsenal weapon is one of three eras of post-Second-World-War kit (Cold War issue,
	contemporary service, near-future prototype); a wonder weapon is one of five elemental
	families. Everything that needs to know - the Mystery Box's "one wonder weapon per
	family" rule, the element behaviour in server/weapons/weapon_elements.qc, the name
	shown on the ammo counter - asks this table instead of keeping its own list of ids.

	The vocabulary itself (WCAT_*, WELEM_*) is in shared_defs.qc with the rest of the
	game's enums; this file owns the mapping from weapon id to category, and from category
	to element and to a readable name.

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

float(float weapon) WepDef_GetCategory =
{
	switch (weapon)
	{
		// --- ray family: aetheric damage ---
		case W_RAY:
		case W_PORTER:
		case W_RAYMK2:
		case W_PORTERMK2:
			return WCAT_WONDER_AETHER;

		// --- tesla family: arcs between targets ---
		case W_TESLA:
		case W_DG3:
			return WCAT_WONDER_SHOCK;

		// --- incendiary: leaves the target burning ---
		case W_M2:
		case W_AFTERBURNER:
			return WCAT_WONDER_FIRE;

		// --- cryo: slows and brittles ---
		case W_FIW:
			return WCAT_WONDER_CRYO;

		// --- heavy: explosive payloads ---
		case W_PULVERIZER:
		case W_LONGINUS:
		case W_PENETRATOR:
			return WCAT_WONDER_HEAVY;

		// --- melee and equipment ---
		case W_BK:
		case W_KRAUS:
		case W_BOWIE:
			return WCAT_MELEE;
		case W_GRENADE:
		case W_BETTY:
			return WCAT_EQUIPMENT;

		// --- contemporary service weapons ---
		case W_MP5K:
		case W_KOLLIDER:
		case W_PPSH:
		case W_REAPER:
		case W_PTRS:
			return WCAT_MODERN;

		// everything else is Cold War issue
		default:
			return WCAT_RETRO;
	}

	return WCAT_RETRO;
}

// WepDef_IsWonderWeapon(weapon)
// True for every category that behaves like a wonder weapon, i.e. the elemental
// families - not "has a special model" or "came out of the box".
float(float weapon) WepDef_IsWonderWeapon =
{
	float category = WepDef_GetCategory(weapon);
	return (category >= WCAT_WONDER_AETHER) && (category <= WCAT_WONDER_HEAVY);
}

// WepDef_GetElement(weapon)
// The on-hit element implied by the weapon's category. WELEM_NONE for everything that
// is not a wonder weapon, so an ordinary gun can never set a zombie alight.
float(float weapon) WepDef_GetElement =
{
	switch (WepDef_GetCategory(weapon))
	{
		case WCAT_WONDER_AETHER: return WELEM_AETHER;
		case WCAT_WONDER_SHOCK:  return WELEM_SHOCK;
		case WCAT_WONDER_FIRE:   return WELEM_FIRE;
		case WCAT_WONDER_CRYO:   return WELEM_CRYO;
		case WCAT_WONDER_HEAVY:  return WELEM_HEAVY;
		default: return WELEM_NONE;
	}

	return WELEM_NONE;
}

// WepDef_GetCategoryName(category)
// Display label for menus and the HUD, so the categories are visible to the player.
// Categories are read by the client too: the HUD and the menus show them.
string(float category) WepDef_GetCategoryName =
{
	switch (category)
	{
		case WCAT_RETRO:         return "Cold War";
		case WCAT_MODERN:        return "Modern";
		case WCAT_PROTOTYPE:     return "Prototype";
		case WCAT_WONDER_AETHER: return "Aether";
		case WCAT_WONDER_SHOCK:  return "Shock";
		case WCAT_WONDER_FIRE:   return "Incendiary";
		case WCAT_WONDER_CRYO:   return "Cryo";
		case WCAT_WONDER_HEAVY:  return "Heavy";
		case WCAT_MELEE:         return "Melee";
		case WCAT_EQUIPMENT:     return "Equipment";
		default: return "Unknown";
	}

	return "Unknown";
}
