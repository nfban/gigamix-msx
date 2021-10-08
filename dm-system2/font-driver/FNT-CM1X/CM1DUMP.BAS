100 'save "cm1dump.bas",a
110 'Matsushita(Panasonic) 12px Kanji-ROM font viewer version 1.0
120 'by nf_ban (MSX Club Gigamix) www.gigamix.jp
130 'This program requires MSX Expand I/O F7h (not 08h)
140 CLEAR 200:DEFINT A-Z
150 DIM DD$(15),BN(3),O(17)
160 A=0:B=0:I=0:J=0:N=0:A1=0:A2=0:A3=0:A$=""
170 N=&H20 :'character code
180 FOR I=0 TO 15:READ DD$(I):NEXT
190 DM$=STRING$(16,CHR$(0))
200 '
210 GOSUB 680 :'display how to use
220 OUT &H40,&HF7 :'#40:use MSX expand I/O F7h
230 OUT &H42,3    :'#42:enable Matsushita Kanji ROM 1st & 2nd level
240 'read font data
250 OUT &H47,N\256     :'#47:set character code (upper 8bit)
260 OUT &H48,N MOD 256 :'#48:set character code (lower 8bit)
270 FOR I=0 TO 17:O(I)=INP(&H49):NEXT :'#49:get font data (18 bytes)
280 'display font
290 IF N<&H100 THEN A$=RIGHT$("000"+HEX$(N),4) ELSE A$=HEX$(N+&H7340)+":SJIS"
300 LOCATE 15,0:PRINT A$;"     "
310 GOSUB 570:'display 12px matrix sub.
320 'key commands
330 A=ASC(INPUT$(1))
340 IF A=27 THEN CLS:GOTO 410 :'[ESC] quit
350 IF A=30 THEN N=&H21       :'[UP] change Hankaku
360 IF A=31 THEN N=&HE01      :'[Down] change Zenkaku
370 IF A=29 THEN GOSUB 430    :'[Left] prev.
380 IF A=28 THEN GOSUB 470    :'[Right] next
390 IF A=67 OR A=99 THEN GOSUB 510 :'[C] set Shift-JIS code
400 GOTO 250
410 END
420 'prev. sub.
430 IF N=0 THEN BEEP:RETURN
440 N=N-1:IF N=&HDFF THEN N=&HFE  :'change Zenkaku to Hankaku
450 RETURN
460 'next sub.
470 IF N=&H2532 THEN BEEP:RETURN  :'Shift-JIS 1st max value:9872h
480 N=N+1:IF N=&H100 THEN N=&HE00 :'change Hankaku to Zenkaku
490 RETURN
500 'set shift-jis code sub.
510 INPUT "Shift-JIS code (8140 to 9872)";A$
520 B=VAL("&H"+A$):IF &H9872<B OR B<&H8140 THEN BEEP:RETURN
530 N=B+36032!
540 LOCATE 0,13:PRINT SPACE$(40)
550 RETURN
560 'display 12px matrix sub.
570 FOR I=0 TO 5
580  A1=O(I*3):A2=O(I*3+1):A3=O(I*3+2)
590  BN$(0)=DD$(A1\16)+DD$(A1 AND 15)+DD$(A2\16)
600  BN$(1)=DD$(A2 AND 15)+DD$(A3\16)+DD$(A3 AND 15)
610  FOR J=0 TO 1
620   LOCATE 2,I*2+J:PRINT BN$(J)
630  NEXT
640 NEXT
650 PRINT CHR$(13)
660 RETURN
670 'display how to use sub.
680 COLOR 15,4,7:SCREEN 1:WIDTH 29
690 LOCATE 0,16
700 PRINT "[LEFT] prev, [RIGHT] next"
710 PRINT "[UP] Hankaku, [Down] Zenkaku"
720 PRINT "[C] SJIS code, [ESC] Quit"
730 FOR I=0 TO 7:VPOKE BASE(7)+(&H40*8)+I,&HFE+(I=7)*254:NEXT
740 RETURN
750 '
760 DATA "----","---@","--@-","--@@","-@--","-@-@","-@@-","-@@@"
770 DATA "@---","@--@","@-@-","@-@@","@@--","@@-@","@@@-","@@@@"
