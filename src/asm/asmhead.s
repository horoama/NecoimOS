.intel_syntax noprefix
# haribote-os boot asm
# TAB=4
.equ BOTPAK,  0x00280000 # bootpackのロード先
.equ DSKCAC,  0x00100000 # ディスクキャッシュの場所
.equ DSKCAC0,  0x00008000 # ディスクキャッシュの場所（リアルモード）
# BOOT_INFO関係
.equ CYLS,  0x0ff0 # ブートセクタが設定する
.equ LEDS,  0x0ff1
.equ VMODE,  0x0ff2 # 色数に関する情報。何ビットカラーか？
.equ SCRNX,  0x0ff4 # 解像度のX
.equ SCRNY,  0x0ff6 # 解像度のY
.equ VRAM,  0x0ff8 # グラフィックバッファの開始番地

#ORG 0xc200 # このプログラムがどこに読み込まれるのか

.text
.code16
head:
# 画面モードを設定
    mov al, byte ptr 0x13 # VGAグラフィックス、320x200x8bitカラー
    mov ah, byte ptr 0x00
    int 0x10
    mov BYTE PTR [VMODE], byte ptr 8 # 画面モードをメモする（C言語が参照する）
    mov WORD PTR [SCRNX],word ptr  320
    mov WORD PTR [SCRNY],word ptr  200
    mov DWORD PTR [VRAM],dword ptr  0x000a0000
    # キーボードのLED状態をBIOSに教えてもらう
    mov ah, 0x02
    int 0x16 # keyboard BIOS
    mov byte ptr [LEDS], al
    # PICが一切の割り込みを受け付けないようにする
    # AT互換機の仕様では、PICの初期化をするなら、
    # こいつをCLI前にやっておかないと、たまにハングアップする
    # PICの初期化はあとでやる
    mov al,byte ptr  0xff
    out byte ptr 0x21, AL
    nop # OUT命令を連続させるとうまくいかない機種があるらしいので
    out byte ptr 0xa1, AL
    cli # さらにCPUレベルでも割り込み禁止
    # CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
    call waitkbdout
    mov al, byte ptr 0xd1
    out byte ptr 0x64, al 
    call waitkbdout
    mov AL, byte ptr 0xdf # enable A20
    out byte ptr 0x60, AL
    call waitkbdout
    # プロテクトモード移行

.arch i486						# 32bitネイティブコード
    LGDT    [GDTR0]         # 暫定GDTを設定
    MOV     EAX, cr0
    AND     EAX, dword ptr 0x7fffffff # bit31を0にする（ページング禁止のため）
    OR      EAX, dword ptr 0x00000001 # bit0を1にする（プロテクトモード移行のため）
    MOV     cr0, EAX
    JMP     pipelineflush
pipelineflush:
    MOV     AX, word ptr 1*8         #  読み書き可能セグメント32bit
    MOV     DS, AX
    MOV     ES, AX
    MOV     FS, AX
    MOV     GS, AX
    MOV     SS, AX

# bootpackの転送

    MOV     ESI, dword ptr bootpack   # 転送元
    MOV     EDI, dword ptr BOTPAK     # 転送先
    MOV     ECX, dword ptr 512*1024/4
    CALL    memcpy

    # ついでにディスクデータも本来の位置へ転送

    # まずはブートセクタから

    MOV     ESI, dword ptr 0x7c00     # 転送元
    MOV     EDI, dword ptr DSKCAC     # 転送先
    MOV     ECX, dword ptr 512/4
    CALL    memcpy

# 残り全部

    MOV     ESI, dword ptr DSKCAC0+512    # 転送元
    MOV     EDI, dword ptr DSKCAC+512 # 転送先
    MOV     ECX, dword ptr 0x00
    MOV     CL, BYTE [CYLS]
    IMUL    ECX, dword ptr 512*18*2/4 # シリンダ数からバイト数/4に変換
    SUB     ECX, dword ptr 512/4      # IPLの分だけ差し引く
    CALL    memcpy

    # asmheadでしなければいけないことは全部し終わったので、
    #   あとはbootpackに任せる

    # bootpackの起動

    MOV     EBX, dword ptr BOTPAK
    MOV     ECX, 0x11a8#[EBX+16]
    ADD     ECX, 3          # ECX += 3#
    SHR     ECX, 2          # ECX /= 4#
    JZ      skip            # 転送するべきものがない
    MOV     ESI, 0x10c8#[EBX+20]   # 転送元
    ADD     ESI, EBX
    MOV     EDI, 0x00310000#[EBX+12]   # 転送先
    CALL    memcpy
skip:
    MOV     ESP,dword ptr  0x00310000#[EBX+12]   # スタック初期値
    ljmp      2*8,  0x00000000

waitkbdout:
    IN       AL, byte ptr 0x64
    AND      AL, byte ptr 0x02
    in     al, byte ptr 0x60
    JNZ     waitkbdout      # ANDの結果が0でなければwaitkbdoutへ
    ret

memcpy:
    MOV     EAX, dword ptr [ESI]
    ADD     ESI, 4
    MOV     dword ptr [EDI], EAX
    ADD     EDI, 4
    SUB     ECX, 1
    JNZ     memcpy          # 引き算した結果が0でなければmemcpyへ
    ret
    # memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける

.align 8
GDT0:
.skip 8, 0x00               # ヌルセレクタ
    .word      0xffff, 0x0000, 0x9200, 0x00cf  # 読み書き可能セグメント32bit
    .word      0xffff, 0x0000, 0x9a28, 0x0047  # 実行可能セグメント32bit（bootpack用）

    .word      0x0000
GDTR0:
    .word      8*3-1
    .int      GDT0

.align 8
bootpack:
