/*
 * Base64Tool.cpp
 *
 *  Created on: 14 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>
#include <Base64Tool.h>

const char Base64[64 + 1] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void Base64Tool::Enc3B(char *dst, const uint8_t *src) {

	uint8_t b1 = src[0];
	uint8_t b2 = src[1];
	uint8_t b3 = src[2];

	dst[0] = Base64[b1 >> 2];
	dst[1] = Base64[((b1 << 4) | (b2 >> 4)) & 0x3F];
	dst[2] = Base64[((b2 << 2) | (b3 >> 6)) & 0x3F];
	dst[3] = Base64[b3 & 0x3F];
}

void Base64Tool::Enc2B(char *dst, const uint8_t *src) {
	uint8_t b1 = src[0];
	uint8_t b2 = src[1];

	dst[0] = Base64[b1 >> 2];
	dst[1] = Base64[((b1 << 4) | (b2 >> 4)) & 0x3F];
	dst[2] = Base64[(b2 << 2) & 0x3F];
	dst[3] = '=';
}

void Base64Tool::Enc1B(char *dst, const uint8_t *src) {
	uint8_t b1 = src[0];

	dst[0] = Base64[b1 >> 2];
	dst[1] = Base64[(b1 << 4) & 0x3F];
	dst[2] = '=';
	dst[3] = '=';
}

//konwersja do TXT
int Base64Tool::Encode(char *dst, const uint8_t *src, int n) {
	char *dst_m = dst;
	int i = 0;
	while (i < n) {
		switch (n - i) {
		default:
			Enc3B(dst, src);
			break;
		case 2:
			Enc2B(dst, src);
			break;
		case 1:
			Enc1B(dst, src);
			break;
		}
		i += 3;
		src += 3;
		dst += 4;
	}
	int nn = dst - dst_m;
	return nn;
}

uint8_t Base64Tool::knvChar(char ch) {

	if (ch >= 'A' && ch <= 'Z')
		return ch - 'A';
	if (ch >= 'a' && ch <= 'z')
		return ch - 'a' + 26;

	if (ch >= '0' && ch <= '9')
		return ch - '0' + 52;

	if (ch == '+')
		return 62;
	if (ch == '/')
		return 63;
	mError = true;
	return 0;
}

void Base64Tool::knv3Bt(uint8_t *dst, const char *src) {
	uint8_t b1 = knvChar(src[0]);
	uint8_t b2 = knvChar(src[1]);
	uint8_t b3 = knvChar(src[2]);
	uint8_t b4 = knvChar(src[3]);

	dst[0] = (b1 << 2) | ((b2 >> 4) & 0x03);
	dst[1] = ((b2 << 4) & 0xF0) | ((b3 >> 2) & 0x0F);
	dst[2] = ((b3 << 6) & 0xC0) | b4;
}

void Base64Tool::knv2Bt(uint8_t *dst, const char *src) {
	uint8_t b1 = knvChar(src[0]);
	uint8_t b2 = knvChar(src[1]);
	uint8_t b3 = knvChar(src[2]);

	dst[0] = (b1 << 2) | ((b2 >> 4) & 0x03);
	dst[1] = ((b2 << 4) & 0xF0) | ((b3 >> 2) & 0x0F);
}

void Base64Tool::knv1Bt(uint8_t *dst, const char *src) {
	uint8_t b1 = knvChar(src[0]);
	uint8_t b2 = knvChar(src[1]);

	dst[0] = (b1 << 2) | ((b2 >> 4) & 0x03);
}

//konwersja do postaci binarnej
int Base64Tool::Decode(uint8_t *dst, const char *src, int len) {
	mError = false;

	if (((len % 4) == 0) && (len > 0)) {
		int last = 0;
		if (src[len - 1] == '=') {
			last = 2;
			if (src[len - 2] == '=') {
				last = 1;
			}
		}

		int n = len >> 2;
		if (last != 0)
			n--;

		for (int i = 0; i < n; i++) {
			knv3Bt(dst, src);
			dst += 3;
			src += 4;
		}

		switch (last) {
		case 2:
			knv2Bt(dst, src);
			break;
		case 1:
			knv1Bt(dst, src);
			break;
		}
		if (!mError)
			return n * 3 + last;
	}
	return 0;
}
