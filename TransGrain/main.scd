"startup.scd".loadRelative[0];
~moduleSynth = "moduleSynth.scd".loadRelative[0];

~gsine = ~moduleSynth[\gauss_sine_constructor].(\gsine_pattern,\gsine_cloud,\gsine_out,\gauss_sine,\cloud_env)

~gsine.play;

(
~gsine.patternParam.dur = {(0.01,0.05..0.4).choose};
~gsine.patternParam.freq = Pxrand((170,1200..12500),inf);
~gsine.patternParam.amp = Pwhite(0.1,0.3);
~gsine.patternParam.grain_dur = Pbrown(0.001,0.05,0.00125);
~gsine.patternParam.pos = Pwhite(-1,1);
//
~gsine.patternGen(10) // n voices, fadeTime
)

(
~gsine.cloudParam.sus_lvl = 0.4;
~gsine.cloudParam.dur = Pseq((1..10),inf);
~gsine.cloudParam.atk = 1;
~gsine.cloudParam.dec = 1;
~gsine.cloudParam.sus = 2;
~gsine.cloudParam.rel = 3;
~gsine.cloudGen(0.50,0.7,0.3, 8); // Reverb wet/dry mix, room, damp (0-1), fadeTime
)
~gsine.play;
~gsine.end;
~gsine.destroy();

// PULSE TRAIN API
~train = ~moduleSynth[\gauss_train_constructor].(\gtrain_pattern,\gtrain_cloud,\gtrain_out,\gauss_train,\cloud_env)

(
~train.patternParam.dur = Pxrand((0.02, 0.03..0.1), inf);
~train.patternParam.freq = {(100,200..1000).choose};
~train.patternParam.nharm = 15;
~train.patternParam.amp = Pwhite(0.1,0.5);
~train.patternParam.grain_dur = Pwhite(1,2);
~train.patternParam.pos = Pwhite(-1,1);
//
~train.patternGen(4) // n voices, fadeTime
)

(
~train.cloudParam.sus_lvl = 0.7;
~train.cloudParam.dur = Pwhite(6,7);
~train.cloudParam.atk = 3;
~train.cloudParam.dec = 0.5;
~train.cloudParam.sus = 1;
~train.cloudParam.rel = Pwhite(5,8);

~train.cloudGen(0.7,0.9,0.3); // Reverb wet/dry mix, room, damp (0-1), fadeTime
)

~train.play;


