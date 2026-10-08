// Demon Slayer Takeover: checkered haori cubes, Nezuko's bamboo box, demon turrets and Breathing-style slashes.
::DS <- {
	forms = ["Water Breathing: First Form!", "Thunderclap and Flash!", "Flame Breathing: Rising Scorching Sun!", "Water Breathing: Waterwheel!", "Total Concentration: Constant!"],
	form = 0, form2 = 0, demons = [], origin = null
}

// The player stands at the south end of a long floor. The show happens straight ahead (north).
::DsLane <- function(along, lateral) {
	if (::DS.origin == null) { local o = SigfHost().GetOrigin(); ::DS.origin = Vector(o.x, o.y, o.z) }
	local o = ::DS.origin
	return Vector(o.x + lateral, o.y + along, o.z)
}
::DsFaceLane <- function() { SigfLook(14.0, 90.0) }
::DsDemoOn <- function() { return ("SigfDemoMode" in getroottable()) && ::SigfDemoMode }

// Full-screen colour pulse and a camera shake: the "breath" of a slash.
::DsFlash <- function(rgb, power = 100) {
	SigfSpawn("env_fade", Vector(0, 0, 0), {}, 4.0, function(e):(rgb, power) {
		e.__KeyValueFromString("rendercolor", rgb)
		e.__KeyValueFromInt("renderamt", power)
		e.__KeyValueFromFloat("duration", 0.7)
		e.__KeyValueFromFloat("holdtime", 0.3)
		e.__KeyValueFromInt("spawnflags", 1)
		EntFireByHandle(e, "Fade", "", 0.0, null, null)
	})
	SigfSpawn("env_shake", Vector(0, 0, 0), {}, 4.0, function(e) {
		e.__KeyValueFromFloat("amplitude", 5.0)
		e.__KeyValueFromFloat("frequency", 40.0)
		e.__KeyValueFromFloat("duration", 0.6)
		e.__KeyValueFromFloat("radius", 3000.0)
		e.__KeyValueFromInt("spawnflags", 4)
		EntFireByHandle(e, "StartShake", "", 0.0, null, null)
	})
}

// Slash arcs: glowing portal-ring models tilted around the target for a moment (blue water, orange flame, both for thunder).
::DsRings <- function(pos, kind) {
	local angs = [Vector(90, 0, 90), Vector(40, 35, 90), Vector(-40, -35, 90), Vector(0, 90, 20)]
	foreach (i, a in angs) {
		local m = (kind == 0 || (kind == 1 && i % 2 == 0)) ? "models/effects/fakeportalring_blue.mdl" : "models/effects/fakeportalring_orange.mdl"
		SigfIn(i * 0.12, function():(m, a, pos) {
			SigfDynamic(m, pos + Vector(0, 0, 60), 0.9, function(e):(a) {
				e.SetAngles(a.x, a.y, a.z)
				SigfScale(e, 2.2)
			})
		})
	}
}

// A blast at pos: fireball, sound, and it shoves cubes and crates around.
::DsBlast <- function(pos) {
	SigfSpawn("env_explosion", pos, {}, 3.0, function(e) { EntFireByHandle(e, "Explode", "", 0.0, null, null) })
}

// Nezuko's bamboo box: a wooden crate that tumbles like a cube.
::DsNezuko <- function(pos, life = 20.0, fn = null) {
	SigfProp("models/props_junk/wood_crate002a.mdl", pos, life, fn)
}

// A demon: a purple turret with a glaring red eye. A slayer's slash will find it.
::DsDemon <- function(pos, fn = null, life = 25.0) {
	SigfTurret(pos, 270.0, life, function(t):(fn) {
		SigfScale(t, 1.5)
		// Oni come in red and blue.
		SigfColor(t, ::DS.form2 % 2 == 0 ? "255 130 110" : "120 160 255")
		::DS.form2++
		::DS.demons.append(t)
		if (fn != null) fn(t)
	})
}

// One slash of a breathing form: each form has its own colour, effect and sound.
::DsSlay <- function(t) {
	if (t == null || !t.IsValid()) return
	local pos = t.GetOrigin()
	local kind = ::DS.form % 3
	SigfCaption(::DS.forms[::DS.form % ::DS.forms.len()], 2)
	::DS.form++
	SigfSound(kind == 1 ? "sigf/snd_thunder.wav" : "sigf/snd_slash.wav")
	::DsRings(pos, kind)
	if (kind == 0) {
		::DsFlash("60 140 255")
		SigfIn(0.25, function():(t, pos) {
			SigfSound("sigf/snd_hit.wav")
			::DsBlast(pos + Vector(0, 0, 20))
			if (t != null && t.IsValid()) EntFireByHandle(t, "SelfDestruct", "", 0.0, null, null)
		})
	} else if (kind == 1) {
		::DsFlash("255 230 60", 120)
		SigfIn(0.2, function():(t) {
			SigfSound("sigf/snd_hit.wav")
			if (t != null && t.IsValid()) EntFireByHandle(t, "Dissolve", "", 0.0, null, null)
		})
	} else {
		::DsFlash("255 120 20")
		SigfIn(0.15, function():(t) {
			if (t != null && t.IsValid()) EntFireByHandle(t, "Ignite", "", 0.0, null, null)
		})
		SigfIn(1.6, function():(t, pos) {
			SigfSound("sigf/snd_hit.wav")
			if (t != null && t.IsValid()) { ::DsBlast(pos + Vector(0, 0, 20)); EntFireByHandle(t, "SelfDestruct", "", 0.0, null, null) }
		})
	}
}

// Muzan, the demon king: a huge red demon that takes a whole volley of slashes.
::DsBoss <- function(pos) {
	SigfTurret(pos, 270.0, 40.0, function(t):(pos) {
		SigfScale(t, 2.2)
		SigfColor(t, "255 150 150")
		SigfSound("sigf/snd_roar.wav")
		for (local i = 0; i < 6; i++) {
			SigfIn(1.6 + i * 0.9, function():(i, pos) {
				SigfCaption(::DS.forms[i % ::DS.forms.len()], 1)
				::DsRings(pos + Vector(RandomFloat(-40, 40), 0, 0), i % 3)
				SigfSound(i % 3 == 1 ? "sigf/snd_thunder.wav" : "sigf/snd_slash.wav")
				::DsFlash(i % 3 == 0 ? "60 140 255" : (i % 3 == 1 ? "255 230 60" : "255 120 20"), 70)
				::DsBlast(pos + Vector(RandomFloat(-50, 50), RandomFloat(-30, 30), 40))
			})
		}
		SigfIn(7.4, function():(t, pos) {
			SigfSound("sigf/snd_roar.wav")
			SigfSound("sigf/snd_taiko.wav")
			SigfCaption("Muzan falls! Sunrise over the chamber!", 3)
			::DsFlash("255 255 255", 150)
			::DsBlast(pos + Vector(0, 0, 60))
			if (t != null && t.IsValid()) {
				EntFireByHandle(t, "Ignite", "", 0.0, null, null)
				EntFireByHandle(t, "SelfDestruct", "", 0.3, null, null)
			}
		})
	})
}

// Water Breathing portals: a blue ring and an orange ring; whatever enters one slashes out of the other.
::DsPortalOpts <- {
	sprite = false, boost = 1.3,
	onEnter = function(ent, from, to) {
		if (ent.GetClassname() != "player") {
			SigfSound("sigf/snd_slash.wav")
			::DsFlash("60 140 255", 90)
		}
	}
}
::DsPortalPair <- function(a, b, life) {
	SigfDynamic("models/effects/fakeportalring_blue.mdl", a + Vector(0, 0, 45), life, function(e) { e.SetAngles(90, 0, 90) })
	SigfDynamic("models/effects/fakeportalring_orange.mdl", b + Vector(0, 0, 45), life, function(e) { e.SetAngles(90, 0, 90) })
	SigfPortal(a, b, ::DsPortalOpts, life)
}

SigfAfter(0.5, function() {
	::DsLane(0, 0)
	SigfAutoCam(false)
	::DsFaceLane()
	SigfCmd("gameinstructor_enable 0")
	SigfCaption("DEMON SLAYER TAKEOVER", 4)
	SigfSound("sigf/snd_taiko.wav")
	// Something to see right away: a first rain of cubes and a crate.
	if (!::DsDemoOn()) {
		for (local i = 0; i < 3; i++) {
			SigfIn(0.4 + i * 0.5, function():(i) {
				local at = ::DsLane(170 + i * 30, -70 + i * 70) + Vector(0, 0, 240)
				if (i == 2) ::DsNezuko(at, 14.0)
				else SigfCube(at, 0, 14.0)
			})
		}
	}
})

// Tanjiro's checkered haori cubes and Nezuko's bamboo box rain down.
SigfEvery(3.5, function() {
	if (::DsDemoOn()) return
	local at = ::DsLane(RandomFloat(150, 300), RandomFloat(-100, 100)) + Vector(0, 0, 260)
	if (RandomInt(0, 3) == 0) ::DsNezuko(at, 14.0)
	else SigfCube(at, 0, 14.0)
})

// Demons arrive; the slayer cuts them down a few seconds later.
SigfEvery(8.0, function() {
	if (::DsDemoOn()) return
	::DS.demons = []
	for (local i = 0; i < 2; i++) ::DsDemon(::DsLane(RandomFloat(190, 280), -70.0 + i * 140.0))
	SigfIn(3.0, function() {
		local k = 0
		foreach (d in ::DS.demons) {
			SigfIn(k * 1.1, function():(d) { ::DsSlay(d) })
			k++
		}
	})
})

SigfEvery(10.0, function() {
	if (::DsDemoOn()) return
	::DsPortalPair(::DsLane(150, -110), ::DsLane(260, 100), 18.0)
})
