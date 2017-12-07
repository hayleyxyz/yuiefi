
SRCDIR = .

VPATH = $(SRCDIR)

include $(SRCDIR)/Make.defaults

CDIR=$(SRCDIR)/..
LINUX_HEADERS	= /usr/src/sys/build
CPPFLAGS	+= -D__KERNEL__ -I$(LINUX_HEADERS)/include -I/usr/include/efi -I/usr/include/efi/$(ARCH)
CRTOBJS		= /usr/lib/crt0-efi-$(ARCH).o

LDSCRIPT	= /usr/lib/elf_$(ARCH)_efi.lds
ifneq (,$(findstring FreeBSD,$(OS)))
LDSCRIPT	= /usr/lib/elf_$(ARCH)_fbsd_efi.lds
endif

LDFLAGS		+= -shared -Bsymbolic $(CRTOBJS)

LOADLIBES	+= $(LIBGCC) -L/usr/lib -lgnuefi -lefi
LOADLIBES	+= -T $(LDSCRIPT)

TARGET_APPS = yuiefi.efi
TARGET_BSDRIVERS = 
TARGET_RTDRIVERS =

ifneq ($(HAVE_EFI_OBJCOPY),)

FORMAT		:= --target efi-app-$(ARCH)
$(TARGET_BSDRIVERS): FORMAT=--target efi-bsdrv-$(ARCH)
$(TARGET_RTDRIVERS): FORMAT=--target efi-rtdrv-$(ARCH)

else

SUBSYSTEM	:= 0xa
$(TARGET_BSDRIVERS): SUBSYSTEM = 0xb
$(TARGET_RTDRIVERS): SUBSYSTEM = 0xc

FORMAT		:= -O binary
LDFLAGS		+= --defsym=EFI_SUBSYSTEM=$(SUBSYSTEM)

endif

TARGETS = $(TARGET_APPS) $(TARGET_BSDRIVERS) $(TARGET_RTDRIVERS)

all:	$(TARGETS)

clean:
	rm -f $(TARGETS) *~ *.o *.so

.PHONY: install

include $(SRCDIR)/Make.rules
