; MyOS
; TAB=4

		CYLS 		EQU 10

		ORG		0x7c00			; 이 프로그램이 어디에 read되는가
							; 이 주소는 메모리 
							; 0xeb, 0x4e, 0x90 3 bytes
							; http://www.datadoctor.biz/data_recovery_programming_book_chapter3-page20.html

; 이하는 표준적인 FAT12 포맷 플로피 디스크를 위한 기술DOS Boot Record  Format for FAT12 and FAT16

start:
		JMP		entry
		DB		0x90			; DB = 1byte DW = 2byte DD = 4byte 
		DB		"MyOS    "		; OEM ID(8바이트)
;BIOS Parameter Block
		DW		512			; Bytes Per Sector(512로 해야 함)
		DB		1			; 클러스터 크기(1섹터로 해야 함)
		DW		1			; 예약된 섹터
		DB		2			; FAT 개수(2로 해야 함)
;End of BIOS Parameter Block
		DW		224			; 루트 디렉토리 영역의 크기(보통 224엔트리로 해야 한다)
		DW		2880			; 드라이브 크기(2880섹터로 해야 함)
		DB		0xf0			; 미디어 타입(0xf0로 해야 함)
		DW		9			; FAT영역 길이(9섹터로 해야 함)
		DW		18			; 1트럭에 몇 개의 섹터가 있을까(18로 해야 함)
		DW		2			; 헤드 수(2로 해야 함)
		DD		0			; 파티션을 사용하지 않기 때문에 여기는 반드시 0
		DD		2880			; 드라이브 크기를 한번 더 write
		DB		0,0,0x29		; Extended Boot Signature Record
		DD		0xffffffff		; Volume Serial Number 
		DB		"MyOS-Vol   "		; 디스크 이름(11바이트)
		DB		"FAT12   "		; 포맷 이름(8바이트)
		TIMES 		18 DB 0			

; 프로그램 본체

entry:
		MOV		AX, 0			; 레지스터 초기화
		MOV 		SS,AX
		MOV 		SP,0x7c00 
		MOV 		DS,AX 
;		MOV 		ES,AX 
;		MOV		SI,msg
;putloop:
;		MOV		AL,BYTE [DS:SI]		; 데이터세그먼트는 생략 가능
;		ADD		SI, 1			; SI에 1을 더한다
;		CMP		AL,0
;		JE		fin
;		MOV		AH, 0x0e		; 한 글자 표시 Function
;		MOV		BX, 0xe1		; 칼라 코드
;		INT		0x10			; 비디오 BIOS 호출
;		JMP		putloop
;디스크 읽기						;+++++++++++++++++++++++++++++++++++++++++++++++++++++++
		MOV 		AX,0x0820		; 질문: 왜 바로 ES에 MOV로 넣지않고 AX를 거쳐서 넣는가?
							;+++++++++++++++++++++++++++++++++++++++++++++++++++++++
		MOV 		ES,AX 			; 세그먼트레지스터의 세그먼트 부분[EX:BX] 
							; 0x00007E00~0x0007FFFF guaranteed free for use: 사용해도 문제가 없는 영역 
		MOV 		CH, 0			; 실린더 번호
		MOV 		DH, 0			; 해드 번호
		MOV 		CL, 2			; 섹터  번호 1번은 부트섹터 
readloop:	
		MOV 		SI, 0			; 실패 카운트 할레지스터
retry:		
		MOV 		AH, 0x02 		; 디스크 읽기설정
		MOV 		AL, 1 			; 처리할 섹터 수!!!!! 
		MOV 		BX, 0			; 버퍼 어드레스 : 디스크에서 읽은 데이터를 어디에 저장할 것인쥐![0820:0000]
		MOV 		DL, 0x00 		; 첫번째 하드드라이브 
		INT 		0x13			; 디스크 바이오스
		JNC 		next			; 캐리가 0이면 (에러없을시에) next로 	
		ADD 		SI, 1			; 
		CMP 		SI, 5
		JAE 		error
		MOV 		AH, 0x00
		MOV 		DL, 0x00
		INT 		0x13 			; 디스크 바이오스 다시호출
		JMP 		retry 
next:
		MOV 		AX,ES
		ADD 		AX,0x0020
		MOV 		ES,AX 
		ADD 		CL, 1
		CMP 		CL,18
		JBE 		readloop
		MOV 		CL, 1
		ADD 		DH, 1
		CMP 		DH, 2
		JB 		readloop 
		MOV 		DH, 0
		ADD 		CH, 1
		CMP 		CH,CYLS 
		JB 		readloop   

fin:
		HLT					; 무엇인가 있을 때까지 CPU를 정지시킨다
		JMP		fin			; Endless Loop
error: 		
		MOV 		AX, 0
		MOV 		ES,AX
		MOV 		SI,msg
printloop:
		MOV		AL,[SI]
		ADD		SI, 1			; SI에 1을 더한다
		CMP		AL,0
		JE		fin
		MOV		AH, 0x0e		; 한 글자 표시 function
		MOV		BX, 15			; 칼라 코드
		INT		0x10			; 비디오 BIOS 호출i
		JMP 		printloop
msg:
		DB		0x0a, 0x0a		; 개행을 2개
		DB		"load error"
		DB		0x0a			; 개행
		DB		0

maker:		TIMES		0x01fe-(maker-start) DB 0	; 0x7dfe까지를 0x00로 채우는 명령 510번지 까지.
							; nasm 에서는 RESB와 $를함께 쓸수 없다.

		DB		0x55, 0xaa 		; 여기까지 512byte 즉, 예약된 섹터이다

; 이하는 boot sector이외의 부분을 기술
; FAT 영역과 데이터 영역(클러스터영역) 
done: 		TIMES		0x168000-done DB 0		
