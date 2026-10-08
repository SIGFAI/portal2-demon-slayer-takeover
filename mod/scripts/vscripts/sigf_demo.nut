// Demo: demons and slashes from the first seconds, haori cubes, a portal throw, a Nezuko crate throw, then Muzan.
::DemoDemons <- []
::DemoBox <- null
::DemoFocus <- null
::DemoSwayOn <- true
::DemoRain <- true

::DemoDemon <- function(pos) { ::DsDemon(pos, function(t) { ::DemoDemons.append(t) }, 11.0) }
::DemoSlayAll <- function(gap) {
	local k = 0
	foreach (d in ::DemoDemons) {
		SigfIn(k * gap, function():(d) { ::DsSlay(d) })
		k++
	}
}

SigfDemo(0.5, function() {
	::DsLane(0, 0)
	::DemoFocus = ::DsLane(220, 0) + Vector(0, 0, 50)
	::DsFaceLane()
})

SigfDemo(1, function() {
	SigfCaption("DEMON SLAYER TAKEOVER", 3)
	::DemoDemons = []
	::DemoDemon(::DsLane(200, -80))
	::DemoDemon(::DsLane(200, 80))
	SigfIn(0.4, function() { SigfCube(::DsLane(150, -30) + Vector(0, 0, 230), 0, 9.0) })
	SigfIn(0.9, function() { ::DsNezuko(::DsLane(160, 40) + Vector(0, 0, 230), 9.0) })
})

SigfDemo(4.5, function() { ::DemoSlayAll(1.6) })

SigfDemo(11, function() {
	SigfCaption("MORE DEMONS!", 2)
	::DemoDemons = []
	::DemoDemon(::DsLane(210, -60))
	::DemoDemon(::DsLane(210, 60))
	SigfIn(3.0, function() { ::DemoSlayAll(1.6) })
})

SigfDemo(19.5, function() {
	SigfCaption("Water Breathing portals: slash on exit!", 4)
	::DsPortalPair(::DsLane(150, -110), ::DsLane(260, 100), 14.0)
	SigfIn(1.0, function() { SigfCube(::DsLane(150, -110) + Vector(0, 0, 200), 0, 20.0) })
	SigfIn(3.5, function() { SigfCube(::DsLane(150, -105) + Vector(0, 0, 220), 0, 20.0) })
})

SigfDemo(31, function() {
	SigfCaption("Nezuko's box takes the fight!", 3)
	::DemoDemons = []
	::DemoDemon(::DsLane(210, 0))
	::DsNezuko(::DsLane(40, 0) + Vector(0, 0, 60), 20.0, function(c) { ::DemoBox = c; ::DemoSwayOn = false; SigfGrab(c) })
	SigfIn(1.8, function() {
		SigfLookAt(::DsLane(210, 0) + Vector(0, 0, 40))
		SigfHold("use", 0.1)
		SigfIn(0.15, function() {
			if (::DemoBox != null && ::DemoBox.IsValid()) {
				local dir = ::DsLane(210, 0) + Vector(0, 0, 30) - ::DemoBox.GetOrigin()
				dir.Norm()
				SigfPush(::DemoBox, dir * 900.0 + Vector(0, 0, 40))
			}
		})
	})
	SigfIn(3.4, function() { ::DemoSlayAll(1.0) })
	SigfIn(5.0, function() { ::DemoSwayOn = true })
})

SigfDemo(41, function() {
	SigfCaption("MUZAN, THE DEMON KING, APPEARS!", 3)
	::DemoRain = false
	::DemoFocus = ::DsLane(270, 0) + Vector(0, 0, 100)
	::DsBoss(::DsLane(270, 0))
	SigfIn(10.0, function() { ::DemoRain = true })
})

SigfDemo(52, function() {
	::DemoFocus = ::DsLane(220, 0) + Vector(0, 0, 50)
	SigfCaption("THE DEMON SLAYER CORPS STRIKES BACK", 3)
	::DemoDemons = []
	foreach (l in [-110, 0, 110]) ::DemoDemon(::DsLane(210, l))
	SigfIn(2.5, function() { ::DemoSlayAll(1.4) })
})

SigfDemo(62, function() {
	SigfText("Total concentration, portals open!", -1, 0.85, 5, "255 255 255", 2)
	::DsPortalPair(::DsLane(150, -110), ::DsLane(260, 100), 10.0)
	for (local i = 0; i < 3; i++) SigfIn(i * 0.6, function() { SigfCube(::DsLane(150, -105) + Vector(RandomFloat(-20, 20), 0, 200 + i * 30), 0, 12.0) })
})

// Constant gentle motion: the view sways around the action, the player strafes, cubes keep raining.
SigfEvery(0.1, function() {
	if (!::DemoSwayOn || SigfHost() == null || ::DemoFocus == null) return
	local t = Time()
	SigfLookAt(::DemoFocus + Vector(70.0 * sin(t * 0.8), 0, 25.0 * sin(t * 0.6)))
})
::DemoStrafe <- 0
SigfEvery(1.6, function() {
	::DemoStrafe++
	SigfHold(::DemoStrafe % 2 == 0 ? "moveleft" : "moveright", 0.6)
})
SigfEvery(2.0, function() {
	if (!::DemoRain) return
	SigfCube(::DsLane(RandomFloat(140, 260), RandomFloat(-110, 110)) + Vector(0, 0, 230), 0, 7.0)
})
