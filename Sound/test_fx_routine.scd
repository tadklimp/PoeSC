
~fx_list=(
	'1': \echo,
	'2': \verb
);


(
~fx_maker = {|id, server, group, fx_bus, fx_name|
	Pdef((fx_name++'_'++id).asSymbol,
		( type: \on, instrument: fx_name,
			server: server, group: group,
			addAction: 1, out: fx_bus)).play;
}
);



(
Pdef(\gaga,
	Prout({
		var id =1;
		var group = Group.new;
		var server = s;
		var fx_bus = Bus.audio(server,2);

		~fx_list.keysValuesDo{|key, val|
			~fx_maker.(id, server, group, fx_bus, val);
		};

		Pdef((\fxMonitor_++id).asSymbol,
			( type: \on, instrument: \monitor,
				server: server, group: group,
				addAction: 1, in: fx_bus, out:0)).play;

		PbdefClean(
			//cleanup function
			{ var time=3;
				fork{
					group.release(time);
					(time+1).wait;
					fx_bus.free;
					group.free;
					Pdef.all.keys.do{ |key,i|
						if (key.asString.contains(id.asString)) { Pdef(key).remove}
					};
					"cleared".postln;
				}
			},
			// name
			(\player_++id).asSymbol,
			// Pbind
			\server, s,
			\group, group,
			\addAction, 0,
			\dur, 1,
			\degree, Pshuf([0,2,4,5]+[2,5,-2,7].choose+12,2),
			\amp, 0.01,
			\pan, Pwhite(-1,1),
			\scale, Pfunc{topEnvironment[\stanza].scale},
			\out, fx_bus.index
			/*,
			{ var time=3;
			fork{ group.release(time);
			(time+1).wait;
			group.free}
			}*/
		).play;
})))


Pdef(\gaga).play
Pdef.gui
Pdef.clear