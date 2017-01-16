(
var localpath = thisProcess.nowExecutingPath.dirname +/+ "quarks"; // add this as a local path for install
Quarks.install(localpath +/+ "SynthModule"); // now install each Module seperately
thisProcess.recompile;
)


// boot and build a proxyspace
s.boot;
~proxy = ProxySpace(s)

//
~sine = GaussSine(s, ~proxy, \gsine)
~sine2 = GaussSine(s, ~proxy,\gsine2)

~cloud = CloudEnv(s,~proxy,~sine.pattern_name, \genv);

~sine.pattern_name

(
~sine.setFreq(Pseq((100,200..700),inf));
~sine.setAmp(Pwhite(0.1,0.5));
~sine.patternGen(1, 3);
~sine2.setFreq(Pwhite(4000,8000));
~sine2.setDur(0.2);
~sine2.setAmp(Pwhite(0.2,0.6));
~sine2.patternGen(1,3);
~cloud.cloudGen(3);
~cloud.setSusLvl(1);
)

// send sine and sine2 to a seperate bus
~proxy[\bus][0] = ~proxy[~sine.pattern_name];
~proxy[\bus][1] = ~proxy[~sine2.pattern_name];
~cloud.setInbus(\bus)

~cloud.inbus_name

~proxy[\out] = {FreeVerb.ar(~cloud.cloudGen(3))}
~proxy[\out].play
~proxy[\out].end;


~proxy[\bus].end;

~proxy[\out2] = {FreeVerb.ar(~cloud2.cloudGen(2))}
~proxy[\out2].play;


// unload the module from the library
(
Quarks.uninstall("SynthModule");
thisProcess.recompile;
)