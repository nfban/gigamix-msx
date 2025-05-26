100 'save "NEKOMAKE.BAS",a
110 _SYSON
120 _PEEKS(&H7600,8,A$):IF A$<>"MSX-View" THEN BEEP:PRINT "Not installed FNT-VIEW driver":END
130 'BLOAD "FNT-VIEW.BIN",R :'install FNT-VIEW (if necessary)
140 DEFINT A-Y
150 AD=0:SJ=0:CH$=""
160 A=0:B=0:I=0:ZA=0:ZB=0:A$="":B$="" :'temporary variables
170 TA=0:TI=0:TJ=0:TA$="" :'temporary variables for subroutine
180 '
190 COLOR 15,0,0:SCREEN 8,0
200 VDP(9)=VDP(9) OR &B10 :'sprite off
210 _HMMM(0,0)-(255,211) TO (0,256):_HMMM(0,0)-(255,43) TO (0,256+212)
220 _LOAD("KANJI3.GRP",@65536!,,7)
230 _LOAD("NEKO-EXT.SC8",@0,,7)
240 _KINIT(0):_KBOLD(1,1):_KCOLOR(255,0,0,0):_KSIZE(6,12)
250 '
260 OPEN "NEKO-TBL.TXT" FOR INPUT AS #1
270 IF EOF(1) THEN 500
280 LINE INPUT #1,B$ :'text analyzing sub. [in] B$:string
290 A$=","           :'[in] A$:separator
300 GOSUB 550        :'[out] ZA:offset addr, SJ:shift-jis code, CH$:characters
310 IF CH$="" THEN 270 :'no string:go next line
320 IF LEFT$(CH$,1)<>"G" THEN 410 :'kanji code
330 'extra code
340  A=VAL(RIGHT$(CH$,3))
350  COPY((A MOD 20)*12,(A\20)*12)-STEP(11,11) TO (0,128):_VDPWAIT
360  GOSUB 870 :'data compress sub.
370  ZB=65536!+ZA
380  _BLOCK(&H3000,@ZB,18)
390  GOTO 270
400 'kanji code
410  N=LEN(CH$)\2
420  FOR I=0 TO N-1
430   A$=MID$(CH$,I*2+1,2)
440   _XY(0,128):_KPRINT(A$)
450   GOSUB 870 :'data compress sub.
460   ZB=65536!+ZA+(I*18)
470  _BLOCK(&H3000,@ZB,18)
480  NEXT
490  GOTO 270
500 'compress finish
510 CLOSE #1
520 SET PAGE 1,1
530 BSAVE "KANJI3'.GRP",0,65411!,S
540 END
550 'text analyzing sub.
560 '[in] A$:separator, B$:string
570 '[out] ZA:offset addr, SJ:shift-jis code, CH$:characters
580 '[use] TA, TI, TA$, SP$()
590 ZA=0:SJ=0:CH$=""
600 FOR I=0 TO 2:SP$(I)="":NEXT
610 GOSUB 710
620 IF SP$(0)="" OR SP$(1)="" OR SP$(2)="" THEN RETURN :'quit by invalid data
630 _UPPER(SP$(0),SP$(0))
640 IF SP$(0)="ADDR" THEN RETURN :'quit by 1st line
650 ZA=VAL("&H"+SP$(0)): 'set offset addr
660 IF ZA<0 THEN ZA=ZA+65536!
670 _UPPER(SP$(1),SP$(1))
680 SJ=VAL("&H"+SP$(1)): 'set shift-jis code
690 CH$=SP$(2): 'set characters
700 RETURN
710 'text split sub.
720 '[in] A$:separator, B$:string
730 '[out] SP$():array, TA:array count
740 '[use] TA, TI, TA$
750 TA=0:TI=0:TA$=""
760 FOR TI=1 TO LEN(B$)
770  IF MID$(B$,TI,1)=A$ THEN TA=TA+1
780 NEXT
790 IF 9<TA THEN TA=9:'max array No.
800 ERASE SP$:DIM SP$(TA)
810 TA=0
820 FOR TI=1 TO LEN(B$)
830  TA$=MID$(B$,TI,1)
840  IF A$<>TA$ THEN SP$(TA)=SP$(TA)+TA$ ELSE TA=TA+1:IF 9<TA THEN TI=LEN(B$)
850 NEXT
860 RETURN
870 'data compress sub.
880 '[in] none
890 '[out] RAM:3000h-3011h (18 bytes)
900 '[use] TA, TI, TJ, TA$
910 FOR TI=0 TO 5
920  TA$=""
930  FOR TJ=0 TO 23
940   TA=POINT((TJ MOD 12),128+(TI*2)+(TJ\12))
950   TA$=TA$+HEX$(-(TA=255))
960  NEXT
970  _POKE(&H3000+(TI*3)+0,VAL("&B"+LEFT$(TA$,8)))
980  _POKE(&H3000+(TI*3)+1,VAL("&B"+MID$(TA$,9,8)))
990  _POKE(&H3000+(TI*3)+2,VAL("&B"+RIGHT$(TA$,8)))
1000 NEXT
1010 RETURN
