// Moving On Second
// for Sauer and SuperCollider

(
s.waitForBoot {

	var pID = 1; // 0=Sauer, 1=percussive MIDI instrument
	var project = (
		name: ["Sauer", "Percussive"]
	);
	var sets = [ #[48,60,63,67,71], #[42,55,58,62,66], #[48,60,63,67,70] , #[41,53,61,68,72], #[64,65,69] ];
					// Cmmaj7 Gmmaj7 Cm7 C#maj7/E# Fomit5/E (E F A)
	var buffers = [
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/131106-115647 spelende kinderen1.WAV"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/131106-115647 spelende kinderen2.WAV"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/kids in water reverb rbeq.aiff"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/Apollo 9 spacewalk.wav"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/moving on second.wav"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/BoLo.wav"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/intro1.aif"),
		Buffer.read(s, Document.dir++"Moving-On-Second/Data/clock-horse1.aif")
	];
	var buffer, len, start, alwaysPlaySamples = 0, chosenSet;
	// manual II green grey
	var regNbr1 = 0, regIndex1 = 0, note1Prev = 0, note1Next = 60;
	var regList1 = [3,4,5,6,7,8];
	var regName1 = [  "Contrabass 16", "Octavbass 8", "Cello 8", "Bassflöte 8", "Subbass 16", "Lieblich Gedackt 16"];
	// manual III green grey blue white
	var regNbr2 = 9, regIndex2 = 0, note2Prev = 0, note2Next;
	var regList2 = [3,4,5,6,7,8,10,13,14,19];
	var regName2 = [  "Contrabass 16", "Octavbass 8", "Cello 8", "Bassflöte 8", "Subbass 16", "Lieblich Gedackt 16","Bourdon 16","Flute", "Dulciana", "Bourdon 8"];
	var fRun, tRun, win, bStart, fStop, bPanic, bQuit, tHeader;
	var synths = Group.new();
	var screenHeight = Window.screenBounds.height;
	var tMidiSeq, fMidiSeq, note3Next;

	~midiOutDevice = "EXT";

	// start controllers
	if(~wControllersAvail.isNil, { (Document.dir++"Lapis/Controllers.scd").load });

	SynthDef(\multi, {
		arg pitchMod = 0, pitchRange = 0.05, pitchSet = #[48,60,63,67,71], len, gate = 1;
		var sig, amp = 1, env;
		env = EnvGen.kr( Env.new([0,1,0],[len,len],[-1,1]), gate, doneAction: 2 );
		amp = SinOsc.kr({ExpRand(0.01,0.5)}!5).range(0.3,1);
		sig = SinOsc.ar(
			( pitchMod * ({ LFNoise1.kr(ExpRand(0.4,2)).range(1-pitchRange,1+pitchRange) }!5) * pitchSet.midicps ) +
			( (1-pitchMod) * pitchSet.midicps )
		);
		sig = sig * 0.2 * amp * env;
		sig = Splay.ar(sig);
		Out.ar(0,sig);
	}).add;

	SynthDef(\organ, { arg freq=440, amp=0.2, gate=1, len = 3;
		var signal;
		signal = Saw.ar(freq * [0.998, 1, 1.003]).sum + SinOsc.ar(2*freq, 0, -4.dbamp);
		signal = (signal*0.5) + Resonz.ar(signal, 2/[2, 4, 8, 14, 32, 50, 80], [200, 400, 800, 1400, 3200, 5000, 8000]).mean;
		signal = MoogFF.ar(signal, freq * 4, 3.2);
		signal = FFT(LocalBuf(2**10), signal);
		signal = PV_MagSquared(signal);
		signal = PV_LocalMax(signal, 31);
		signal = IFFT(signal);
		signal = EnvGen.kr(Env.new([0,1,1,0],[0.2*len,0.6*len,0.2*len],[-1,0,1]), gate, doneAction: 2) * signal;
		Out.ar(0, Pan2.ar(signal * (-28.dbamp) * amp, Rand(-0.5,0.5)));
	}).add;

	SynthDef(\clicks, {
		arg ratio = 1, gate = 1;
		var sig, env;
		env = EnvGen.kr( Env.new([0,1,0],[5,15],[1,-1]), gate, doneAction: 2 );
		sig = Dust.ar({ExpRand(2,10)}!2, {Rand(10,30)}!2);
		sig = PitchShift.ar(sig, pitchRatio: ratio);
		sig = FreeVerb.ar(sig, mix: 0.8, room:1, damp: 1);
		sig = sig * env;
		Out.ar(0,0.2 * sig);
	}).add;

	// SynthDef(\kick, {
	// 	var sig;
	// 	sig = SinOsc.ar( XLine.kr(800,50,0.02) * LFNoise1.kr(30).range(0.97,1.03) );
	// 	sig = sig * EnvGen.kr( Env.new([0,1,0], [0.01, 2]), doneAction:2);
	// 	sig = [sig, DelayL.ar(sig,0.2,Rand(0.01,0.2))];
	// 	sig = softclip(sig);
	// 	sig = Decimator.ar(sig, 10000);
	// 	Out.ar(0, 0.5 * sig);
	// }).add;
	//
	// SynthDef(\kick2, {
	// 	var sig, sigPluck, kickFreq, kickFreqList;
	// 	kickFreqList = Dwrand([900,200,50,2000],[0.5,0.2,0.2,0.1],1);
	// 	kickFreq = Demand.ar(Impulse.ar(0),0,kickFreqList);
	// 	sig = LPF.ar(Ringz.ar(Impulse.ar(0), Rand(50,80), Rand(3.5,3.8)), kickFreq, mul:2);
	// 	sig = sig * EnvGen.kr( Env.new([0,1,0], [0.01, 5]), doneAction:2);
	// 	sig = 0.5 * [sig, DelayL.ar(sig,0.2,Rand(0.01,0.2))];
	// 	sig = Decimator.ar(sig, 10000);
	// 	Out.ar(0,sig);
	// }).add;

	SynthDef(\samplePlay, {
		arg buffer, len, start, gate = 1;
		var sig, env;
		env = EnvGen.kr(Env.linen(2, len ,2), gate, doneAction: 2);
		sig = Pan2.ar( PlayBufCF.ar(2,buffer, startPos: start*s.sampleRate), Rand(-1,0) );
		sig = LPF.ar(sig, LFNoise1.ar(1).range(300,2000));
		Out.ar(0, 0.3 * sig * env);
	}).add;

	if(pID == 0, { // only for Sauer
		// assignment knobs
		~midiOut.noteOn(13, 101, 127); // reset

		~midiOut.noteOn(13, 68, 127); // manual II green
		~midiOut.noteOn(13, 70, 127); // manual II grey
		~midiOut.noteOn(13, 67, 127); // manual II green ^
		~midiOut.noteOn(13, 69, 127); // manual II grey ^

		~midiOut.noteOn(13, 84, 127); // manual III green
		~midiOut.noteOn(13, 86, 127); // manual III grey
		~midiOut.noteOn(13, 83, 127); // manual III green ^
		~midiOut.noteOn(13, 85, 127); // manual III grey ^
		~midiOut.noteOn(13, 88, 127); // manual III white
		~midiOut.noteOn(13, 91, 127); // manual III blue
	});

	fRun = {
		inf.do { |i|
			("\nRun"+i).postln;

			k = rand(2);
			j = rrand(0.01,0.05).round(0.001);
			if(k==1, { ("Pitch Modulation ON with pitch deviation maximum" + j).postln }, { "Pitch Modulation OFF".postln });

			if( (i+1)%15 == 0, {
				chosenSet = sets[4];
				("PitchSet 4:"+chosenSet).postln;
			},
			{
				chosenSet = sets[i%4];
				("PitchSet"+(i%4)++":"+chosenSet).postln;
			});
			Synth(\multi, [\pitchMod, k,\pitchRange,j,\pitchSet,chosenSet,\len,10 + ( (i%10)/2 ) - rrand(0,4)], target: synths);

			if( i%2 == 0, {
				Synth(\organ, [\freq, (chosenSet.choose-12).midicps, \len,15 + (i%10) - rrand(0,3), \amp, rrand(0.05,0.1) ], target: synths);
			});

			if( i%1 == 0, {

				if(pID == 0, { // only for Sauer
					note1Next = (chosenSet.choose) - 12;
					note2Next = (chosenSet.choose);

					~midiOut.noteOff(2, note1Prev, 127);
					note1Prev = note1Next;
					~midiOut.noteOff(3, note2Prev, 127);
					note2Prev = note2Next;

					{
						~midiOut.noteOn(13, regNbr1, 0);
						regIndex1 = rand(regList1.size-1);
						regNbr1 = regList1[regIndex1];
						("Registration:"+regName1[regIndex1]).postln;
						~midiOut.noteOn(13, regNbr1, 127);

						~midiOut.noteOn(13, regNbr2, 0);
						regIndex2 = rand(regList2.size-1);
						regNbr2 = regList2[regIndex2];
						("Registration:"+regName2[regIndex2]).postln;
						~midiOut.noteOn(13, regNbr2, 127);

						{
							~midiOut.noteOn(2,note1Next,127) ;
							~midiOut.noteOn(3,note2Next,127)
						}.defer(0.5);
					}.defer(rrand(2.0,10.0));
				});

				if(pID == 1, { // only for Percussive
					if([0,1].wchoose([0.7,0.3]) == 0, { // sometimes stick with the old bass note
						note1Next = (chosenSet.choose) - 12;
					}, { "# Keeping bass note".postln });
					note2Next = (chosenSet.choose);
					note3Next = (chosenSet.choose);
					tMidiSeq.stop;
					tMidiSeq = Task(fMidiSeq).start;
				});

			});

			if( (i+1)%7 == 0, {
				n = [0.2,0.4,1].choose;
				("Clicks Pitch Ratio:"+n).postln;
				Synth(\clicks, [\ratio,n], target: synths)
			});
			// if( (i-1)%3 == 0, {Synth([\kick,\kick2].choose)});
			if( ( (i+1)%4 == 0 ) || (alwaysPlaySamples == 1), {
				buffer = buffers.choose;
				len = (buffer.numFrames / s.sampleRate) / rrand(1,3); len = max(0,len - 4);
				start = rrand(0, (buffer.numFrames / s.sampleRate) - len);
				("Playback sample \"" ++ buffer.path.subStr(buffer.path.findBackwards("/")+1) ++ "\" from" + start.round(0.01) + "sec until" + (start.round(0.01)  + len.round(0.01)) +"sec").postln;
				Synth(\samplePlay,[\buffer,buffer,\len,len,\start,start], target: synths);
			});
			("Wait"+(15 + (i%10))+"seconds" ).postln;
			(15 + (i%10) ).wait;
		};
	};

	fMidiSeq = {
		var count = 3;
		var seqNotes = [note1Next, note2Next, note3Next],seqLen = {[0.25,0.5].wchoose([0.8,0.2])}!3;
		var note, len, factor = 1, factor2 = 1, midiSeqSpeed, interval1, interval2, velocity, tossy = -1;

		rrand(0.0,6.0).wait;
		midiSeqSpeed = rrand(2.0,3.0);
		midiSeqSpeed = midiSeqSpeed / [1,1.5,2].wchoose([0.8,0.15,0.05]); // every now and than speed up
		interval1 = (15 / midiSeqSpeed).floor;
		("MIDI sequence: notes" + seqNotes + "with a speed of" + midiSeqSpeed.round(0.01)).postln;

		inf.do { |i|
			note = seqNotes[i%count];
			velocity = [rrand(50,127),0].wchoose([0.8,0.2]);
			// ("Triggering MIDI note" + note + "with velocity" + velocity).postln;
			~midiOut.noteOn(0,note,velocity);
			{~midiOut.noteOff(0,note,127); }.defer(factor*factor2*midiSeqSpeed*seqLen[i%count]/2);
			(rrand(0.9,1.1)*factor*factor2*midiSeqSpeed*seqLen[i%count]).wait;

			// speed up irregularly
			if(i%interval1 == 3, { factor = 0.5 });
			if(i%interval1 == 1, { factor = 1 });
			if(i%interval1 == 5, { factor2 = 0.5 });
			if(i%interval1 == 1, { factor2 = 1 });

			// stop
			if( i > (60/midiSeqSpeed), {
				if(tossy == -1, { tossy = [0,1].wchoose([0.6,0.4]) });
				// ("# Reached max with tossy =" + tossy).postln;
				if( tossy == 1, {
					tMidiSeq.stop;
					("# Aborted MIDI sequence after" + (60/midiSeqSpeed).round(0.1) + "ticks").postln;
				});
			});
		};
	};

	fStop = {
		arg deferTime = 3.2;
		tRun.stop;
		synths.freeAll;
		if(pID == 0, { // only for Sauer
			// ~midiOut.control(2,123,0);
			// ~midiOut.control(3,123,0);
			~midiOut.noteOff(3, note2Prev, 127); ~midiOut.noteOff(3, note2Prev+12, 127);
			~midiOut.noteOff(2, note1Prev, 127); ~midiOut.noteOff(2, note1Prev+12, 127);
			{
				synths.freeAll;
				// ~midiOut.control(2,123,0);
				// ~midiOut.control(3,123,0);
				~midiOut.noteOff(3, note2Prev, 127); ~midiOut.noteOff(3, note2Prev+12, 127);
				~midiOut.noteOff(2, note1Prev, 127); ~midiOut.noteOff(2, note1Prev+12, 127);
			}.defer(deferTime);
		});
		if(pID == 1, { // only for Percussive
			tMidiSeq.stop;
			{
				tMidiSeq.stop;
				synths.freeAll;
			}.defer(deferTime);
		});
	};

	win = (Window("Moving On Second |" + project.name[pID],Rect(100,screenHeight - 260,500,180))
		.background_(Color.rand)
		.onClose_({
			buffers.size.do { |i|
				buffers[i].free;
			};
			fStop.value();
		})
	);
	tHeader = (StaticText(win,Rect(0,0,500,100))
		.font_(Font("Courier",50))
		.align_(\center)
		.string_("Moving On Second")
	);
	bStart = (SmoothButton(win,Rect(10,100,150,60))
		.border_(1).radius_(2).canFocus_(false)
		.font_(Font("Courier",30))
		.states_([ ["START",Color.black, Color.white]  ,  ["STOP",Color.white, Color.black]  ])
		.action_({
			if(bStart.value == 1, {
				tRun = Task(fRun).start;
			},{
				fStop.value();
				win.background_(Color.rand);
			});
		})
	);
	bPanic = (SmoothButton(win,Rect(175,100,150,60))
		.border_(1).radius_(2).canFocus_(false)
		.font_(Font("Courier",30))
		.states_([ ["PANIC",Color.black, Color.white]  ,  ["PANIC",Color.white, Color.black]  ])
		.action_({
			if(bPanic.value == 1, {
				bStart.valueAction_(0);
				fStop.value();
				{ bPanic.valueAction_(0) }.defer(0.1);
			});
		})
	);
	bQuit = (SmoothButton(win,Rect(340,100,150,60))
		.border_(1).radius_(2).canFocus_(false)
		.font_(Font("Courier",30))
		.states_([ ["QUIT",Color.black, Color.white]  ])
		.action_({
			fStop.value(deferTime: 0.3);
			{ "osascript -e 'tell application \"SuperCollider 3.7.0 beta1\" to quit'".unixCmd }.defer(0.5);
		})
	);
	win.front;

	~vol = Volume.new;
	{
	~vol.volume = -10;
	~vol.gui;
	}.defer(0.1);

	// hide IDE
	// "osascript -e 'tell application \"System Events\" to set visible of process \"SuperCollider\" to false'".unixCmd;

}
)


