.model small
.stack 100h

.data
	;Screen Messages
	WelcomeMsg db 'Welcome To Candy Crush$'
	EnterNameMsg db "Please Enter Your Name:$"
	RulesMsg db ' Rules$'
	MovesLeftMsg db ' Moves left: $'
	scoremsg db 'score : $'
	RulesExplainedMsg db 'The game is played by swiping candies',0ah,
						 'You have 15 moves',0ah,
						 'You have to make combos of 3',0ah,
						 'Colorbomb replaces a shape and you get the points',0ah,
						 0ah,'[Press Enter to Continue]$'

	;User-Related Variables
	UserName db 250 dup (?)
	
	mainarray db 49 dup(?),0
	
	
	fhandle dw ?
	lineskip db 0Ah	
	msg db 'player name :'
	msg1 db 'score lvl1 :'
	msg2 db 'score lvl2 :'
	msg3 db 'score lvl3 :'
	filename db 'scores.txt',0
	filecount db ?
	scorefiletemp dw ?
	scoredisp db ?,?,?
	scoredisp2 db ?,?,?
	
	
	counter db 0
	bombcounter db 0
	display dw 0
	movescount db 0
	movestemp dw ?
	scorecount db 0
	scoretemp dw ?
	;msg1 db "swap successfull $"
	;msg2 db "swap not successfull  : $"
	
	
	
	
	
	changex dw 100
	changey dw 100

	x dw 100
	y dw 100

	xcord dw 100
	ycord dw 110
	bombtemp db ?
	temp dw ?
	temp1 dw ?
	random db ?
	looptemp dw ?
	ptemp dw ?

	valuex dw ?
	valuey dw ?

	moves dw 10
	scorelvl1 dw ?
	scorelvl3 dw ?
	swap1 dw ?
	swap2 dw ?

	
.code
main proc
	mov ax,@data
	mov ds,ax

	call DisplayInitialScreen
	call DisplayRulesScreen
	call DisplayNameOnBoard
	call producerand
	call drawboxes	
	
	
	mov display,0
	mov cx,7
	ploop:
		mov ptemp,cx
		call populate
		mov ax,xcord
			sub ax,350
		mov xcord,ax
		mov ax,ycord
		add ax,50
		mov ycord,ax
		
		mov cx,ptemp
	loop ploop
		mov moves,10
gamecontinue:	
		call checkswap
		call checkcolourbomb
		
		call checkcombos
		call updateboard
	cmp moves,0
	jne gamecontinue
	
	
;lvl3
	call clearscreen
	mov ah, 00h
	mov al, 12h
	int 10h
	
	mov	changex,  100
	mov	changey, 100

	mov	x , 100
	mov	y , 100

	mov	xcord , 100
	mov	ycord , 110
	call DisplayNameOnBoardlvl3
	call producerandlvl3
	call drawboxes
	
	
	mov display,0
	mov cx,7
	bloop:
		mov ptemp,cx
		call populate
		mov ax,xcord
		sub ax,350
		mov xcord,ax
		mov ax,ycord
		add ax,50
		mov ycord,ax
		
		mov cx,ptemp
	loop bloop
	
		mov moves,10
		mov scorelvl3,0
gamecontinuelvl3:

		call checkswaplvl3
		call checkcomboslvl3
		call checkcolourbomblvl3
		call updateboardlvl3
		
	cmp moves,0
	jne gamecontinuelvl3
	
	call scorefiling
	
	exit:
		mov ah,4ch
		int 21h
	
main endp


scorefiling proc

	mov si,0
	mov filecount,0
	mov ax,scorelvl1
	mov scorefiletemp,ax
	
	displayscore1:
	

	mov ax,scorefiletemp
	mov dx,0
	mov bx,10
	div bx
	push dx
	mov scorefiletemp,ax	
	inc filecount
	
	cmp ax,0
	
	je popscore1
	jne displayscore1
	
	popscore1:
	
	cmp filecount,0
	je toscore2
	pop dx
	add dx,48
	mov scoredisp[si],dl
	inc si
	dec filecount 
	jmp popscore1
	
toscore2:

	mov si,0
	mov filecount,0
	mov ax,scorelvl3
	mov scorefiletemp,ax
	
	displayscore3:
	

	mov ax,scorefiletemp
	mov dx,0
	mov bx,10
	div bx
	push dx
	mov scorefiletemp,ax	
	inc filecount
	
	cmp ax,0
	
	je popscore3
	jne displayscore3
	
	popscore3:
	
	cmp filecount,0
	je toscore4
	pop dx
	add dx,48
	mov scoredisp2[si],dl
	inc si
	dec filecount 
	jmp popscore3
	
	
toscore4:	
	mov ah,3ch
	mov si,offset filename
	mov dx,si
	mov cl,0
	int 21h
	jc exit1

	mov fhandle,ax
	
	MOV SI,0
	
	
exit:
	
	mov cx,sizeof msg
	mov ah,40h
	mov bx,fhandle
	mov dx, offset msg
	add cx,0
	int 21h
	
	mov cx,sizeof UserName
	mov ah,40h
	mov bx,fhandle
	mov dx, offset UserName
	add cx,0
	int 21h
	
	mov ah,40h
	mov bx,fhandle
	mov dx,offset lineskip
	mov cx,1
	int 21h
	
	
	mov cx,sizeof msg1
	mov ah,40h
	mov bx,fhandle
	mov dx, offset msg1
	add cx,0
	int 21h
			

	;mov ah,3ch
	;mov bx,fhandle
	;int 21h
		
	
	
	mov cx,sizeof scoredisp
	mov ah,40h
	mov bx,fhandle
	mov dx, offset scoredisp
	add cx,0
	int 21h
	
	mov ah,40h
	mov bx,fhandle
	mov dx,offset lineskip
	mov cx,1
	int 21h
	
	
	mov cx,sizeof msg2
	mov ah,40h
	mov bx,fhandle
	mov dx, offset msg2
	add cx,0
	int 21h
			

	;mov ah,3ch
	;mov bx,fhandle
	;int 21h
		
	
	
	mov cx,sizeof scoredisp2
	mov ah,40h
	mov bx,fhandle
	mov dx, offset scoredisp2
	add cx,0
	int 21h
	
	;mov dl,'0'
	;mov ah,02h
	;int 21h

	
	
exit1:

ret
scorefiling endp





clearscreen proc

	call pause	
		MOV AL,03
		MOV AH,0
		INT 10H

ret
clearscreen endp

checkcolourbomb proc

mov si,swap1
.if(mainarray[si]==6)
	mov si,swap2
	mov al,mainarray[si]
	mov bombtemp,al
	
	mov si,0
	mov bombcounter,0
	
	
loopcheckbomb1:
	mov al,bombtemp
	cmp mainarray[si],al
jne skip
	call pause
	call numrand
	mov mainarray[si],dl
	add scorelvl1,5
skip:
	inc si
	inc bombcounter


	cmp bombcounter,49
	jne loopcheckbomb1
	
mov si,swap1
call numrand
mov mainarray[si],dl

mov si,swap2
call numrand
mov mainarray[si],dl
	

.endif
	
	mov bombcounter,0
	mov si,0
		
mov si,swap2
.if(mainarray[si]==6)
	mov si,swap1
	mov al,mainarray[si]
	mov bombtemp,al
	
	mov si,0
	mov bombcounter,0
	
	
loopcheckbomb2:
	mov al,bombtemp
	cmp mainarray[si],al
jne skip1
	call pause
	call numrand
	mov mainarray[si],dl
	add scorelvl1,5
skip1:
	inc si
	inc bombcounter


	cmp bombcounter,49
	jne loopcheckbomb2

	mov si,swap1
	call numrand
	mov mainarray[si],dl

	mov si,swap2
	call numrand
	mov mainarray[si],dl


.endif

	mov si,0
	mov bombcounter,0
	


endbomb:
ret
checkcolourbomb endp


checkswap proc

	mov ax,1
	int 33h
	
	;mov ax,4
	;int 33h
getswap1:
	mov ax,3
	int 33h
	
	mov valuex,cx
	mov valuey,dx
	cmp bl,1
	je disp
jmp getswap1
	
disp:
.if((valuex>100)&&(valuex<150)&&(valuey>100)&&(valuey<150))
	mov swap1,0 
.elseif((valuex>150)&&(valuex<200)&&(valuey>100)&&(valuey<150))
	mov swap1,1
.elseif((valuex>200)&&(valuex<250)&&(valuey>100)&&(valuey<150))
	mov swap1,2
.elseif((valuex>250)&&(valuex<300)&&(valuey>100)&&(valuey<150))
	mov swap1,3
.elseif((valuex>300)&&(valuex<350)&&(valuey>100)&&(valuey<150))
	mov swap1,4
.elseif((valuex>350)&&(valuex<400)&&(valuey>100)&&(valuey<150))
	mov swap1,5
.elseif((valuex>400)&&(valuex<450)&&(valuey>100)&&(valuey<150))
	mov swap1,6
	
	
.elseif((valuex>100)&&(valuex<150)&&(valuey>150)&&(valuey<200))
	mov swap1,7
.elseif((valuex>150)&&(valuex<200)&&(valuey>150)&&(valuey<200))
	mov swap1,8
.elseif((valuex>200)&&(valuex<250)&&(valuey>150)&&(valuey<200))
	mov swap1,9
.elseif((valuex>250)&&(valuex<300)&&(valuey>150)&&(valuey<200))
	mov swap1,10
.elseif((valuex>300)&&(valuex<350)&&(valuey>150)&&(valuey<200))
	mov swap1,11
.elseif((valuex>350)&&(valuex<400)&&(valuey>150)&&(valuey<200))
	mov swap1,12
.elseif((valuex>400)&&(valuex<450)&&(valuey>150)&&(valuey<200))
	mov swap1,13


.elseif((valuex>100)&&(valuex<150)&&(valuey>200)&&(valuey<250))
	mov swap1,14
.elseif((valuex>150)&&(valuex<200)&&(valuey>200)&&(valuey<250))
	mov swap1,15
.elseif((valuex>200)&&(valuex<250)&&(valuey>200)&&(valuey<250))
	mov swap1,16
.elseif((valuex>250)&&(valuex<300)&&(valuey>200)&&(valuey<250))
	mov swap1,17
.elseif((valuex>300)&&(valuex<350)&&(valuey>200)&&(valuey<250))
	mov swap1,18
.elseif((valuex>350)&&(valuex<400)&&(valuey>200)&&(valuey<250))
	mov swap1,19
.elseif((valuex>400)&&(valuex<450)&&(valuey>200)&&(valuey<250))
	mov swap1,20



.elseif((valuex>100)&&(valuex<150)&&(valuey>250)&&(valuey<300))
	mov swap1,21
.elseif((valuex>150)&&(valuex<200)&&(valuey>250)&&(valuey<300))
	mov swap1,22
.elseif((valuex>200)&&(valuex<250)&&(valuey>250)&&(valuey<300))
	mov swap1,23
.elseif((valuex>250)&&(valuex<300)&&(valuey>250)&&(valuey<300))
	mov swap1,24
.elseif((valuex>300)&&(valuex<350)&&(valuey>250)&&(valuey<300))
	mov swap1,25
.elseif((valuex>350)&&(valuex<400)&&(valuey>250)&&(valuey<300))
	mov swap1,26
.elseif((valuex>400)&&(valuex<450)&&(valuey>250)&&(valuey<300))
	mov swap1,27
	

.elseif((valuex>100)&&(valuex<150)&&(valuey>300)&&(valuey<350))
	mov swap1,28
.elseif((valuex>150)&&(valuex<200)&&(valuey>300)&&(valuey<350))
	mov swap1,29
.elseif((valuex>200)&&(valuex<250)&&(valuey>300)&&(valuey<350))
	mov swap1,30
.elseif((valuex>250)&&(valuex<300)&&(valuey>300)&&(valuey<350))
	mov swap1,31
.elseif((valuex>300)&&(valuex<350)&&(valuey>300)&&(valuey<350))
	mov swap1,32
.elseif((valuex>350)&&(valuex<400)&&(valuey>300)&&(valuey<350))
	mov swap1,33
.elseif((valuex>400)&&(valuex<450)&&(valuey>300)&&(valuey<350))
	mov swap1,34	


.elseif((valuex>100)&&(valuex<150)&&(valuey>350)&&(valuey<400))
	mov swap1,35
.elseif((valuex>150)&&(valuex<200)&&(valuey>350)&&(valuey<400))
	mov swap1,36
.elseif((valuex>200)&&(valuex<250)&&(valuey>350)&&(valuey<400))
	mov swap1,37
.elseif((valuex>250)&&(valuex<300)&&(valuey>350)&&(valuey<400))
	mov swap1,38
.elseif((valuex>300)&&(valuex<350)&&(valuey>350)&&(valuey<400))
	mov swap1,39
.elseif((valuex>350)&&(valuex<400)&&(valuey>350)&&(valuey<400))
	mov swap1,40
.elseif((valuex>400)&&(valuex<450)&&(valuey>350)&&(valuey<400))
	mov swap1,41
	


.elseif((valuex>100)&&(valuex<150)&&(valuey>400)&&(valuey<450))
	mov swap1,42
.elseif((valuex>150)&&(valuex<200)&&(valuey>400)&&(valuey<450))
	mov swap1,43
.elseif((valuex>200)&&(valuex<250)&&(valuey>400)&&(valuey<450))
	mov swap1,44
.elseif((valuex>250)&&(valuex<300)&&(valuey>400)&&(valuey<450))
	mov swap1,45
.elseif((valuex>300)&&(valuex<350)&&(valuey>400)&&(valuey<450))
	mov swap1,46
.elseif((valuex>350)&&(valuex<400)&&(valuey>400)&&(valuey<450))
	mov swap1,47
.elseif((valuex>400)&&(valuex<450)&&(valuey>400)&&(valuey<450))
	mov swap1,48
.endif

;mov bx,0
getswap2:
	mov ax,3
	int 33h
	
	mov valuex,cx
	mov valuey,dx
	cmp bl,2
	je dispp
jmp getswap2


dispp:
.if((valuex>100)&&(valuex<150)&&(valuey>100)&&(valuey<150))
	mov swap2,0 
.elseif((valuex>150)&&(valuex<200)&&(valuey>100)&&(valuey<150))
	mov swap2,1
.elseif((valuex>200)&&(valuex<250)&&(valuey>100)&&(valuey<150))
	mov swap2,2
.elseif((valuex>250)&&(valuex<300)&&(valuey>100)&&(valuey<150))
	mov swap2,3
.elseif((valuex>300)&&(valuex<350)&&(valuey>100)&&(valuey<150))
	mov swap2,4
.elseif((valuex>350)&&(valuex<400)&&(valuey>100)&&(valuey<150))
	mov swap2,5
.elseif((valuex>400)&&(valuex<450)&&(valuey>100)&&(valuey<150))
	mov swap2,6
	
	
.elseif((valuex>100)&&(valuex<150)&&(valuey>150)&&(valuey<200))
	mov swap2,7
.elseif((valuex>150)&&(valuex<200)&&(valuey>150)&&(valuey<200))
	mov swap2,8
.elseif((valuex>200)&&(valuex<250)&&(valuey>150)&&(valuey<200))
	mov swap2,9
.elseif((valuex>250)&&(valuex<300)&&(valuey>150)&&(valuey<200))
	mov swap2,10
.elseif((valuex>300)&&(valuex<350)&&(valuey>150)&&(valuey<200))
	mov swap2,11
.elseif((valuex>350)&&(valuex<400)&&(valuey>150)&&(valuey<200))
	mov swap2,12
.elseif((valuex>400)&&(valuex<450)&&(valuey>150)&&(valuey<200))
	mov swap2,13


.elseif((valuex>100)&&(valuex<150)&&(valuey>200)&&(valuey<250))
	mov swap2,14
.elseif((valuex>150)&&(valuex<200)&&(valuey>200)&&(valuey<250))
	mov swap2,15
.elseif((valuex>200)&&(valuex<250)&&(valuey>200)&&(valuey<250))
	mov swap2,16
.elseif((valuex>250)&&(valuex<300)&&(valuey>200)&&(valuey<250))
	mov swap2,17
.elseif((valuex>300)&&(valuex<350)&&(valuey>200)&&(valuey<250))
	mov swap2,18
.elseif((valuex>350)&&(valuex<400)&&(valuey>200)&&(valuey<250))
	mov swap2,19
.elseif((valuex>400)&&(valuex<450)&&(valuey>200)&&(valuey<250))
	mov swap2,20



.elseif((valuex>100)&&(valuex<150)&&(valuey>250)&&(valuey<300))
	mov swap2,21
.elseif((valuex>150)&&(valuex<200)&&(valuey>250)&&(valuey<300))
	mov swap2,22
.elseif((valuex>200)&&(valuex<250)&&(valuey>250)&&(valuey<300))
	mov swap2,23
.elseif((valuex>250)&&(valuex<300)&&(valuey>250)&&(valuey<300))
	mov swap2,24
.elseif((valuex>300)&&(valuex<350)&&(valuey>250)&&(valuey<300))
	mov swap2,25
.elseif((valuex>350)&&(valuex<400)&&(valuey>250)&&(valuey<300))
	mov swap2,26
.elseif((valuex>400)&&(valuex<450)&&(valuey>250)&&(valuey<300))
	mov swap2,27
	

.elseif((valuex>100)&&(valuex<150)&&(valuey>300)&&(valuey<350))
	mov swap2,28
.elseif((valuex>150)&&(valuex<200)&&(valuey>300)&&(valuey<350))
	mov swap2,29
.elseif((valuex>200)&&(valuex<250)&&(valuey>300)&&(valuey<350))
	mov swap2,30
.elseif((valuex>250)&&(valuex<300)&&(valuey>300)&&(valuey<350))
	mov swap2,31
.elseif((valuex>300)&&(valuex<350)&&(valuey>300)&&(valuey<350))
	mov swap2,32
.elseif((valuex>350)&&(valuex<400)&&(valuey>300)&&(valuey<350))
	mov swap2,33
.elseif((valuex>400)&&(valuex<450)&&(valuey>300)&&(valuey<350))
	mov swap2,34	


.elseif((valuex>100)&&(valuex<150)&&(valuey>350)&&(valuey<400))
	mov swap2,35
.elseif((valuex>150)&&(valuex<200)&&(valuey>350)&&(valuey<400))
	mov swap2,36
.elseif((valuex>200)&&(valuex<250)&&(valuey>350)&&(valuey<400))
	mov swap2,37
.elseif((valuex>250)&&(valuex<300)&&(valuey>350)&&(valuey<400))
	mov swap2,38
.elseif((valuex>300)&&(valuex<350)&&(valuey>350)&&(valuey<400))
	mov swap2,39
.elseif((valuex>350)&&(valuex<400)&&(valuey>350)&&(valuey<400))
	mov swap2,40
.elseif((valuex>400)&&(valuex<450)&&(valuey>350)&&(valuey<400))
	mov swap2,41
	


.elseif((valuex>100)&&(valuex<150)&&(valuey>400)&&(valuey<450))
	mov swap2,42
.elseif((valuex>150)&&(valuex<200)&&(valuey>400)&&(valuey<450))
	mov swap2,43
.elseif((valuex>200)&&(valuex<250)&&(valuey>400)&&(valuey<450))
	mov swap2,44
.elseif((valuex>250)&&(valuex<300)&&(valuey>400)&&(valuey<450))
	mov swap2,45
.elseif((valuex>300)&&(valuex<350)&&(valuey>400)&&(valuey<450))
	mov swap2,46
.elseif((valuex>350)&&(valuex<400)&&(valuey>400)&&(valuey<450))
	mov swap2,47
.elseif((valuex>400)&&(valuex<450)&&(valuey>400)&&(valuey<450))
	mov swap2,48
.endif
	mov ax,swap2
	add ax,1
.if(swap1==ax)
	
	jmp doswap
.endif
	mov ax,swap2
	sub ax,1
.if(swap1==ax)
	jmp doswap
.endif

	mov ax,swap2
	sub ax,7
.if(swap1==ax)
	jmp doswap
.endif
	mov ax,swap2
	add ax,7
.if(swap1==ax)
	jmp doswap
.endif

	
	jmp endswap
	

doswap:
mov si,swap1
mov al,mainarray[si]
mov	si,swap2
mov ah,mainarray[si]
mov mainarray[si],al
mov si,swap1
mov mainarray[si],ah
dec moves

endswap:
	ret
checkswap endp

checkcombos proc
	




mov si,swap2
mov al,mainarray[si]
.if((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si+2]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si+2],dl
	add scorelvl1,10

.elseif((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si-1]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si-1],dl
	add scorelvl1,10

.elseif((mainarray[si]==al)&&(mainarray[si-1]==al)&&(mainarray[si-2]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-1],dl
	call numrand
	mov mainarray[si-2],dl
	add scorelvl1,10

.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si+14]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si+14],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si-7]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si-7],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si-7]==al)&&(mainarray[si-14]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-7],dl
	call numrand
	mov mainarray[si-14],dl
	add scorelvl1,10
.endif


mov si,swap1
mov al,mainarray[si]
.if((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si+2]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si+2],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si-1]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si-1],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si-1]==al)&&(mainarray[si-2]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-1],dl
	call numrand
	mov mainarray[si-2],dl
	add scorelvl1,10

.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si+14]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si+14],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si-7]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si-7],dl
	add scorelvl1,10
.elseif((mainarray[si]==al)&&(mainarray[si-7]==al)&&(mainarray[si-14]==al))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-7],dl
	call numrand
	mov mainarray[si-14],dl
	add scorelvl1,10
.endif

endcombos:

ret


checkcombos endp


updateboard proc

mov	changex,  100
mov	changey, 100

mov	x , 100
mov	y , 100

mov	xcord , 100
mov	ycord , 110

	call clearscreen
	mov ah, 00h
	mov al, 12h
	int 10h
	call DisplayNameOnBoard
	call drawboxes	
	

	mov display,0
	mov cx,7
	ploop:
		mov ptemp,cx
		call populate
		mov ax,xcord
		sub ax,350
		mov xcord,ax
		mov ax,ycord
		add ax,50
		mov ycord,ax
		
		mov cx,ptemp
	loop ploop

ret

updateboard endp


;;Function that calls other fuctions to output the intial display screen before the game begins
;;
DisplayInitialScreen proc
	mov bh,0
	mov ah,0h
	mov al,12h
	int 10h
	
	mov ah, 0bh
	mov bh, 00h
	mov bl, 04
	int 10h
	
	call DisplayWelcome
	call DisplayNameMsg
	call inputPlayerName

	ret
DisplayInitialScreen endp

;;Function that calls other fuctions to output the display page for rules screen before the game begins
;;
DisplayRulesScreen proc
	mov bh,1
	mov ah,0h
	mov al,12h
	int 10h
	
	call DisplayRules
	call DisplayRulesExplained
	call RulesContinuePrompt

	ret
DisplayRulesScreen endp

;;Function that displays welcome msg
;;
DisplayWelcome proc
	mov dh, 2
	mov dl, 27
	mov si, 0
	
	printWelcomeMsg:
		mov ah, 02
		int 10h
		mov ah, 09
		mov al, WelcomeMsg[si]
		mov bh, 0
		mov bl, 0bh
		mov cx,1
		int 10h	
		
		inc dx
		inc si
		cmp WelcomeMsg[si], "$"
		jne printWelcomeMsg
	
	ret
DisplayWelcome endp

;;Function that takes input of User's name.
;;
inputPlayerName proc
	mov dl, 42 ;column
	mov dh, 13 ;row
	mov ah, 02
	int 10h
	
	mov si, offset UserName
	mov ax, ' '
	mov [si], ax
	inc si
;	mov dx,' '
;	mov ah,02h
;	int 21h
	
	inputChar:
		mov ah, 01h
		int 21h
		mov [si], al
		inc si
		cmp al, 13
		jne inputChar
	
	;dec si
	dec si
	mov ax,'$'
	mov [si],ax

	ret	
inputPlayerName endp

;;Function that displays message to ask user to enter their name
;;
DisplayNameMsg proc
	mov dl, 18 ;column
	mov dh, 13 ;row
	mov si, 0
	
	PrintEnterName:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, EnterNameMSG[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp EnterNameMSG[si], "$"
		jne PrintEnterName 	
	
	ret
DisplayNameMsg endp

;;Function that displays 'Rules' on top of the rules page.
;;
DisplayRules proc
	mov dh, 2
	mov dl, 34
	mov si, 0
	
	printRulesMsg:
		mov ah, 02
		int 10h
		mov ah, 09h
		mov al, RulesMsg[si]
		mov bh, 0
		mov bl, 0Bh
		mov cx,1
		int 10h	
		
		inc dx
		inc si
		cmp RulesMsg[si], "$"
		jne printRulesMsg
	
	ret
DisplayRules endp

;;Function that displays rules of the game step wise.
;;
DisplayRulesExplained proc
	mov dh, 8	;row
	mov dl, 8	;column
	mov si, 0
	
	PrintRulesExplained:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, RulesExplainedMsg[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		
		cmp RulesExplainedMsg[si], 0ah
		jne here
		mov dl,8
		inc dh
		here:
			cmp RulesExplainedMsg[si], "$"
			jne PrintRulesExplained 
	
	ret
DisplayRulesExplained endp

;;Function that gives a prompt to the user on the rules page in order to continue to the game.
;;
RulesContinuePrompt proc
	
	print:
		mov ah,00h
		int 16h
		
		cmp al,13
		je Ext
		
		mov dl,al
		mov ah,02h
		int 21h
		jmp print
		Ext:

	ret	
RulesContinuePrompt endp

;;
;;
DisplayNameOnBoard proc
	mov bh,2
	mov ah,0h
	mov al,12h
	int 10h
	
	mov dl, 62 ;column
	mov dh, 08 ;row
	mov si, 0
	
	PrintNameOnBoard:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, UserName[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp UserName[si], "$"
		jne PrintNameOnBoard
	
	call DisplayMovesOnBoard
	call DisplayscoresOnBoard
	ret
DisplayNameOnBoard endp

;;
;;
pause proc
	mov cx,300
	
	pause1:
		mov dx,300
		pause2:
			dec dx
			cmp dx,0	
		jne pause2
	loop pause1
	
	ret
pause endp

;;
;;
numrand proc     
	call pause
 	mov ah, 00h          
 	int 1ah      
 	mov  ax, dx
 	xor  dx, dx
 	mov  cx, 5  
	div  cx       
   	mov random,dl
 	mov random,dl
      
	ret
numrand endp

;;
;;
DisplayMovesOnBoard proc
	mov dl, 60 ;column
	mov dh, 10 ;row
	mov si, 0
	
	PrintMovesString:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, MovesLeftMsg[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp MovesLeftMsg[si], "$"
		jne PrintMovesString
	
		mov movescount,0
		mov ax,moves
		mov movestemp,ax
	displaymoves:
	
		
		mov ax,movestemp
		mov dx,0
		mov bx,10
		div bx
		push dx
		mov movestemp,ax	
		inc movescount
		
		cmp ax,0
	
	je popmoves
	jne displaymoves
	
	popmoves:
	
		cmp movescount,0
		je endmoves 
		pop dx
		add dx,48
		mov ah,02h
		int 21h
		dec movescount 
		jmp popmoves
	endmoves:
	
	ret
DisplayMovesOnBoard endp

DisplayscoresOnBoard proc
	mov dl, 62 ;column
	mov dh, 12 ;row
	mov si, 0
	
	PrintscoresString:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, scoremsg[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp scoremsg[si], "$"
		jne PrintscoresString
	
		mov scorecount,0
		mov ax,scorelvl1
		mov scoretemp,ax
	displayscore:
	
		
		mov ax,scoretemp
		mov dx,0
		mov bx,10
		div bx
		push dx
		mov scoretemp,ax	
		inc scorecount
		
		cmp ax,0
	
	je popscores
	jne displayscore
	
	popscores:
	
		cmp scorecount,0
		je endscores 
		pop dx
		add dx,48
		mov ah,02h
		int 21h
		dec scorecount 
		jmp popscores
	endscores:
	
	ret
DisplayscoresOnBoard endp


;;
;;
verticalline proc
	mov cx,350
	
	l1:
		mov temp,cx
			
		mov ah, 0ch
		mov al, 0FH

		mov cx, changex
		inc changex
		mov dx, changey
		int 10h
		mov cx,temp
	loop l1
	
	ret 
verticalline endp

;;
;;
horizontalline proc
	mov cx,350
	
	l1:
		mov temp,cx
			
		mov ah, 0ch
		mov al, 0FH

		mov cx, changex
		mov dx, changey
		inc changey
		int 10h
		mov cx,temp
	loop l1
	ret 
horizontalline endp

;;
;;
circleline proc
	l1:
		mov temp,cx
			
		mov ah, 0ch
		mov al, 0fH
		
		mov cx, temp1
		inc temp1
		mov dx, y
		int 10h
		mov cx,temp
	loop l1
	
	ret 
circleline endp

;;
;;
circle proc
	mov cx,4
	mov ax,x
	mov temp1,ax
	
	call circleline
	
	inc y
	sub x,2
	mov cx,8
	mov ax,x
	mov temp1,ax
	
	call circleline
	
	sub x,2
	mov cx,12
	mov ax,x
	mov temp1,ax
	inc y
	
	call circleline
	
	sub x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,16
	
	call circleline
	
	sub x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,20

	call circleline
	
	sub x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,24
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,24
	
	call circleline
	
	sub x,1
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,26
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,26
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,26
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,26
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,26
	
	call circleline
	
	add x,1
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,24
	
	call circleline
	
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,24
	
	call circleline
	
	add x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,20
	
	call circleline
	
	add x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,16
	
	call circleline
	
	add x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,12
	
	call circleline
	
	add x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,8
	
	call circleline
	
	add x,2
	mov ax,x
	mov temp1,ax
	inc y
	mov cx,4
	
	call circleline

	ret
circle endp

;;
;;
printx2 proc
	print5:
		dec bx
		dec x
		mov ah, 0ch
		mov al, 02h
		mov cx, x
		mov dx, y 
		int 10h
		cmp bx,0
		jne print5
	
	ret
printx2 endp

;;
;;
printy2 proc
	print5:
		dec bx
		inc x
		mov ah, 0ch
		mov al, 02h
		mov cx, x
		mov dx, y 
		int 10h
		cmp bx,0
		jne print5
	ret

printy2 endp

;;
;;
rhombus proc
	mov bx,1
	inc y
	call printy2
	mov bx,2
	inc y
	call printx2
	mov bx,3
	inc y
	call printy2
	mov bx,4
	inc y
	call printx2

	mov bx,5
	inc y
	call printy2
	mov bx,6
	inc y
	call printx2
	mov bx,7
	inc y	
	call printy2
	inc y 
	mov bx,8
	call printx2
	inc y
	mov bx, 9
	call printy2
	inc y
	mov bx,10
	call printx2
	inc y
	mov bx,11
	call printy2
	inc y
	mov bx,12
	call printx2
	inc y
	mov bx,13
	call printy2
	inc y 
	mov bx,14
	call printx2
	inc y 
	mov bx,13
	call printy2
	inc y
	mov bx,12
	call printx2
	mov bx,11
	inc y
	call printy2
	mov bx,10
	inc y
	call printx2
	mov bx,9
	inc y
	call printy2
	mov bx,8
	inc y
	call printx2
	mov bx,7
	inc y
	call printy2
	mov bx,6
	inc y 
	call printx2
	mov bx,5
	inc y
	call printy2
	mov bx,4
	inc y
	call printx2
	mov bx,3
	inc y
	call printy2
	mov bx,2
	inc y
	call printx2
	mov bx,1
	inc y
	call printy2
	
	ret
rhombus endp




blockageline proc
	mov cx,50
	
	block:
	mov temp,cx
		
	mov ah, 0ch
	mov al, 0fH

	mov cx, x
	inc x
	mov dx, y
	int 10h
	mov cx,temp
	loop block
	
	ret 
blockageline endp

;;
;;
drawblockage proc
	mov temp1,50
	
	lpp:
		call blockageline
		mov ax,x
		sub ax,50
		mov x,ax
		inc y
		dec temp1
		cmp temp1,0
		je endd
		jne lpp
	endd:

	ret
drawblockage endp

;;
;;




squareline proc
	mov cx,30
	
	l1:
	mov temp,cx
		
	mov ah, 0ch
	mov al, 0dH

	mov cx, x
	inc x
	mov dx, y
	int 10h
	mov cx,temp
	loop l1
	
	ret 
squareline endp

;;
;;
drawsquare proc
	mov temp1,30
	
	lp:
		call squareline
		mov ax,x
		sub ax,30
		mov x,ax
		inc y
		dec temp1
		cmp temp1,0
		je endd
		jne lp
	endd:

	ret
drawsquare endp

;;
;;
printxx proc
	print1:
		dec bx
		dec x
		mov ah, 0ch
		mov al, 0eh
		mov cx, x; CX = 10
		mov dx, y ; DX = 20
		int 10h
		cmp bx,0
		jne print1
	ret
printxx endp

;;
;;
printyy proc
	print1:
		dec bx
		inc x
		mov ah, 0ch
		mov al, 0eh
		mov cx, x; CX = 10
		mov dx, y ; DX = 20
		int 10h
		cmp bx,0
		jne print1
	ret
printyy endp

;;
;;
inverted proc
	inc y
	mov bx,24
	call printxx
	mov bx,23
	inc y
	call printyy
	mov bx,22
	inc y
	call printxx
	mov bx,21
	inc y
	call printyy
	inc y 
	mov bx,20
	call printxx
	inc y
	mov bx,19
	call printyy
	inc y
	mov bx,18
	call printxx
	inc y
	mov bx,17
	call printyy
	inc y
	mov bx,16
	call printxx
	inc y
	mov bx,15
	call printyy
	inc y 
	mov bx,14
	call printxx
	inc y 
	mov bx,13
	call printyy
	inc y
	mov bx,12
	call printxx
	mov bx,11
	inc y
	call printyy
	mov bx,10
	inc y
	call printxx
	mov bx,9
	inc y
	call printyy
	mov bx,8
	inc y
	call printxx
	mov bx,7
	inc y
	call printyy
	mov bx,6
	inc y 
	call printxx
	mov bx,5
	inc y
	call printyy
	mov bx,4
	inc y
	call printxx
	mov bx,3
	inc y
	call printyy
	mov bx,2
	inc y
	call printxx
	mov bx,1
	inc y
	call printyy
	
	ret
inverted endp

;;
;;
printxxx proc
	print1:
		dec bx
		inc x
		MOV AH, 0Ch
		MOV AL, 04h
		MOV CX, x; CX = 10
		MOV DX, y ; DX = 20
		INT 10H
		cmp bx,0
		jne print1
		
	ret
printxxx endp

;;
;;
printyyy proc
	print1:
		dec bx
		dec x
		MOV AH, 0Ch
		MOV AL, 04h
		MOV CX, x; CX = 10
		MOV DX, y ; DX = 20
		INT 10H
		cmp bx,0
		jne print1

	ret
printyyy endp

;;
;;
running proc
	inc y
	mov bx,1
	call printxxx
	mov bx,2
	inc y
	call printyyy
	mov bx,3
	inc y
	call printxxx
	mov bx,4
	inc y
	call printyyy
	inc y 
	mov bx,5
	call printxxx
	inc y
	mov bx,6
	call printyyy
	inc y
	mov bx,7
	call printxxx
	inc y
	mov bx,8
	call printyyy
	inc y
	mov bx,9
	call printxxx
	inc y
	mov bx,10
	call printyyy
	inc y 
	mov bx,11
	call printxxx
	inc y 
	mov bx,12
	call printyyy
	inc y
	mov bx,13
	call printxxx
	mov bx,14
	inc y
	call printyyy
	mov bx,15
	inc y
	call printxxx
	mov bx,16
	inc y
	call printyyy
	mov bx,17
	inc y
	call printxxx
	mov bx,18
	inc y
	call printyyy
	mov bx,19
	inc y 
	call printxxx
	mov bx,20
	inc y
	call printyyy
	mov bx,21
	inc y
	call printxxx
	mov bx,22
	inc y
	call printyyy
	mov bx,23
	inc y
	call printxxx
	mov bx,24
	inc y
	call printyyy
	
	ret
running endp

producerand proc

	mov si,0
	mov counter,0
	
	randloop:


	call numrand
	mov mainarray[si],dl
	inc si
	inc counter


	cmp counter,49
	jne randloop
	mov counter,0
	mov si,0
	mov mainarray[si],6
	mov si,48
	mov mainarray[si],6
	
	ret


producerand endp



;;
;;
populate proc
	mov si,display
	mov looptemp,7
	inn:
		
		cmp mainarray[si],0
		je drawcircle
		cmp mainarray[si],1
		je square
		cmp mainarray[si],2
		je roombus
		cmp mainarray[si],3
		je uptri
		cmp mainarray[si],4
		je lowtri
		cmp mainarray[si],6
		je bombbomb
		cmp mainarray[si],10
		je blockageb
	drawcircle:
		mov ax,xcord
		mov x,ax
		add x,20
		mov ax,ycord
		mov y,ax
		call circle
		add xcord,50
		jmp notequal

	square:
		mov ax,xcord
		mov x,ax
		add x,10
		mov ax,ycord
		mov y,ax
		call drawsquare
		add xcord,50
		jmp notequal
	roombus:
		mov ax,xcord
		mov x,ax
		add x,25
		mov ax,ycord
		mov y,ax
		call rhombus
		add xcord,50
		jmp notequal
	
	uptri:
		mov ax,xcord
		mov x,ax
		add x,25
		mov ax,ycord
		mov y,ax
		call running
		add xcord,50
		jmp notequal

	lowtri:
		mov ax,xcord
		mov x,ax
		add x,35
		mov ax,ycord
		mov y,ax
		call inverted
		add xcord,50
		jmp notequal
	bombbomb:
		mov ax,xcord
		mov x,ax
		add x,10
		mov ax,ycord
		mov y,ax
		add y,10
		call drawbomb	
		add xcord,50
		jmp notequal
	blockageb:
		mov ax,xcord
		mov x,ax
		mov ax,ycord
		mov y,ax
		sub y,10
		call drawblockage
		add xcord,50
		jmp notequal
	notequal:
		inc si
		dec looptemp
		cmp looptemp,0
		jne inn
		mov display,si
	ret
populate endp

;;
;;
hline proc
	mov cx,30

	l1:
		mov temp,cx
			
		mov ah, 0ch
		mov al, 09H

		mov cx, x
		inc x
		mov dx, y
		int 10h
		mov cx,temp
		loop l1
		
	ret 
hline endp

;;
;;
vline proc
	mov cx,30

	l1:
		mov temp,cx
			
		mov ah, 0ch
		mov al, 01H

		mov cx,x

		mov dx,y
		inc y	
		int 10h
		mov cx,temp
		loop l1
	ret 
vline endp

;;
;;
drawbomb proc
	mov temp1,10
	lp:
		call hline
		mov ax,x
		sub ax,30
		mov x,ax
		inc y
		dec temp1
		cmp temp1,0
		je endd
		jne lp
	
	endd:
		mov ax,y
		sub ax,20
		mov y,ax
		mov ax,x
		add ax , 10
		mov x,ax

		mov temp1,10
	
	lp1:
		call vline
		mov ax,y
		sub ax,30
		mov y,ax
		inc x
		dec temp1
		cmp temp1,0
		je endd1
		jne lp1

	endd1:
	
	ret
drawbomb endp

;;
;;
firstrow proc
	mov ax,xcord
	mov x,ax
	add x,10
	mov ax,ycord
	mov y,ax
	add y,10
	call drawbomb	

	add xcord,50

	mov looptemp,5

	inn:
		call numrand
		;mov ah,02h
		;int 21h
		cmp random,0
		je drawcircle
		cmp random,1
		je square
		cmp random,2
		je roombus
		cmp random,3
		je uptri
		cmp random,4
		je lowtri


	drawcircle:
		mov ax,xcord
		mov x,ax
		add x,20
		mov ax,ycord
		mov y,ax
		call circle
		add xcord,50
		jmp notequal

	square:
		mov ax,xcord
		mov x,ax
		add x,10
		mov ax,ycord
		mov y,ax
		call drawsquare
		add xcord,50
		jmp notequal
		
	roombus:
		mov ax,xcord
		mov x,ax
		add x,25
		mov ax,ycord
		mov y,ax
		call rhombus
		add xcord,50
		jmp notequal
		
	uptri:
		mov ax,xcord
		mov x,ax
		add x,25
		mov ax,ycord
		mov y,ax
		call running
		add xcord,50
		jmp notequal

	lowtri:
		mov ax,xcord
		mov x,ax
		add x,35
		mov ax,ycord
		mov y,ax
		call inverted
		add xcord,50
		jmp notequal

	notequal:
		dec looptemp
		cmp looptemp,0
		jne inn
		
	mov ax,xcord
	mov x,ax
	add x,10
	mov ax,ycord
	mov y,ax
	add y,10
	call drawbomb	
	
	add xcord,50

	ret
firstrow endp

;;
;;
drawboxes proc
	;mov bh,2
	;mov ah,0h
	;mov al,12h
	;int 10h
	
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0

	call verticalline	
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	sub changex,350
	add changey,50
	
	call verticalline
	mov changex,100
	mov changey,100
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	call horizontalline
	sub changey,350
	add changex,50
	
	
	
	call horizontalline
	mov changex,100
	mov changey,100

	ret 
drawboxes endp

;for level 3
;
producerandlvl3 proc

	mov si,0
	mov counter,0
	
	randloop3:


	call numrand
	mov mainarray[si],dl
	inc si
	inc counter


	cmp counter,49
	jne randloop3
	mov counter,0
	mov si,0
	mov mainarray[si],6
	mov si,48
	mov mainarray[si],6
	
	mov mainarray[21],10
	mov mainarray[22],10
	mov mainarray[23],10
	mov mainarray[24],10
	mov mainarray[25],10
	mov mainarray[26],10
	mov mainarray[27],10
	
	mov mainarray[3],10
	mov mainarray[10],10
	mov mainarray[17],10
	mov mainarray[24],10
	mov mainarray[31],10
	mov mainarray[38],10
	mov mainarray[45],10
	
	
	
	
	
	ret


producerandlvl3 endp


checkswaplvl3 proc

	mov ax,1
	int 33h
	
	;mov ax,4
	;int 33h
getswap1lvl3:
	mov ax,3
	int 33h
	
	mov valuex,cx
	mov valuey,dx
	cmp bl,1
	je displvl3
jmp getswap1lvl3
	
displvl3:
.if((valuex>100)&&(valuex<150)&&(valuey>100)&&(valuey<150))
	mov swap1,0 
.elseif((valuex>150)&&(valuex<200)&&(valuey>100)&&(valuey<150))
	mov swap1,1
.elseif((valuex>200)&&(valuex<250)&&(valuey>100)&&(valuey<150))
	mov swap1,2
.elseif((valuex>250)&&(valuex<300)&&(valuey>100)&&(valuey<150))
	mov swap1,3
.elseif((valuex>300)&&(valuex<350)&&(valuey>100)&&(valuey<150))
	mov swap1,4
.elseif((valuex>350)&&(valuex<400)&&(valuey>100)&&(valuey<150))
	mov swap1,5
.elseif((valuex>400)&&(valuex<450)&&(valuey>100)&&(valuey<150))
	mov swap1,6
	
	
.elseif((valuex>100)&&(valuex<150)&&(valuey>150)&&(valuey<200))
	mov swap1,7
.elseif((valuex>150)&&(valuex<200)&&(valuey>150)&&(valuey<200))
	mov swap1,8
.elseif((valuex>200)&&(valuex<250)&&(valuey>150)&&(valuey<200))
	mov swap1,9
.elseif((valuex>250)&&(valuex<300)&&(valuey>150)&&(valuey<200))
	mov swap1,10
.elseif((valuex>300)&&(valuex<350)&&(valuey>150)&&(valuey<200))
	mov swap1,11
.elseif((valuex>350)&&(valuex<400)&&(valuey>150)&&(valuey<200))
	mov swap1,12
.elseif((valuex>400)&&(valuex<450)&&(valuey>150)&&(valuey<200))
	mov swap1,13


.elseif((valuex>100)&&(valuex<150)&&(valuey>200)&&(valuey<250))
	mov swap1,14
.elseif((valuex>150)&&(valuex<200)&&(valuey>200)&&(valuey<250))
	mov swap1,15
.elseif((valuex>200)&&(valuex<250)&&(valuey>200)&&(valuey<250))
	mov swap1,16
.elseif((valuex>250)&&(valuex<300)&&(valuey>200)&&(valuey<250))
	mov swap1,17
.elseif((valuex>300)&&(valuex<350)&&(valuey>200)&&(valuey<250))
	mov swap1,18
.elseif((valuex>350)&&(valuex<400)&&(valuey>200)&&(valuey<250))
	mov swap1,19
.elseif((valuex>400)&&(valuex<450)&&(valuey>200)&&(valuey<250))
	mov swap1,20



.elseif((valuex>100)&&(valuex<150)&&(valuey>250)&&(valuey<300))
	mov swap1,21
.elseif((valuex>150)&&(valuex<200)&&(valuey>250)&&(valuey<300))
	mov swap1,22
.elseif((valuex>200)&&(valuex<250)&&(valuey>250)&&(valuey<300))
	mov swap1,23
.elseif((valuex>250)&&(valuex<300)&&(valuey>250)&&(valuey<300))
	mov swap1,24
.elseif((valuex>300)&&(valuex<350)&&(valuey>250)&&(valuey<300))
	mov swap1,25
.elseif((valuex>350)&&(valuex<400)&&(valuey>250)&&(valuey<300))
	mov swap1,26
.elseif((valuex>400)&&(valuex<450)&&(valuey>250)&&(valuey<300))
	mov swap1,27
	

.elseif((valuex>100)&&(valuex<150)&&(valuey>300)&&(valuey<350))
	mov swap1,28
.elseif((valuex>150)&&(valuex<200)&&(valuey>300)&&(valuey<350))
	mov swap1,29
.elseif((valuex>200)&&(valuex<250)&&(valuey>300)&&(valuey<350))
	mov swap1,30
.elseif((valuex>250)&&(valuex<300)&&(valuey>300)&&(valuey<350))
	mov swap1,31
.elseif((valuex>300)&&(valuex<350)&&(valuey>300)&&(valuey<350))
	mov swap1,32
.elseif((valuex>350)&&(valuex<400)&&(valuey>300)&&(valuey<350))
	mov swap1,33
.elseif((valuex>400)&&(valuex<450)&&(valuey>300)&&(valuey<350))
	mov swap1,34	


.elseif((valuex>100)&&(valuex<150)&&(valuey>350)&&(valuey<400))
	mov swap1,35
.elseif((valuex>150)&&(valuex<200)&&(valuey>350)&&(valuey<400))
	mov swap1,36
.elseif((valuex>200)&&(valuex<250)&&(valuey>350)&&(valuey<400))
	mov swap1,37
.elseif((valuex>250)&&(valuex<300)&&(valuey>350)&&(valuey<400))
	mov swap1,38
.elseif((valuex>300)&&(valuex<350)&&(valuey>350)&&(valuey<400))
	mov swap1,39
.elseif((valuex>350)&&(valuex<400)&&(valuey>350)&&(valuey<400))
	mov swap1,40
.elseif((valuex>400)&&(valuex<450)&&(valuey>350)&&(valuey<400))
	mov swap1,41
	


.elseif((valuex>100)&&(valuex<150)&&(valuey>400)&&(valuey<450))
	mov swap1,42
.elseif((valuex>150)&&(valuex<200)&&(valuey>400)&&(valuey<450))
	mov swap1,43
.elseif((valuex>200)&&(valuex<250)&&(valuey>400)&&(valuey<450))
	mov swap1,44
.elseif((valuex>250)&&(valuex<300)&&(valuey>400)&&(valuey<450))
	mov swap1,45
.elseif((valuex>300)&&(valuex<350)&&(valuey>400)&&(valuey<450))
	mov swap1,46
.elseif((valuex>350)&&(valuex<400)&&(valuey>400)&&(valuey<450))
	mov swap1,47
.elseif((valuex>400)&&(valuex<450)&&(valuey>400)&&(valuey<450))
	mov swap1,48
.endif

;mov bx,0
getswap2lvl3:
	mov ax,3
	int 33h
	
	mov valuex,cx
	mov valuey,dx
	cmp bl,2
	je dispplvl3
jmp getswap2lvl3


dispplvl3:
.if((valuex>100)&&(valuex<150)&&(valuey>100)&&(valuey<150))
	mov swap2,0 
.elseif((valuex>150)&&(valuex<200)&&(valuey>100)&&(valuey<150))
	mov swap2,1
.elseif((valuex>200)&&(valuex<250)&&(valuey>100)&&(valuey<150))
	mov swap2,2
.elseif((valuex>250)&&(valuex<300)&&(valuey>100)&&(valuey<150))
	mov swap2,3
.elseif((valuex>300)&&(valuex<350)&&(valuey>100)&&(valuey<150))
	mov swap2,4
.elseif((valuex>350)&&(valuex<400)&&(valuey>100)&&(valuey<150))
	mov swap2,5
.elseif((valuex>400)&&(valuex<450)&&(valuey>100)&&(valuey<150))
	mov swap2,6
	
	
.elseif((valuex>100)&&(valuex<150)&&(valuey>150)&&(valuey<200))
	mov swap2,7
.elseif((valuex>150)&&(valuex<200)&&(valuey>150)&&(valuey<200))
	mov swap2,8
.elseif((valuex>200)&&(valuex<250)&&(valuey>150)&&(valuey<200))
	mov swap2,9
.elseif((valuex>250)&&(valuex<300)&&(valuey>150)&&(valuey<200))
	mov swap2,10
.elseif((valuex>300)&&(valuex<350)&&(valuey>150)&&(valuey<200))
	mov swap2,11
.elseif((valuex>350)&&(valuex<400)&&(valuey>150)&&(valuey<200))
	mov swap2,12
.elseif((valuex>400)&&(valuex<450)&&(valuey>150)&&(valuey<200))
	mov swap2,13


.elseif((valuex>100)&&(valuex<150)&&(valuey>200)&&(valuey<250))
	mov swap2,14
.elseif((valuex>150)&&(valuex<200)&&(valuey>200)&&(valuey<250))
	mov swap2,15
.elseif((valuex>200)&&(valuex<250)&&(valuey>200)&&(valuey<250))
	mov swap2,16
.elseif((valuex>250)&&(valuex<300)&&(valuey>200)&&(valuey<250))
	mov swap2,17
.elseif((valuex>300)&&(valuex<350)&&(valuey>200)&&(valuey<250))
	mov swap2,18
.elseif((valuex>350)&&(valuex<400)&&(valuey>200)&&(valuey<250))
	mov swap2,19
.elseif((valuex>400)&&(valuex<450)&&(valuey>200)&&(valuey<250))
	mov swap2,20



.elseif((valuex>100)&&(valuex<150)&&(valuey>250)&&(valuey<300))
	mov swap2,21
.elseif((valuex>150)&&(valuex<200)&&(valuey>250)&&(valuey<300))
	mov swap2,22
.elseif((valuex>200)&&(valuex<250)&&(valuey>250)&&(valuey<300))
	mov swap2,23
.elseif((valuex>250)&&(valuex<300)&&(valuey>250)&&(valuey<300))
	mov swap2,24
.elseif((valuex>300)&&(valuex<350)&&(valuey>250)&&(valuey<300))
	mov swap2,25
.elseif((valuex>350)&&(valuex<400)&&(valuey>250)&&(valuey<300))
	mov swap2,26
.elseif((valuex>400)&&(valuex<450)&&(valuey>250)&&(valuey<300))
	mov swap2,27
	

.elseif((valuex>100)&&(valuex<150)&&(valuey>300)&&(valuey<350))
	mov swap2,28
.elseif((valuex>150)&&(valuex<200)&&(valuey>300)&&(valuey<350))
	mov swap2,29
.elseif((valuex>200)&&(valuex<250)&&(valuey>300)&&(valuey<350))
	mov swap2,30
.elseif((valuex>250)&&(valuex<300)&&(valuey>300)&&(valuey<350))
	mov swap2,31
.elseif((valuex>300)&&(valuex<350)&&(valuey>300)&&(valuey<350))
	mov swap2,32
.elseif((valuex>350)&&(valuex<400)&&(valuey>300)&&(valuey<350))
	mov swap2,33
.elseif((valuex>400)&&(valuex<450)&&(valuey>300)&&(valuey<350))
	mov swap2,34	


.elseif((valuex>100)&&(valuex<150)&&(valuey>350)&&(valuey<400))
	mov swap2,35
.elseif((valuex>150)&&(valuex<200)&&(valuey>350)&&(valuey<400))
	mov swap2,36
.elseif((valuex>200)&&(valuex<250)&&(valuey>350)&&(valuey<400))
	mov swap2,37
.elseif((valuex>250)&&(valuex<300)&&(valuey>350)&&(valuey<400))
	mov swap2,38
.elseif((valuex>300)&&(valuex<350)&&(valuey>350)&&(valuey<400))
	mov swap2,39
.elseif((valuex>350)&&(valuex<400)&&(valuey>350)&&(valuey<400))
	mov swap2,40
.elseif((valuex>400)&&(valuex<450)&&(valuey>350)&&(valuey<400))
	mov swap2,41
	


.elseif((valuex>100)&&(valuex<150)&&(valuey>400)&&(valuey<450))
	mov swap2,42
.elseif((valuex>150)&&(valuex<200)&&(valuey>400)&&(valuey<450))
	mov swap2,43
.elseif((valuex>200)&&(valuex<250)&&(valuey>400)&&(valuey<450))
	mov swap2,44
.elseif((valuex>250)&&(valuex<300)&&(valuey>400)&&(valuey<450))
	mov swap2,45
.elseif((valuex>300)&&(valuex<350)&&(valuey>400)&&(valuey<450))
	mov swap2,46
.elseif((valuex>350)&&(valuex<400)&&(valuey>400)&&(valuey<450))
	mov swap2,47
.elseif((valuex>400)&&(valuex<450)&&(valuey>400)&&(valuey<450))
	mov swap2,48
.endif
	mov ax,swap2
	add ax,1
.if(swap1==ax)
	
	jmp doswaplvl3
.endif
	mov ax,swap2
	sub ax,1
.if(swap1==ax)
	jmp doswaplvl3
.endif

	mov ax,swap2
	sub ax,7
.if(swap1==ax)
	jmp doswaplvl3
.endif
	mov ax,swap2
	add ax,7
.if(swap1==ax)
	jmp doswaplvl3
.endif

	
	jmp endswaplvl3
	

doswaplvl3:
mov si,swap1
mov al,mainarray[si]
mov	si,swap2
mov ah,mainarray[si]
.if(ah==10)||(al==10)
jmp endswaplvl3
.endif

mov mainarray[si],al
mov si,swap1
mov mainarray[si],ah
dec moves

endswaplvl3:
	ret
checkswaplvl3 endp


checkcomboslvl3 proc
	




mov si,swap2
mov al,mainarray[si]
.if((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si+2]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si+2],dl
	add scorelvl3,10

.elseif((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si-1]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si-1],dl
	add scorelvl3,10

.elseif((mainarray[si]==al)&&(mainarray[si-1]==al)&&(mainarray[si-2]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-1],dl
	call numrand
	mov mainarray[si-2],dl
	add scorelvl3,10

.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si+14]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si+14],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si-7]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si-7],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si-7]==al)&&(mainarray[si-14]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-7],dl
	call numrand
	mov mainarray[si-14],dl
	add scorelvl3,10
.endif


mov si,swap1
mov al,mainarray[si]
.if((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si+2]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si+2],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si+1]==al)&&(mainarray[si-1]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+1],dl
	call numrand
	mov mainarray[si-1],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si-1]==al)&&(mainarray[si-2]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-1],dl
	call numrand
	mov mainarray[si-2],dl
	add scorelvl3,10

.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si+14]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si+14],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si+7]==al)&&(mainarray[si-7]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si+7],dl
	call numrand
	mov mainarray[si-7],dl
	add scorelvl3,10
.elseif((mainarray[si]==al)&&(mainarray[si-7]==al)&&(mainarray[si-14]==al)&&(mainarray[si]!=10))
	call numrand
	mov mainarray[si],dl
	call numrand
	mov mainarray[si-7],dl
	call numrand
	mov mainarray[si-14],dl
	add scorelvl3,10
.endif

endcomboslvl3:

ret


checkcomboslvl3 endp

updateboardlvl3 proc

mov	changex,  100
mov	changey, 100

mov	x , 100
mov	y , 100

mov	xcord , 100
mov	ycord , 110

	call clearscreen
	mov ah, 00h
	mov al, 12h
	int 10h
	call DisplayNameOnBoardlvl3
	call drawboxes	
	

	mov display,0
	mov cx,7
	ploop:
		mov ptemp,cx
		call populate
		mov ax,xcord
		sub ax,350
		mov xcord,ax
		mov ax,ycord
		add ax,50
		mov ycord,ax
		
		mov cx,ptemp
	loop ploop

ret

updateboardlvl3 endp

DisplayNameOnBoardlvl3 proc
	mov bh,2
	mov ah,0h
	mov al,12h
	int 10h
	
	mov dl, 62 ;column
	mov dh, 08 ;row
	mov si, 0
	
	PrintNameOnBoardlvl3:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, UserName[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp UserName[si], "$"
		jne PrintNameOnBoardlvl3
	
	call DisplayMovesOnBoard
	call DisplayscoresOnBoardlvl3
	ret
DisplayNameOnBoardlvl3 endp

DisplayscoresOnBoardlvl3 proc
	mov dl, 62 ;column
	mov dh, 12 ;row
	mov si, 0
	
	PrintscoresStringlvl3:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, scoremsg[si]
		mov bl, 0eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp scoremsg[si], "$"
		jne PrintscoresStringlvl3
	
		mov scorecount,0
		mov ax,scorelvl3
		mov scoretemp,ax
	displayscorelvl3:
	
		
		mov ax,scoretemp
		mov dx,0
		mov bx,10
		div bx
		push dx
		mov scoretemp,ax	
		inc scorecount
		
		cmp ax,0
	
	je popscoreslvl3
	jne displayscorelvl3
	
	popscoreslvl3:
	
		cmp scorecount,0
		je endscoreslvl3 
		pop dx
		add dx,48
		mov ah,02h
		int 21h
		dec scorecount 
		jmp popscoreslvl3
	endscoreslvl3:
	
	ret
DisplayscoresOnBoardlvl3 endp



checkcolourbomblvl3 proc

mov si,swap1
.if(mainarray[si]==6)
	mov si,swap2
	mov al,mainarray[si]
	mov bombtemp,al
	
	mov si,0
	mov bombcounter,0
	
	
loopcheckbomb1lvl3:
	mov al,bombtemp
	cmp mainarray[si],al
jne skiplvl3
	call pause
	call numrand
	mov mainarray[si],dl
	add scorelvl3,5
skiplvl3:
	inc si
	inc bombcounter


	cmp bombcounter,49
	jne loopcheckbomb1lvl3
	
mov si,swap1
call numrand
mov mainarray[si],dl

mov si,swap2
call numrand
mov mainarray[si],dl
	

.endif
	
	mov bombcounter,0
	mov si,0
		
mov si,swap2
.if(mainarray[si]==6)
	mov si,swap1
	mov al,mainarray[si]
	mov bombtemp,al
	
	mov si,0
	mov bombcounter,0
	
	
loopcheckbomb2lvl3:
	mov al,bombtemp
	cmp mainarray[si],al
jne skip1lvl3
	call pause
	call numrand
	mov mainarray[si],dl
	add scorelvl3,5
skip1lvl3:
	inc si
	inc bombcounter


	cmp bombcounter,49
	jne loopcheckbomb2lvl3

	mov si,swap1
	call numrand
	mov mainarray[si],dl

	mov si,swap2
	call numrand
	mov mainarray[si],dl


.endif

	mov si,0
	mov bombcounter,0
	


endbomblvl3:
ret
checkcolourbomblvl3 endp



end main
