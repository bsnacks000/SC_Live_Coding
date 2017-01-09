"startup.scd".loadRelative[0];
~moduleSynth = "moduleSynth.scd".loadRelative[0];

~gsine = ~moduleSynth[\gauss_sine_constructor].(\gsine_pattern,\gsine_cloud,\gsine_out,\gauss_sine,\cloud_env)

// change parameters
(
~gsine.patternParam.dur = Pseq((0.01..0.1),inf);
~gsine.patternParam.freq = {(1500,1600..2500).choose};
~gsine.patternParam.amp = Pwhite(0.1,0.3);
~gsine.patternParam.grain_dur = 0.01;
~gsine.patternParam.pos = Pwhite(-1,1);
//
~gsine.patternGen(5,3) // n voices, fadeTime
)

(
~gsine.cloudParam.sus_lvl = 0.5;
~gsine.cloudParam.dur = 7;
~gsine.cloudParam.atk = 0.01;
~gsine.cloudParam.dec = 0.5;
~gsine.cloudParam.sus = 4;
~gsine.cloudParam.rel = 3;

~gsine.cloudGen(0,0.5,0.3, 3); // Reverb wet/dry mix, room, damp (0-1), fadeTime
)
~gsine.play;

~gsine.end;

~gsine.destroy();



