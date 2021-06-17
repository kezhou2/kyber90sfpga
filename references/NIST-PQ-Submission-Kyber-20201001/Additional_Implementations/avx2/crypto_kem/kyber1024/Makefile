CC=/usr/bin/gcc
CFLAGS += -mavx2 -mbmi2 -mpopcnt -maes -march=native -mtune=native -O3 -fomit-frame-pointer
LDFLAGS=-lcrypto

SOURCES= cbd.c consts.c indcpa.c kem.c poly.c polyvec.c rejsample.c rng.c verify.c PQCgenKAT_kem.c \
         fips202.c fips202x4.c keccak4x/KeccakP-1600-times4-SIMD256.c symmetric-shake.c \
         fq.S invntt.S ntt.S shuffle.S basemul.S

HEADERS= api.h cbd.h consts.h indcpa.h kem.h ntt.h params.h poly.h polyvec.h reduce.h rejsample.h rng.h symmetric.h verify.h \
         fips202.h fips202x4.h keccak4x/align.h keccak4x/brg_endian.h keccak4x/KeccakP-1600-times4-SnP.h keccak4x/KeccakP-1600-unrolling.macros keccak4x/SIMD256-config.h \
				 fq.inc shuffle.inc

PQCgenKAT_kem: $(HEADERS) $(SOURCES)
	$(CC) $(CFLAGS) -o $@ $(SOURCES) $(LDFLAGS)

.PHONY: clean

clean:
	-rm PQCgenKAT_kem
