onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /butterfly2_tb/u
add wave -noupdate -radix unsigned /butterfly2_tb/t
add wave -noupdate -radix unsigned /butterfly2_tb/w
add wave -noupdate /butterfly2_tb/clk
add wave -noupdate /butterfly2_tb/rst
add wave -noupdate /butterfly2_tb/sel
add wave -noupdate /butterfly2_tb/fail
add wave -noupdate /butterfly2_tb/start
add wave -noupdate -radix unsigned /butterfly2_tb/s0
add wave -noupdate -radix unsigned /butterfly2_tb/s1
add wave -noupdate /butterfly2_tb/ibutterfly2/clk
add wave -noupdate /butterfly2_tb/ibutterfly2/rst
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/u
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/t
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/w
add wave -noupdate /butterfly2_tb/ibutterfly2/sel
add wave -noupdate /butterfly2_tb/ibutterfly2/s0
add wave -noupdate /butterfly2_tb/ibutterfly2/s1
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/multa
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/multb
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/modrslt
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/modhalf2
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/multrslt
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/u1
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/t1
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/w1
add wave -noupdate /butterfly2_tb/ibutterfly2/sel1
add wave -noupdate /butterfly2_tb/ibutterfly2/sel10
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/udelay
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/usel
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/addera
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/adderb
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/addrslt
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/modhalf1
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/modhalf1delay
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/suba
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/subb
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/subrslt
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s0ct
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s0gs
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s1ct
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s1gs
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s0ctdelay
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s1ctdelay
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s0o
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/s1o
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/u10
add wave -noupdate -radix unsigned /butterfly2_tb/ibutterfly2/t10
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {74 ps} {141 ps}
