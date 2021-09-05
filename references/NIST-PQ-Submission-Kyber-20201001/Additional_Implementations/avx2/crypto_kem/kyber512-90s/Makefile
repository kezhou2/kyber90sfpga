CC=/usr/bin/gcc
CFLAGS += -mavx2 -mbmi2 -mpopcnt -maes -march=native -mtune=native -O3 -fomit-frame-pointer
LDFLAGS=-lcrypto

SOURCES= cbd.c consts.c indcpa.c kem.c poly.c polyvec.c rejsample.c rng.c verify.c PQCgenKAT_kem.c \
			   aes256ctr.c \
         fq.S invntt.S ntt.S shuffle.S basemul.S

HEADERS= api.h cbd.h consts.h indcpa.h kem.h ntt.h params.h poly.h polyvec.h reduce.h rejsample.h rng.h symmetric.h verify.h \
				 aes256ctr.h \
				 fq.inc shuffle.inc

PQCgenKAT_kem: $(HEADERS) $(SOURCES)
	$(CC) $(CFLAGS) -DKYBER_90S -o $@ $(SOURCES) $(LDFLAGS)

.PHONY: clean

clean:
	-rm PQCgenKAT_kem



