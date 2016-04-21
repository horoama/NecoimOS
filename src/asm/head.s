.intel_syntax noprefix
# haribote-os boot asm
# TAB=4
.equ BOTPAK,    0x00280000 # bootpackのロード先
.equ DSKCAC,    0x00100000 # ディスクキャッシュの場所
.equ DSKCAC0,   0x00008000 # ディスクキャッシュの場所（リアルモード）
# BOOT_INFO関係
.equ CYLS,      0x0ff0 # ブートセクタが設定する
.equ LEDS,      0x0ff1
.equ VMODE,     0x0ff2 # 色数に関する情報。何ビットカラーか？
.equ SCRNX,     0x0ff4 # 解像度のX
.equ SCRNY,     0x0ff6 # 解像度のY
.equ VRAM,      0x0ff8 # グラフィックバッファの開始番地

#ORG 0xc200 # このプログラムがどこに読み込まれるのか

.text
.code16
head:
    # 画面モードを設定
    mov al, byte ptr 0x13 # VGAグラフィックス、320x200x8bitカラー
    mov ah, byte ptr 0x00
    int 0x10
    mov BYTE PTR [VMODE], 0x08 # 画面モードをメモする（C言語が参照する）
    mov WORD PTR [SCRNX], 320
    mov WORD PTR [SCRNY], 200
    mov DWORD PTR [VRAM], 0x000a0000
    # キーボードのLED状態をBIOSに教えてもらう
    #call waitkbdout

    mov ah, 0x02
    int 0x16 # keyboard BIOS
    mov [LEDS], al
    # PICが一切の割り込みを受け付けないようにする
    # AT互換機の仕様では、PICの初期化をするなら、
    # こいつをCLI前にやっておかないと、たまにハングアップする
    # PICの初期化はあとでやる
    mov al, 0xff
    out 0x21, AL
    nop # OUT命令を連続させるとうまくいかない機種があるらしいので
    out 0xa1, AL
    cli # さらにCPUレベルでも割り込み禁止

    # CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
    call waitkbdout
    mov al, 0xd1
    out  0x64, al
    call waitkbdout
    mov AL,  0xdf # enable A20
    out  0x60, AL
    call waitkbdout
    # プロテクトモード移行
.arch i486						# 32bitネイティブコード
	lgdt [GDTR0]		# 暫定GDTを設定
    mov EAX, cr0
    and EAX, 0x7fffffff # bit31を0にする（ページング禁止のため）
    or EAX, 0x00000001 # bit0を1にする（プロテクトモード移行のため）
    mov cr0, EAX
    jmp pipelineflash
pipelineflash:
    mov ax, 1*8 # 読み書き可能セグメント32bit
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

# bootpackの転送
	mov esi, offset bootpack
    mov edi,  BOTPAK # 転送先
    mov ecx, 512*1024/4

    call memcpy
    # ついでにディスクデータも本来の位置へ転送
    # まずはブートセクタから
    mov esi, 0x7c00 # 転送元
    mov edi, DSKCAC # 転送先
    mov ecx, 512/4
    call memcpy

    # 残り全部
    mov esi, DSKCAC0+512 # 転送元
    mov edi, DSKCAC+512 # 転送先
    mov ecx, 0x00
    mov cl,  [CYLS]
    imul ecx, 512*18*2/4 # シリンダ数からバイト数/4に変換
    sub ecx, 512/4 # IPLの分だけ差し引く
    call memcpy
    # asmheadでしなければいけないことは全部し終わったので、
    # あとはbootpackに任せる
    # bootpackの起動
    mov ebx, DWORD PTR BOTPAK
    mov ecx, DWORD PTR 0x11a8#[EBX+16]
    add ecx, 3 # ECX += 3#
    shr ecx, 2 # ECX /= 4#
    jz skip # 転送するべきものがない
    mov esi, 0x10c8#[ebx+20] # 転送元
    add esi, ebx
    mov edi, 0x00310000#[ebx+12] # 転送先
    call memcpy
skip:
    mov esp,  0x00310000#[ebx+12] # スタック初期値
    ljmp  2*8,  0x00000000

waitkbdout:
    in al, 0x64
    and al, 0x02
    in al, 0x60 # から読み(受信バッファが悪さをしないように)
    jnz waitkbdout # ANDの結果が0でなければwaitkbdoutへ
    ret
#
memcpy:
    mov eax, [esi]
    add esi, 4
    mov [edi], eax
    add edi, 4
    sub ecx, 1
    jnz memcpy # 引き算した結果が0でなければmemcpyへ
    ret
    # memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける
.align 8
GDT0:
.skip 8, 0x00 # ヌルセレクタ
    .word 0xffff, 0x0000, 0x9200, 0x00cf # 読み書き可能セグメント32bit
    .word 0xffff, 0x0000, 0x9a28, 0x0047 # 実行可能セグメント32bit（bootpack用）

    .word 0x0000
GDTR0:
    .word 8*3-1
    .int  GDT0

.align 8
bootpack:
