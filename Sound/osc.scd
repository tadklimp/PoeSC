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
		new_list.postln;
		Pdefn(\sylab_length, Pseq(new_list.asArray, 1));
	},
	'/sylab/length', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;



// TO DO: find a way to recognize compound symbols
OSCdef.new(
	'/sylab/stress', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		values[1..].do{ |i|
			if (i.isKindOf(Symbol)){
				i.do{
					i.postln;
					case
					{i == 'P'}{ new_list.add(1)}
					{i == 'U'}{ new_list.add(0.5)}
					{i == 'Rest(1)'} { new_list.add(Rest(1))}
			}}{

			}
		};
		// ("lenghts are: "++ msg[1..]).postln;
		new_list.postln;
		Pdefn(\sylab_stress, Pseq(new_list.asArray, inf));

		("stresses are: "++ msg[1..]).postln
	},
	'/sylab/stress', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;

OSCdef.new(
	'/sylab/weight', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		// msg in the form of [OSC address, arg1, arg2, ...]
		// postln("Message from " ++ recAddr ++ ": " + msg);
		("weights are: "++ msg[1..]).postln
	},
	'/sylab/weight', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;

)

OSCdef.all; // All OSC listening functions stored as dictionary
OSCdef.freeAll;


Pbind(\dur, Pseq([2,1,1,1,Rest(1)],1), \degree, Prand([1,2,5,4,7,2],inf)).play
(
Pbind(
	\dur, (Pdefn(\sylab_length)*0.5).trace,
	\degree, Prand([1,2,5,4,7,2],inf),
	\amp, Pdefn(\sylab_stress)*0.7
).play
);

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