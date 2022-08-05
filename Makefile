# packXXX Makefile, based on UniMake: Universal Makefile
# Created by Matthias Stirner, 01/2016

TARGET   = jpegpack
CC       = gcc
CPP      = g++
RC       = windres -O coff
CPPFLAGS = -Wall -O3 -std=c++14 -Isrc -pedantic -funroll-loops -ffast-math -fsched-spec-load -fomit-frame-pointer
LDFLAGS  = -lstdc++fs -s
CSRC     = $(wildcard src/*.c)
CPPSRC   = $(wildcard src/*.cpp)
DEPS     = $(wildcard src/*.h) Makefile
OBJ      = $(patsubst %.c,%.o,$(CSRC)) $(patsubst %.cpp,%.o,$(CPPSRC))
RM       = rm -f

# conditional stuff
ifeq ($(OS),Windows_NT)
LDFLAGS  += -lpthread -L libwinpthread-1.dll
RES       = icons.res
UPX      := -upx --best --lzma $(TARGET).exe
else
CPPFLAGS += -DUNIX
RC        = 
RES       =
UPX       =
endif

ifeq ($(STATIC),Y)
LDFLAGS += -static -static-libgcc -static-libstdc++
endif

.PHONY: all dev lib dll

all: $(TARGET)

$(TARGET): $(OBJ) $(RES)
	$(CPP) $^ $(LDFLAGS) -o $@
	$(UPX)

%.o: %.cpp $(DEPS)
	$(CPP) $(CPPFLAGS) -c $< -o $@
	
icons.res: icons.rc
	@-$(RC) $< $@

dev: CPPFLAGS += -DDEV_BUILD
dev: $(TARGET)

lib: CPPFLAGS += -DBUILD_LIB
lib: $(OBJ)
	ar r lib$(TARGET).a $(OBJ)
	ranlib lib$(TARGET).a
    
dll: CPPFLAGS += -DBUILD_DLL
dll: LDFLAGS  += -Wl,--out-implib,libpackJPG.a -fvisibility=hidden
dll: $(OBJ)
	$(CPP) -shared -o $(TARGET).dll $^ $(LDFLAGS)

clean:
	@echo clean...
	@-rm $(OBJ) lib$(TARGET).a $(TARGET) $(TARGET).exe $(TARGET).dll
