// You cannot open a TCP listening port with sclang :(
// You will have to use UDP
NetAddr.langPort; // Generally port 57120 but could be used by another application so check
thisProcess.openPorts; // See all open ports for sclang.  These are UDP ports

// Trace incoming messages
OSCFunc.trace(false);

(
OSCdef.new(
	'/sylab/length', // It expects Integers and Rests
	{ |msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;
		values[1..].do{ |i|
			if (i.isKindOf(Integer)){
				new_list.add(i)
			}{
				new_list.add(Rest(1))
			}
		};
		("lenghts are: "++ msg[1..]).postln;
		// new_list.postln;
		Pdefn(\sylab_length, Pseq(new_list.asArray, 1));
	},
	'/sylab/length', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;


// 'PUU'.asString.do{|i| {case {i==$P}{"ya".postln}{i==$U}{"yuuu".postln}; }.fork}

//
OSCdef.new(
	'/sylab/stress', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		new_list.add(0); // init list
		values[1..].do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $P}{ new_list.add(1.0)}
					{x == $U}{ new_list.add(0.5)}
				}
				}{
					// new_list.add(Rest(0))
					new_list.add(0)
				}
			}
		};

		Pdefn(\sylab_stress, Pseq(new_list.asArray, 1));
		("stresses are: "++ msg[1..]).postln;
		// (Pdefn(\sylab_stress).source.storeArgs).postln;
		new_list.postln;
	},
	'/sylab/stress', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;


OSCdef.new(
	'/sylab/weight', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		new_list.add(0); // init list
		values[1..].do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $H}{ new_list.add(2.0)}
					{x == $L}{ new_list.add(1.0)}
				}
				}{
					new_list.add(0)
				}
			}
		};

		Pdefn(\sylab_weight, Pseq(new_list.asArray, inf));
		("weights are: "++ msg[1..]).postln;
		new_list.postln;

		// ("weights are: "++ msg[1..]).postln
	},
	'/sylab/weight', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;
)



OSCdef.all; // All OSC listening functions stored as dictionary
OSCdef.freeAll;

// calculate sum of array
(
c = [ 2, 1, 1, 1, 1, Rest(0), 2, 1, 1, Rest(0), 1, 1, 1, 1, 2, Rest(0), 1, Rest(0) ].collect({
	arg i;
	var list = List.new;
	if (i.isKindOf(Rest).not){
		i
	}{
		1
	};
}).sum;
)

// A test Pbind
// TODO: Find a way to have multiple speeds inside of Pbind :(
(
Pbind(
	\dur, (Pdefn(\sylab_length)).trace(prefix:'dur: '),
	\degree, Prand([1,2,5,4,7,2],inf),
	\amp, (Pdefn(\sylab_stress)).trace(prefix:'amp: ')
	// \stretch, Pconst(21,Pdefn(\sylab_weight)).trace(prefix:'stretch: ')
).play
);




///////////// troubleshooting multiple speeds in one Pbind

(
Pbind(
	\dur, 1,
	\amp, Pfindur(1,Pseg(Pseq([0.1,1],inf), 0.25 ,\lin,inf)),
).play
);


Rational(4,7).asFloat
a = [2,1,1,2,1,2,2,1]
b = (a.size-1).collect({|i| a[i] %/ a[i+1]; })
b.asFloat.postln



~filterFreqBus = Bus.control(s, 1);

(
Pbind(
	\type, \bus,
	\out, ~filterFreqBus,
	\array, Pseg(Pseq([0.1,0.5],inf), 0.5 ,\sin,inf),
	\dur, 0.001
).play;
)

~filterFreqBus.plot(1); // seems to work

(
Pbind(
	\dur, 2,
	\legato, 1,
	\amp, ~filterFreqBus.asMap
).play;
)











(
s.boot;
~out = 0;

~printUgenMsg = {
	|name, recAddr, freq, phase, amp, dur, pan|
	var header, phaseStr, args;
	header = name ++ " message from " ++ recAddr ++ ": ";
	phaseStr = if(phase == nil, {""}, {", Phase " ++ phase});
	args = "Freq " ++ freq ++ phaseStr ++ ", Amp " ++ amp ++ ", Dur " ++ dur ++ ", Pan " ++ pan;
	postln(header ++ args)
};

SynthDef(\sine, {
	arg out = ~out, freq, phase, amp, dur, pan;
	var sig, env;
	sig = SinOsc.ar(freq, phase, amp);
	env = Env.linen(5, dur, 5);
	sig = sig * EnvGen.kr(env, doneAction: 2);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

OSCdef.new(
	'sine',
	{
		|msg, time, recAddr, recPort|
		var freq, phase, amp, dur, pan;
		freq = msg[1];
		phase = msg[2];
		amp = msg[3];
		dur = msg[4];
		pan = msg[5];
		~printUgenMsg.value("Sine", recAddr, freq, phase, amp, dur, pan);
		Synth(\sine, [\freq, freq, \phase, phase, \amp, amp, \dur, dur, \pan, pan]);
	},
	'/sounds/sine',
	nil
);

SynthDef(\saw, {
	arg out = ~out, freq, amp, dur, pan;
	var sig, env;
	sig = Saw.ar(freq, amp); // Saw doesn't have phase argument
	env = Env.linen(5, dur, 5);
	sig = sig * EnvGen.kr(env, doneAction: 2);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

OSCdef.new(
	'saw',
	{
		|msg, time, recAddr, recPort|
		var freq, amp, dur, pan;
		freq = msg[1];
		amp = msg[2];
		dur = msg[3];
		pan = msg[4];
		~printUgenMsg.value("Saw", recAddr, freq, nil, amp, dur, pan);
		Synth(\saw, [\freq, freq, \amp, amp, \dur, dur, \pan, pan]);
	},
	'/sounds/saw',
	nil
);
)

s.meter;