/*
 * Base64Tool.h
 *
 *  Created on: 14 kwi 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_BASE64TOOL_H_
#define KPHOST_BASE64TOOL_H_

#include "stdint.h"

class Base64Tool {
private:
	bool mError;
	void Enc1B(char *dst, const uint8_t *src);
	void Enc2B(char *dst, const uint8_t *src);
	void Enc3B(char *dst, const uint8_t *src);

	uint8_t knvChar(char ch);
	void knv1Bt(uint8_t *dst, const char *src);
	void knv2Bt(uint8_t *dst, const char *src);
	void knv3Bt(uint8_t *dst, const char *src);

public:
	//konwersja do TXT
	int Encode(char *dst, const uint8_t *src, int len);
	//konwersja do postaci binarnej
	int Decode(uint8_t *dst, const char *src, int len);
};

#endif /* KPHOST_BASE64TOOL_H_ */
