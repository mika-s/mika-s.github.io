---
layout: post
title:  "Verifying emulator correctness - part 1 (diff)"
date:   2022-11-06 12:00:00 +0100
categories: emulators Z80 8080
---

I've been creating emulators for while now, and something that's always a bit difficult is verifying
that they work as they should. Is `ADC` setting the carry flag correctly? Is `POP` incrementing SP as it should?

An invaluable tool are the instruction exercisers people create to verify emulator correctness. Examples of these are
*8080EXM* for the Intel 8080 and *zexall* for the Z80. These programs will typically give us an indication of whether an
instruction is implemented correctly or not. However, if a test is failing the program will not tell us what's wrong
with our implementation.

E.g. zexall shows us this if a particular test is passing:

```
<rlca,rrca,rla,rra>...........  OK
```

And something like this when it's failing:

```
<rlca,rrca,rla,rra>...........  ERROR **** crc expected:9ba3807c found:944e7aed
```

In this post I'll explain how I figure out where the errors are when the tests are failing. This particular post will
use `diff` for finding errors. [The next post]({% post_url 2022-11-11-verifying-emulator-correctness-2 %}) will explain
how I deal with tests that generate too much data to be run to completion before diffing.

I use a Z80 emulator in the examples below, but the principles are the same for all CPUs.

### Assembling with zmac

Assume we run the Z80 test binary *zexdoc* and the `<rlca,rrca,rla,rra>` test is failing, but none of the others. The
output would then be something like this:

```
Z80doc instruction exerciser
<adc,sbc> hl,<bc,de,hl,sp>....  OK
add hl,<bc,de,hl,sp>..........  OK
add ix,<bc,de,ix,sp>..........  OK
add iy,<bc,de,iy,sp>..........  OK
aluop a,nn....................  OK
aluop a,<b,c,d,e,h,l,(hl),a>..  OK
aluop a,<ixh,ixl,iyh,iyl>.....  OK
aluop a,(<ix,iy>+1)...........  OK
bit n,(<ix,iy>+1).............  OK
bit n,<b,c,d,e,h,l,(hl),a>....  OK
cpd<r>........................  OK
cpi<r>........................  OK
<daa,cpl,scf,ccf>.............  OK
<inc,dec> a...................  OK
<inc,dec> b...................  OK
<inc,dec> bc..................  OK
<inc,dec> c...................  OK
<inc,dec> d...................  OK
<inc,dec> de..................  OK
<inc,dec> e...................  OK
<inc,dec> h...................  OK
<inc,dec> hl..................  OK
<inc,dec> ix..................  OK
<inc,dec> iy..................  OK
<inc,dec> l...................  OK
<inc,dec> (hl)................  OK
<inc,dec> sp..................  OK
<inc,dec> (<ix,iy>+1).........  OK
<inc,dec> ixh.................  OK
<inc,dec> ixl.................  OK
<inc,dec> iyh.................  OK
<inc,dec> iyl.................  OK
ld <bc,de>,(nnnn).............  OK
ld hl,(nnnn)..................  OK
ld sp,(nnnn)..................  OK
ld <ix,iy>,(nnnn).............  OK
ld (nnnn),<bc,de>.............  OK
ld (nnnn),hl..................  OK
ld (nnnn),sp..................  OK
ld (nnnn),<ix,iy>.............  OK
ld <bc,de,hl,sp>,nnnn.........  OK
ld <ix,iy>,nnnn...............  OK
ld a,<(bc),(de)>..............  OK
ld <b,c,d,e,h,l,(hl),a>,nn....  OK
ld (<ix,iy>+1),nn.............  OK
ld <b,c,d,e>,(<ix,iy>+1)......  OK
ld <h,l>,(<ix,iy>+1)..........  OK
ld a,(<ix,iy>+1)..............  OK
ld <ixh,ixl,iyh,iyl>,nn.......  OK
ld <bcdehla>,<bcdehla>........  OK
ld <bcdexya>,<bcdexya>........  OK
ld a,(nnnn) / ld (nnnn),a.....  OK
ldd<r> (1)....................  OK
ldd<r> (2)....................  OK
ldi<r> (1)....................  OK
ldi<r> (2)....................  OK
neg...........................  OK
<rrd,rld>.....................  OK
<rlca,rrca,rla,rra>...........  ERROR **** crc expected:251330ae found:2afeca3f
shf/rot (<ix,iy>+1)...........  OK
shf/rot <b,c,d,e,h,l,(hl),a>..  OK
<set,res> n,<bcdehl(hl)a>.....  OK
<set,res> n,(<ix,iy>+1).......  OK
ld (<ix,iy>+1),<b,c,d,e>......  OK
ld (<ix,iy>+1),<h,l>..........  OK
ld (<ix,iy>+1),a..............  OK
ld (<bc,de>),a................  OK
Tests complete
```

Running all the tests will first of all take a lot of time, but also run a lot of instructions that we know are fine.
zexdoc runs more than 5 billion instructions. By modifying the zexdoc source code and reassembling the binary we
can make it run only the tests we are interested in.

We can use [zmac - Z-80 Macro Cross Assembler][zmac] to assemble Z80 and 8080 programs. To use zmac you can download
the zip file on the website and either use the precompiled binary if you are on a Windows machine, or compile it if you
are on Linux or Mac.

To compile:

```sh
$ unzip zmac.zip
$ cd src/
$ make
```

That's it. We can now assemble Z80 and 8080 programs like so:

```sh
$ ./zmac zexdoc.src
$ ls zout/
zexdoc.250.cas  zexdoc.250.wav  zexdoc.ams  zexdoc.bds  zexdoc.cim  zexdoc.cmd  zexdoc.hex  zexdoc.lst  zexdoc.mds  zexdoc.tap
```

The newly created zexdoc.cim binary is the one that's interesting.

To modify the tests to only run the tests we are interested in we have to look at the source code (zexdoc.src). It
contains a list of tests:

```asm
tests:
    dw	adc16
    dw	add16
    dw	add16x
    dw	add16y
    dw	alu8i
    dw	alu8r
    dw	alu8rx
    dw	alu8x
    dw	bitx
    dw	bitz80 ; not tested from there upwards
    dw	cpd1
    dw	cpi1
    dw	daaop	; can't use opcode as label
    dw	inca
    dw	incb
    dw	incbc
    dw	incc
    dw	incd
    dw	incde
    dw	ince
    dw	inch
    dw	inchl
    dw	incix
    dw	inciy
    dw	incl
    dw	incm
    dw	incsp
    dw	incx
    dw	incxh
    dw	incxl
    dw	incyh
    dw	incyl
    dw	ld161
    dw	ld162
    dw	ld163
    dw	ld164
    dw	ld165
    dw	ld166
    dw	ld167
    dw	ld168
    dw	ld16im
    dw	ld16ix
    dw	ld8bd
    dw	ld8im
    dw	ld8imx
    dw	ld8ix1
    dw	ld8ix2
    dw	ld8ix3
    dw	ld8ixy
    dw	ld8rr
    dw	ld8rrx
    dw	lda
    dw	ldd1
    dw	ldd2
    dw	ldi1
    dw	ldi2
    dw	negop	; jgh: can't use opcode as label
    dw	rldop	; jgh: can't use opcode as label
    dw	rot8080
    dw	rotxy
    dw	rotz80
    dw	srz80
    dw	srzx
    dw	st8ix1
    dw	st8ix2
    dw	st8ix3
    dw	stabd
    dw	0
```

By modifying this list we can choose what tests to run. To only run the `<rlca,rrca,rla,rra>` tests, we keep
`dw	rot8080` and `dw  0`, but delete the rest:

```asm
tests:
    dw	rot8080
    dw	0
```

Then reassemble the file with `$ ./zmac zexdoc.src` as shown above. After running the new test binary in the emulator
we get the following result:

```
Z80doc instruction exerciser
<rlca,rrca,rla,rra>...........  ERROR **** crc expected:251330ae found:2afeca3f
Tests complete
```

Only a fraction of the instructions are run in this case, which makes testing against a reference emulator much easier.

### Setting up our own emulator and the reference emulator

To figure out what's wrong we can compare our emulator to a reference emulator that we know runs correctly.
[Superzazu's Z80 emulator][superzazu-z80] is one such emulator. We can tell from its Github page that it passes all
the zexdoc tests.

The goal is to compare our emulator to the reference emulator by printing the emulator's state during each instruction,
run and store what the emulator prints to stdout in a log file, and then use a diffing tool to see if there are any
diffs between the two log files. There should be no differences; the reference emulator is known to be correct, so any
deviation on our side is probably incorrect.

By the state of the emulator I mean the following:

- PC
- SP
- Currently executed opcode
- Content of all registers
- The flag register

The memory content is also part of the emulator's state, but is in most cases too large to print out, so I'll skip that.

We therefore have to create a function that prints the state in both emulators. In my own emulator I'll add a call to
the print function right before the big jump table in the CPU core (which is how I implement the opcode parsing):

```cpp
m_opcode = get_next_byte().farg;

print_debug(m_opcode);  // HERE

r_tick();

switch (m_opcode) {
    case NOP:
    nop(cycles);
    break;
}
```

I'm also adding the same call to the IX/IY, IX/IY bits, bits and EXTD jump tables. The calls can be seen
[here][print_debug-call-1], [here][print_debug-call-2], [here][print_debug-call-3], [here][print_debug-call-4] and
[here][print_debug-call-5].

The print function that prints the emulator's state looks like [this][print-function-definition]:

```cpp
std::string hexify(u8 val) {
    std::stringstream ss;
    ss << "0x" << std::setfill('0') << std::setw(2) << std::hex << static_cast<int>(val);
    std::string return_val = ss.str();

    return return_val;
}

void Cpu::print_debug(u8 opcode) {
    std::cout << "pc=" << hexify(m_pc)
              << ",sp=" << hexify(m_sp)
              << ",op=" << hexify(opcode)
              << ",a=" << hexify(m_acc_reg)
              << ",b=" << hexify(m_b_reg)
              << ",c=" << hexify(m_c_reg)
              << ",d=" << hexify(m_d_reg)
              << ",e=" << hexify(m_e_reg)
              << ",h=" << hexify(m_h_reg)
              << ",l=" << hexify(m_l_reg)
              << ",a'=" << hexify(m_acc_p_reg)
              << ",b'=" << hexify(m_b_p_reg)
              << ",c'=" << hexify(m_c_p_reg)
              << ",d'=" << hexify(m_d_p_reg)
              << ",e'=" << hexify(m_e_p_reg)
              << ",h'=" << hexify(m_h_p_reg)
              << ",l'=" << hexify(m_l_p_reg)
              << ",ix=" << hexify(m_ix_reg)
              << ",iy=" << hexify(m_iy_reg)
              << ",i=" << hexify(m_i_reg)
              << ",r=" << hexify(m_r_reg)
              << ",c=" << m_flag_reg.is_carry_flag_set()
              << ",po=" << m_flag_reg.is_parity_overflow_flag_set()
              << ",hc=" << m_flag_reg.is_half_carry_flag_set()
              << ",n=" << m_flag_reg.is_add_subtract_flag_set()
              << ",z=" << m_flag_reg.is_zero_flag_set()
              << ",s=" << m_flag_reg.is_sign_flag_set()
              << ",y=" << m_flag_reg.is_y_flag_set()
              << ",x=" << m_flag_reg.is_x_flag_set()
              << "\n"
              << std::flush;
}
```

The individual bits of the flag register are shown on their own. This is to make it easier to see where the error is if
we encounter a diff. In general we only want one line per instruction (or two or three in the case of IX/IY, bits or
EXTD instructions). We will print a lot of instructions, so each line should not be too big, otherwise we'll end up
using a lot of unnecessary space on the hard drive.

When running zexdoc with the emulator now we see the following at the top of the log file. The log file itself is
2.8 GB, and that was only for one small test.

```
pc=0x0101,sp=0xffff,op=0xc3,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0x00,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x00,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
pc=0x0114,sp=0xffff,op=0x2a,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0x00,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x01,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
pc=0x0117,sp=0xffff,op=0xf9,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0xc9,l=0x01,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x02,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
pc=0x0118,sp=0xc901,op=0x11,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0xc9,l=0x01,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x03,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
```

The same print function has to be set up in the reference emulator. The reference emulator has to print out its state
in exactly the same format as our emulator, otherwise the diffing tool will complain on every single line. Superzazu's
emulator is written in C, and the C version of `print_debug` looks like this:

```c
void print_debug(z80* const z, uint8_t opcode) {
    printf("pc=0x%04x", z->pc);
    printf(",sp=0x%04x", z->sp);
    printf(",op=0x%02x", opcode);
    printf(",a=0x%02x", z->a);
    printf(",b=0x%02x", z->b);
    printf(",c=0x%02x", z->c);
    printf(",d=0x%02x", z->d);
    printf(",e=0x%02x", z->e);
    printf(",h=0x%02x", z->h);
    printf(",l=0x%02x", z->l);
    printf(",a'=0x%02x", z->a_);
    printf(",b'=0x%02x", z->b_);
    printf(",c'=0x%02x", z->c_);
    printf(",d'=0x%02x", z->d_);
    printf(",e'=0x%02x", z->e_);
    printf(",h'=0x%02x", z->h_);
    printf(",l'=0x%02x", z->l_);
    printf(",ix=0x%04x", z->ix);
    printf(",iy=0x%04x", z->iy);
    printf(",i=0x%02x", z->i);
    printf(",r=0x%02x", z->r);
    printf(",c=%d", z->cf);
    printf(",po=%d", z->pf);
    printf(",hc=%d", z->hf);
    printf(",n=%d", z->nf);
    printf(",z=%d", z->zf);
    printf(",s=%d", z->sf);
    printf(",y=%d", z->yf);
    printf(",x=%d", z->xf);
    printf("\n");
}
```

It's called in the same places as for my emulator:

```c
void exec_opcode(z80* const z, uint8_t opcode) {
    print_debug(z, opcode);
    z->cyc += cyc_00[opcode];
    inc_r(z);

    switch (opcode) {
    // ...
    }
}
```

Superzazu's emulator is also set up to run three tests in [z80_tests][superzazu-z80-three-tests], so I'll comment out
the two unnecessary tests:

```c
//r += run_test(&cpu, "roms/prelim.com", 8721LU);
r += run_test(&cpu, "roms/zexdoc.cim", 46734978649LU);
//r += run_test(&cpu, "roms/zexall.cim", 46734978649LU);
```

### Comparing with diff


Now that both the emulators are setup for printing their state to stdout, we can run them both and log stdout to a log
file:

```sh
$ ./emulator run zexdoc > sut.log
$ ./z80_tests > ref.log
```

The files are 2.8 GB, so lets compare the first 10,000 lines first:

```sh
head -10000 sut.log > sut_short.log
head -10000 ref.log > ref_short.log
```

We can now use a diffing tool such as KDiff3 or just old regular `diff` to compare the files:

[![Picture of diff in KDiff3](/assets/verifying-emulator-correctness-1/diff.png)](/assets/verifying-emulator-correctness-1/diff.png)

From the screenshot of the diff in KDiff3 (click on it to see the full-sized image), we can see that the first diff is
at line 9375. The opcode that was executed before the diff is `rra`. On the left side, which is my emulator's output,
we can see that the N flag is set after the `rra`, while it's unset in the reference emulator. According to the
documentation, the `rra` flag should always reset N, so that's an error in my emulator.

After fixing the code we can see that KDiff3 no longer reports a diff at that line anymore.

[![Picture of no diff in KDiff3](/assets/verifying-emulator-correctness-1/diff_ok.png)](/assets/verifying-emulator-correctness-1/diff_ok.png)

In fact, in no longer report any diffs, and the test now passes:

```
Z80doc instruction exerciser
<rlca,rrca,rla,rra>...........  OK
Tests complete
```

And that's how I fix bugs in my emulators. By narrowing down the test suite to a single test and then comparing my
emulator to a reference emulator that is known to be correct. This might not always work, however. In some cases the
diff might occur after millions of executed instructions, which makes the log files gigantic. In cases like that,
executing one instruction at a time while running the emulators in parallel might be a better solution. I'll explain
how I do that in [the next part]({% post_url 2022-11-11-verifying-emulator-correctness-2 %}).


[zmac]: http://48k.ca/zmac.html
[superzazu-z80]: https://github.com/superzazu/z80
[superzazu-z80-three-tests]: https://github.com/superzazu/z80/blob/d64fe10a2274e5e40019b1086bf7d8990cbc5f23/z80_tests.c#L126
[print_debug-call-1]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L143
[print_debug-call-2]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L933
[print_debug-call-3]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L1711
[print_debug-call-4]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L2221
[print_debug-call-5]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L2368
[print-function-definition]: https://github.com/mika-s/MikasEmulators/blob/1d4e03284e79833caad1ee5b28beecc3b5969566/src/chips/z80/cpu.cpp#L2797
