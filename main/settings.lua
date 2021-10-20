local settings = {
	-- Change these settings to your own MIDI device output.
    MidiInput = {
        P1 = {
            Left = 0,
            Down = 1,
            Up = 2,
            Right = 3,
            Press = 147,
            Hold = 163,
            Release = 131,
            MaxLevel = 128
        },
        P2 = {
            Left = 4,
            Down = 5,
            Up = 6,
            Right = 7,
            Press = 147,
            Hold = 163,
            Release = 131,
            MaxLevel = 128
        }
    }
}
return settings