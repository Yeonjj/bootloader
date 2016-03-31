EMULATOR = qemu-system-x86_64
AS = nasm
IPL_512 = src/MyOS.asm
CLUSTER_ASM = src/clust.asm
COBINE_ASM = src/MyOS.asm src/clust.asm
APPENDER = AppF

IPL_LST = ipl.lst
BOOTLODER = bootloder.asm
IMGFILE = bootl.img



all : $(IMGFILE)

$(BOOTLODER) : $(COBINE_ASM) 
	./Appending/$(APPENDER) $^ $@
$(IMGFILE) : $(BOOTLODER)
	$(AS) -f bin $< -o $@
	mv bootloder.asm src/
$(IPL_LST) : $(IPL_512) $(IMGFILE)
	mkdir debug 
	$(AS) -f bin $< -l $(IPL_LST) -o ipl.bin
	mv $(IPL_LST) debug/
	mv ipl.bin debug/

#command
.PHONY : 
	
run : $(IMGFILE)	
	$(EMULATOR) -drive file=$<,format=raw
fdrun : $(IMGFILE)
	$(EMULATOR) -fda $<
withlist : $(IPL_LST) 
clean : 
	rm $(IMGFILE) $(BOOTLODER)
	rm src/bootloder.asm
	rm -r debug

