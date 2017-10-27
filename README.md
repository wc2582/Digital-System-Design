Project 1:
A system that accept input x0, x1, x2, ... output x2; x1 - x0; x0 + x3; x0; x6; x5 - x4; x4 + x7; x4; ...

Project 2:
A 8 bit processor with 7 resgisters that suppports 13 basic instructions:
01	d2d1d0	s2s1s0 :	MOV r1, r2 (copy reg s2s1s0 to register d2d1d0)
01	110	    s2s1s0 : 	MOV M, r (copy reg s2s1s0 to memory)
01 	d2d1d0 	110 : 		MOV r, M (copy memory contents to register d2d1d0)
01 	110 	  110 : 		HLT (halt the processor)
10 	000 	  s2s1s0 : 	ADD r (add reg s2s1s0 to register A)
10 	000 	  110 : 		ADD M (add memory contents to register A)
10 	010 	  s2s1s0 : 	SUB r (subtract reg s2s1s0 from reg A)
10 	010 	  110 : 		SUB M (subtract memory contents from register A)
00 	110 	  010 : 		STA d16 (store A to memory address in the next two locations)
00 	111 	  010 : 		LDA d16 (load A from memory address in the next two locations)
00 	d2d1d0 	110 : 		MVI r, d8 (copy the byte in the next memory location to the register d2d1d0)
00 	d2d1d0 	001 : 		LXI rr, d16 (copy the bytes in the next two memory addresses to the register pair d2d1d0)
00 	000 	  000 : 		NOP (do not do anything)

Project 3:
Design a 8 byfe FIFO buffer that interacts with two senders and one receiver.

Project 4:
Designa a pipeline processor taht compute a third degree polynomial

