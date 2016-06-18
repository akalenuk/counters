.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\winmm.inc
include \masm32\include\masm32.inc
include \masm32\include\advapi32.inc
include \masm32\include\kernel32.inc
include \masm32\include\comdlg32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\winmm.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comdlg32.lib

.const
eE0 equ 7
eE1 equ 5
eE2 equ 6
eE3 equ 7
eE4 equ 5
eE5 equ 6
eE6 equ 7
eE7 equ 8
eE8 equ 9
eE9 equ 10
eE10 equ 11
eS0 equ 12
eS5 equ 13
eB equ 14
eB0 equ 15
eB1 equ 16
eBW equ 17
eBF equ 18
eRealtimePrint equ 19
eButton equ 21
eBC equ 22
MAXSIZE equ 260
MEMSIZE equ 65536

MAX_COUNTERS equ 16

.data 
ClassName db "SimpleWinClass",0
AppName  db " ",0
MenuName db "NoMenu",0
ButtonClassName db "button",0
StaticClassName db "static",0
EditClassName db "edit",0
sProgramWindowHandler db "Program window handler: ",0
sCopyToClipboard db "Copy to clipboard?",0
sProfileResults db "Shpion report:",0
sNone db 0
sEOL db 13,10,0
sSp db 9,0
sDash db "-",0
s0 db " 0:",0
s1 db " 1:",0
s2 db " 2:",0
s3 db " 3:",0
s4 db " 4:",0
s5 db " 5:",0
s6 db " 6:",0
s7 db " 7:",0
s8 db " 8:",0
s9 db " 9:",0
s10 db "10: ",0
s100 db "100",0
sA db "0",0
sB db "%",0
sB0 db "0",0
sB1 db "N",0
sBW db "W",0
sBF db "F",0
sRealtimePrint db "Realtime print",0
sBC db "C",0

s03 db "0-3", 0
s47 db "4-7", 0
s8B db "8-B", 0
sCF db "C-F", 0


cT DWORD 0
T0 DWORD 0
T1 DWORD 0
T2 DWORD 0
T3 DWORD 0
T4 DWORD 0
T5 DWORD 0
T6 DWORD 0
T7 DWORD 0
T8 DWORD 0
T9 DWORD 0
T10 DWORD 0
cA DWORD 0
A0 DWORD 0
A1 DWORD 0
A2 DWORD 0
A3 DWORD 0
A4 DWORD 0
A5 DWORD 0
A6 DWORD 0
A7 DWORD 0
A8 DWORD 0
A9 DWORD 0
A10 DWORD 0
q100 QWORD 100.0

ofn OPENFILENAME <>

FilterString    db "Shpion reports",0,"*.shr",0 
                                db "All Files",0,"*.*",0,0
sLog db ".shr",0
Button_count DWORD 0

sCLeft  db "SendMessage((HWND)",0
sCRight db ",WM_USER,,);",0

.data?
chE HWND ?
hE0 HWND ?
hE1 HWND ?
hE2 HWND ?
hE3 HWND ?
hE4 HWND ?
hE5 HWND ?
hE6 HWND ?
hE7 HWND ?
hE8 HWND ?
hE9 HWND ?
hE10 HWND ?
hB HWND ?
hButton HWND ?
hB0 HWND ?
hB1 HWND ?
hBW HWND ?
hBF HWND ?
hRealtimePrint HWND ?
hBC HWND ?
hS0 HWND ?
hS5 HWND ?

hCounters HWND 16 dup(?)

hInstance HINSTANCE ?
CommandLine LPSTR ?
buffer db 512 dup(?)
buf1 db 16 dup(?)
sHWND db 16 dup(?)
text db 65536 dup(?)
hand DWORD ?
addre DWORD ?
float QWORD ?
hFile HANDLE ?
hMemory HANDLE ?
pMemory DWORD ?
SizeReadWrite DWORD ?
do_realtime_print db ?
fqTemp QWORD ?


.code
start:
        invoke GetModuleHandle, NULL
        mov hInstance,eax
        invoke GetCommandLine
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
        invoke ExitProcess,eax


WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
        LOCAL wc:WNDCLASSEX
        LOCAL msg:MSG
        LOCAL hwnd:HWND
        mov wc.cbSize,SIZEOF WNDCLASSEX
        mov wc.style, CS_HREDRAW or CS_VREDRAW
        mov wc.lpfnWndProc, OFFSET WndProc
        mov wc.cbClsExtra,NULL
        mov wc.cbWndExtra,NULL
        push hInst
        pop wc.hInstance
        mov wc.hbrBackground,COLOR_BTNFACE+1
        mov wc.lpszMenuName,OFFSET MenuName
        mov wc.lpszClassName,OFFSET ClassName
        invoke LoadIcon,hInstance,500
        mov wc.hIcon,eax
        invoke LoadIcon,hInstance,501
        mov wc.hIconSm,eax
        invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,eax
        invoke RegisterClassEx, addr wc
        invoke CreateWindowEx,WS_EX_LEFT, ADDR ClassName, ADDR AppName,\
                WS_OVERLAPPEDWINDOW - WS_MAXIMIZEBOX,CW_USEDEFAULT,\
                CW_USEDEFAULT, 420, 160, NULL, NULL,\
                hInst,NULL
        mov hwnd,eax
        invoke ShowWindow, hwnd,SW_SHOWNORMAL
        invoke UpdateWindow, hwnd
        .WHILE TRUE
                invoke GetMessage, ADDR msg, NULL, 0, 0
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
        .ENDW
        mov eax,msg.wParam
        ret
WinMain endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        LOCAL rect:RECT
        LOCAL dWnd:HWND
        LOCAL syst:SYSTEMTIME      
        LOCAL hKey:DWORD
        LOCAL Disp:DWORD
        LOCAL i:DWORD
        LOCAL x:DWORD
        LOCAL y:DWORD
        
        .IF uMsg==WM_DESTROY
                invoke PostQuitMessage,NULL
        ; Setting up UI
        .ELSEIF uMsg==WM_CREATE
                invoke dwtoa, hWnd, ADDR sHWND
                invoke SetWindowText,hWnd, ADDR sHWND

                ; set initial window position  
                invoke GetDesktopWindow
                mov dWnd,eax
                invoke GetWindowRect,dWnd, ADDR rect
                mov eax,rect.right
                sub eax, 500
                invoke SetWindowPos, hWnd, HWND_TOPMOST, eax, 45, 0, 0, SWP_NOSIZE

                ; counters
                mov i, 0
                .repeat
                        mov eax, i
                        shr eax, 2
                        mov ebx, 22
                        mul ebx
                        add eax, 30
                        mov y, eax
                                                
                        mov eax, i
                        and eax, 11b
                        mov ebx, 88
                        mul ebx
                        add eax, 42
                        mov x, eax
                                                
                        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, ADDR sA,\
                                WS_CHILD or WS_VISIBLE or ES_LEFT or ES_AUTOHSCROLL,\
                                x, y, 84, 18, hWnd, i, hInstance, NULL
                        mov esi, offset hCounters
                        mov ecx, i
                        mov [esi + ecx*4], eax
                        inc i
                .until i==MAX_COUNTERS

                ; labels
                invoke CreateWindowEx, NULL, ADDR StaticClassName, ADDR s03,\
                        WS_CHILD or WS_VISIBLE,\
                        15, 32, 25, 20, hWnd, eS0, hInstance, NULL
                invoke CreateWindowEx, NULL, ADDR StaticClassName, ADDR s47,\
                        WS_CHILD or WS_VISIBLE,\
                        15, 54, 25, 20, hWnd, eS0, hInstance, NULL
                invoke CreateWindowEx, NULL, ADDR StaticClassName, ADDR s8B,\
                        WS_CHILD or WS_VISIBLE,\
                        15, 76, 25, 20, hWnd, eS0, hInstance, NULL
                invoke CreateWindowEx, NULL, ADDR StaticClassName, ADDR sCF,\
                        WS_CHILD or WS_VISIBLE,\
                        15, 98, 25, 20, hWnd, eS0, hInstance, NULL

                ; buttons
                invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR sB0,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        2, 2, 21, 21, hWnd, eB0, hInstance, NULL
                mov hB0, eax

                invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR sBW,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        24, 2, 21, 21, hWnd, eBW, hInstance, NULL
                mov hBW, eax

                invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR sBF,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        46, 2, 21, 21, hWnd, eBF, hInstance, NULL
                mov hBF, eax

                invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sBC,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        68, 2, 21, 21, hWnd, eBC, hInstance, NULL
                mov hBC, eax

                ; check box
                invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR sRealtimePrint,\
                        WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX ,\
                        93, 2, 115, 21, hWnd, eRealtimePrint, hInstance, NULL
                mov hRealtimePrint, eax
                
                invoke SendMessage, hRealtimePrint, BM_SETCHECK, 1, 0
                mov do_realtime_print, 1

                ; button button
                invoke CreateWindowEx,NULL, ADDR ButtonClassName, ADDR ButtonClassName,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        208, 2, 84, 21, hWnd, eButton, hInstance, NULL
                mov hButton,eax

        ; Reacting on messages
        .ELSEIF uMsg==WM_USER
                .if wParam=='B';66
                        mov eax, Button_count
                        sub Button_count, eax
                        ret
                .endif
                .if wParam=='Q';81
                        invoke timeBeginPeriod,lParam
                        ret
                .endif
                .if do_realtime_print==1
                        .IF wParam==0
                                .IF lParam==0
                                        mov A0,0
                                        invoke dwtoa,A0, ADDR buffer
                                        invoke SetWindowText,hE0, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T0,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T0
                                        add A0,eax
                                        invoke dwtoa,A0, ADDR buffer
                                        invoke SetWindowText,hE0, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A0
                                        invoke dwtoa,A0, ADDR buffer
                                        invoke SetWindowText,hE0, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==1
                                .IF lParam==0
                                        mov A1,0
                                        invoke dwtoa,A1, ADDR buffer
                                        invoke SetWindowText,hE1, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T1,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T1
                                        add A1,eax
                                        invoke dwtoa,A1, ADDR buffer
                                        invoke SetWindowText,hE1, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A1
                                        invoke dwtoa,A1, ADDR buffer
                                        invoke SetWindowText,hE1, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==2
                                .IF lParam==0
                                        mov A2,0
                                        invoke dwtoa,A2, ADDR buffer
                                        invoke SetWindowText,hE2, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T2,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T2
                                        add A2,eax
                                        invoke dwtoa,A2, ADDR buffer
                                        invoke SetWindowText,hE2, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A2
                                        invoke dwtoa,A2, ADDR buffer
                                        invoke SetWindowText,hE2, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==3
                                .IF lParam==0
                                        mov A3,0
                                        invoke dwtoa,A3, ADDR buffer
                                        invoke SetWindowText,hE3, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T3,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T3
                                        add A3,eax
                                        invoke dwtoa,A3, ADDR buffer
                                        invoke SetWindowText,hE3, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A3
                                        invoke dwtoa,A3, ADDR buffer
                                        invoke SetWindowText,hE3, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==4
                                .IF lParam==0
                                        mov A4,0
                                        invoke dwtoa,A4, ADDR buffer
                                        invoke SetWindowText,hE4, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T4,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T4
                                        add A4,eax
                                        invoke dwtoa,A4, ADDR buffer
                                        invoke SetWindowText,hE4, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A4
                                        invoke dwtoa,A4, ADDR buffer
                                        invoke SetWindowText,hE4, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==5
                                .IF lParam==0
                                        mov A5,0
                                        invoke dwtoa,A5, ADDR buffer
                                        invoke SetWindowText,hE5, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T5,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T5
                                        add A5,eax
                                        invoke dwtoa,A5, ADDR buffer
                                        invoke SetWindowText,hE5, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A5
                                        invoke dwtoa,A5, ADDR buffer
                                        invoke SetWindowText,hE5, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==6
                                .IF lParam==0
                                        mov A6,0
                                        invoke dwtoa,A6, ADDR buffer
                                        invoke SetWindowText,hE6, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T6,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T6
                                        add A6,eax
                                        invoke dwtoa,A6, ADDR buffer
                                        invoke SetWindowText,hE6, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A6
                                        invoke dwtoa,A6, ADDR buffer
                                        invoke SetWindowText,hE6, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==7
                                .IF lParam==0
                                        mov A7,0
                                        invoke dwtoa,A7, ADDR buffer
                                        invoke SetWindowText,hE7, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T7,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T7
                                        add A7,eax
                                        invoke dwtoa,A7, ADDR buffer
                                        invoke SetWindowText,hE7, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A7
                                        invoke dwtoa,A7, ADDR buffer
                                        invoke SetWindowText,hE7, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==8
                                .IF lParam==0
                                        mov A8,0
                                        invoke dwtoa,A8, ADDR buffer
                                        invoke SetWindowText,hE8, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T8,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T8
                                        add A8,eax
                                        invoke dwtoa,A8, ADDR buffer
                                        invoke SetWindowText,hE8, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A8
                                        invoke dwtoa,A8, ADDR buffer
                                        invoke SetWindowText,hE8, ADDR buffer
                                .ENDIF
                        .ELSEIF wParam==9
                                .IF lParam==0
                                        mov A9,0
                                        invoke dwtoa,A9, ADDR buffer
                                        invoke SetWindowText,hE9, ADDR buffer
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T9,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T9
                                        add A9,eax
                                        invoke dwtoa,A9, ADDR buffer
                                        invoke SetWindowText,hE9, ADDR buffer
                                .ELSEIF lParam==3
                                        inc A9
                                        invoke dwtoa,A9, ADDR buffer
                                        invoke SetWindowText,hE9, ADDR buffer
                                .ENDIF
                        .ENDIF
                .else
                        .IF wParam==0
                                .IF lParam==0
                                        mov A0,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T0,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T0
                                        add A0,eax
                                .ELSEIF lParam==3
                                        inc A0
                                .ENDIF
                        .ELSEIF wParam==1
                                .IF lParam==0
                                        mov A1,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T1,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T1
                                        add A1,eax
                                .ELSEIF lParam==3
                                        inc A1
                                .ENDIF
                        .ELSEIF wParam==2
                                .IF lParam==0
                                        mov A2,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T2,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T2
                                        add A2,eax
                                .ELSEIF lParam==3
                                        inc A2
                                .ENDIF
                        .ELSEIF wParam==3
                                .IF lParam==0
                                        mov A3,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T3,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T3
                                        add A3,eax
                                .ELSEIF lParam==3
                                        inc A3
                                .ENDIF
                        .ELSEIF wParam==4
                                .IF lParam==0
                                        mov A4,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T4,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T4
                                        add A4,eax
                                .ELSEIF lParam==3
                                        inc A4
                                .ENDIF
                        .ELSEIF wParam==5
                                .IF lParam==0
                                        mov A5,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T5,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T5
                                        add A5,eax
                                .ELSEIF lParam==3
                                        inc A5
                                .ENDIF
                        .ELSEIF wParam==6
                                .IF lParam==0
                                        mov A6,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T6,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T6
                                        add A6,eax
                                .ELSEIF lParam==3
                                        inc A6
                                .ENDIF
                        .ELSEIF wParam==7
                                .IF lParam==0
                                        mov A7,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T7,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T7
                                        add A7,eax
                                .ELSEIF lParam==3
                                        inc A7
                                .ENDIF
                        .ELSEIF wParam==8
                                .IF lParam==0
                                        mov A8,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T8,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T8
                                        add A8,eax
                                .ELSEIF lParam==3
                                        inc A8
                                .ENDIF
                        .ELSEIF wParam==9
                                .IF lParam==0
                                        mov A9,0
                                .ELSEIF lParam==1
                                        invoke GetTickCount 
                                        mov T9,eax
                                .ELSEIF lParam==2
                                        invoke GetTickCount 
                                        sub eax,T9
                                        add A9,eax
                                .ELSEIF lParam==3
                                        inc A9
                                .ENDIF
                        .ENDIF      
                .endif

                .if do_realtime_print==1
                        .if wParam==10
                                mov eax,lParam
                                mov A0,eax
                                invoke dwtoa,A0, ADDR buffer
                                invoke SetWindowText,hE0, ADDR buffer
                        .elseif wParam==11
                                mov eax,lParam
                                mov A1,eax
                                invoke dwtoa,A1, ADDR buffer
                                invoke SetWindowText,hE1, ADDR buffer
                        .elseif wParam==12
                                mov eax,lParam
                                mov A2,eax
                                invoke dwtoa,A2, ADDR buffer
                                invoke SetWindowText,hE2, ADDR buffer
                        .elseif wParam==13
                                mov eax,lParam
                                mov A3,eax
                                invoke dwtoa,A3, ADDR buffer
                                invoke SetWindowText,hE3, ADDR buffer
                        .elseif wParam==14
                                mov eax,lParam
                                mov A4,eax
                                invoke dwtoa,A4, ADDR buffer
                                invoke SetWindowText,hE4, ADDR buffer
                        .elseif wParam==15
                                mov eax,lParam
                                mov A5,eax
                                invoke dwtoa,A5, ADDR buffer
                                invoke SetWindowText,hE5, ADDR buffer
                        .elseif wParam==16
                                mov eax,lParam
                                mov A6,eax
                                invoke dwtoa,A6, ADDR buffer
                                invoke SetWindowText,hE6, ADDR buffer
                        .elseif wParam==17
                                mov eax,lParam
                                mov A7,eax
                                invoke dwtoa,A7, ADDR buffer
                                invoke SetWindowText,hE7, ADDR buffer
                        .elseif wParam==18
                                mov eax,lParam
                                mov A8,eax
                                invoke dwtoa,A8, ADDR buffer
                                invoke SetWindowText,hE8, ADDR buffer
                        .elseif wParam==19
                                mov eax,lParam
                                mov A9,eax
                                invoke dwtoa,A9, ADDR buffer
                                invoke SetWindowText,hE9, ADDR buffer
                        .endif
                .else
                        .if wParam==10
                                mov eax,lParam
                                mov A0,eax
                        .elseif wParam==11
                                mov eax,lParam
                                mov A1,eax
                        .elseif wParam==12
                                mov eax,lParam
                                mov A2,eax
                        .elseif wParam==13
                                mov eax,lParam
                                mov A3,eax
                        .elseif wParam==14
                                mov eax,lParam
                                mov A4,eax
                        .elseif wParam==15
                                mov eax,lParam
                                mov A5,eax
                        .elseif wParam==16
                                mov eax,lParam
                                mov A6,eax
                        .elseif wParam==17
                                mov eax,lParam
                                mov A7,eax
                        .elseif wParam==18
                                mov eax,lParam
                                mov A8,eax
                        .elseif wParam==19
                                mov eax,lParam
                                mov A9,eax
                        .endif
                .endif
        .ELSEIF uMsg==WM_COMMAND
                mov eax,wParam
                .IF ax==eB
                        .IF A0==0
                                mov eax,A1
                                add eax,A2
                                add eax,A3
                                add eax,A4
                                add eax,A5
                                add eax,A6
                                add eax,A7
                                add eax,A8
                                add eax,A9
                                mov A0,eax
                        .ENDIF
                        invoke SetWindowText,hE0, ADDR s100
                          
                        FINIT
                        FILD A1
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE1, ADDR buffer

                        FINIT
                        FILD A2
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE2, ADDR buffer

                        FINIT
                        FILD A3
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE3, ADDR buffer

                        FINIT
                        FILD A4
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE4, ADDR buffer

                        FINIT
                        FILD A5
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE5, ADDR buffer

                        FINIT
                        FILD A6
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE6, ADDR buffer

                        FINIT
                        FILD A7
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE7, ADDR buffer

                        FINIT
                        FILD A8
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE8, ADDR buffer

                        FINIT
                        FILD A9
                        FLD q100
                        FMUL
                        FILD A0
                        FDIV
                        FST float
                        invoke FloatToStr2,float, ADDR buffer
                        .if buffer[1]!='?'
                                mov buffer[7],0
                        .else
                                mov buffer[0],'0'
                                mov buffer[1],0
                        .endif
                        invoke SetWindowText,hE9, ADDR buffer
                                                
                .ELSEIF ax==eB0
                        mov A0,0
                        mov A1,0
                        mov A2,0
                        mov A3,0
                        mov A4,0
                        mov A5,0
                        mov A6,0
                        mov A7,0
                        mov A8,0
                        mov A9,0
                        mov A10,0
                        invoke SetWindowText,hE0, ADDR sA
                        invoke SetWindowText,hE1, ADDR sA
                        invoke SetWindowText,hE2, ADDR sA
                        invoke SetWindowText,hE3, ADDR sA
                        invoke SetWindowText,hE4, ADDR sA
                        invoke SetWindowText,hE5, ADDR sA
                        invoke SetWindowText,hE6, ADDR sA
                        invoke SetWindowText,hE7, ADDR sA
                        invoke SetWindowText,hE8, ADDR sA
                        invoke SetWindowText,hE9, ADDR sA
                        invoke dwtoa, hWnd, ADDR buffer
                        invoke SetWindowText,hWnd, ADDR buffer
                .ELSEIF ax==eB1
                        invoke dwtoa,A0,addr buffer
                        invoke SetWindowText,hE0, ADDR buffer
                        invoke dwtoa,A1,addr buffer
                        invoke SetWindowText,hE1, ADDR buffer
                        invoke dwtoa,A2,addr buffer
                        invoke SetWindowText,hE2, ADDR buffer
                        invoke dwtoa,A3,addr buffer
                        invoke SetWindowText,hE3, ADDR buffer
                        invoke dwtoa,A4,addr buffer
                        invoke SetWindowText,hE4, ADDR buffer
                        invoke dwtoa,A5,addr buffer
                        invoke SetWindowText,hE5, ADDR buffer
                        invoke dwtoa,A6,addr buffer
                        invoke SetWindowText,hE6, ADDR buffer
                        invoke dwtoa,A7,addr buffer
                        invoke SetWindowText,hE7, ADDR buffer
                        invoke dwtoa,A8,addr buffer
                        invoke SetWindowText,hE8, ADDR buffer
                        invoke dwtoa,A9,addr buffer
                        invoke SetWindowText,hE9, ADDR buffer
                .ELSEIF ax==eBW 
                        invoke lstrcpy, ADDR buffer, ADDR sProgramWindowHandler
                        invoke dwtoa,hWnd,addr buf1
                        invoke szCatStr, ADDR buffer, ADDR buf1
                        invoke MessageBox,0, ADDR buffer, ADDR sCopyToClipboard,MB_YESNO
                        .IF eax==IDYES
                                invoke OpenClipboard,0
                                invoke EmptyClipboard
                                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_DDESHARE,32
                                mov hand,eax
                                invoke GlobalLock,hand
                                mov addre,eax
                                invoke lstrcpy,addre, ADDR buf1
                                invoke GlobalUnlock,hand
                                invoke SetClipboardData,CF_TEXT,hand
                                invoke CloseClipboard
                        .ENDIF  
                .ELSEIF ax==eBF
                        mov text[0],0
                        invoke GetSystemTime,addr syst
                        xor eax,eax
                        mov ax,syst.wDay
                        invoke dwtoa,eax,addr buffer
                        invoke szCatStr,addr text, addr buffer
                        invoke szCatStr,addr text, addr sDash
                        xor eax,eax
                        mov ax,syst.wMonth
                        invoke dwtoa,eax,addr buffer
                        invoke szCatStr,addr text, addr buffer
                        invoke szCatStr,addr text, addr sDash
                        xor eax,eax
                        mov ax,syst.wYear
                        invoke dwtoa,eax,addr buffer
                        invoke szCatStr,addr text, addr buffer
                        invoke szCatStr,addr text, addr sSp
                        xor eax,eax
                        mov ax,syst.wHour
                        invoke dwtoa,eax,addr buffer
                        invoke szCatStr,addr text, addr buffer
                        invoke szCatStr,addr text,addr sDash
                        xor eax,eax
                        mov ax,syst.wMinute
                        invoke dwtoa,eax,addr buffer
                        invoke szCatStr,addr text, addr buffer
                        invoke szCatStr,addr text,addr sEOL
                        invoke szCatStr,addr text,addr sProfileResults
                        invoke szCatStr,addr text,addr sEOL
                        invoke szCatStr,addr text,addr sEOL
                        
                        invoke szCatStr, ADDR text, ADDR s0
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE0, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL
                        
                        invoke szCatStr, ADDR text, ADDR s1
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE1, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s2
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE2, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s3
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE3, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s4
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE4, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s5
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE5, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s6
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE6, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s7
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE7, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s8
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE8, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke szCatStr, ADDR text, ADDR s9
                        invoke szCatStr, ADDR text, ADDR sSp
                        invoke GetWindowText,hE9, ADDR buffer,512
                        invoke szCatStr, ADDR text, ADDR buffer
                        invoke szCatStr, ADDR text, ADDR sEOL

                        invoke RtlZeroMemory,addr ofn,sizeof ofn
                        mov ofn.lStructSize,SIZEOF ofn
                        push hWnd
                        pop ofn.hWndOwner
                        push hInstance
                        pop ofn.hInstance
                        mov ofn.lpstrFilter, OFFSET FilterString
                        mov ofn.lpstrFile, OFFSET buffer
                        mov ofn.nMaxFile,MAXSIZE
                        mov buffer[0],0
                        mov ofn.Flags,OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
                        invoke GetSaveFileName, ADDR ofn
                        .if eax==TRUE
                                invoke szCatStr, ADDR buffer, ADDR sLog
                                invoke CreateFile, ADDR buffer,\
                                        GENERIC_READ or GENERIC_WRITE ,\
                                        FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                        NULL,CREATE_NEW,FILE_ATTRIBUTE_ARCHIVE,NULL
                                mov hFile,eax
                                invoke lstrlen, ADDR text
                                invoke _lwrite,hFile, ADDR text,eax
                                invoke CloseHandle,hFile
                        .endif
                .ELSEIF ax==eRealtimePrint
                        .IF do_realtime_print==1 
                                mov do_realtime_print, 0
                        .ELSE
                                mov do_realtime_print, 1
                        .ENDIF
                .ELSEIF ax==eBC
                        invoke lstrcpy, ADDR buffer, ADDR sCLeft
                        invoke dwtoa,hWnd,addr buf1
                        invoke szCatStr, ADDR buffer, ADDR buf1
                        invoke szCatStr, ADDR buffer, ADDR sCRight
                        invoke MessageBox,0, ADDR buffer, ADDR sCopyToClipboard,MB_YESNO
                        .IF eax==IDYES
                                invoke OpenClipboard,0
                                invoke EmptyClipboard
                                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_DDESHARE,64
                                mov hand,eax
                                invoke GlobalLock,hand
                                mov addre,eax
                                invoke lstrcpy,addre, ADDR buffer
                                invoke GlobalUnlock,hand
                                invoke SetClipboardData,CF_TEXT,hand
                                invoke CloseClipboard
                        .ENDIF  
                .ELSEIF ax==eButton
                        inc Button_count
                .ENDIF
        .ELSE
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam
                ret
        .ENDIF
        xor eax,eax
        ret
WndProc endp
end start
