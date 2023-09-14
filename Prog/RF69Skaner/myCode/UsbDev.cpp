#include "string.h"
#include "UsbDev.h"
#include "usbd_cdc.h"
#include "usbd_desc.h"
#include "main.h"

#include "usbd_cdc_if.h"

extern uint8_t mDebug;

RxData UsbDev::rxData;
char UsbDev::mBuffer[SEND_BUF_SIZE];
uint8_t UsbDev::txBuffer[SEND_BUF_SIZE];

#define STX  0x02
#define ETX  0x03

extern "C" uint8_t getHexNibble(uint8_t ch, uint8_t *dt) {
	if (ch >= '0' && ch <= '9')
		*dt = ch - '0';
	else if (ch >= 'A' && ch <= 'F')
		*dt = 10 + ch - 'A';
	else if (ch >= 'a' && ch <= 'f')
		*dt = 10 + ch - 'a';
	else
		return false;
	return true;
}

extern "C" uint8_t getHexByte(const char *src, uint8_t *dt) {
	uint8_t b1, b2;
	if (!getHexNibble(*src++, &b1))
		return false;
	if (!getHexNibble(*src, &b2))
		return false;
	*dt = (b1 << 4) | b2;
	return true;
}

extern "C" uint8_t getHexWord(const char *src, uint16_t *w) {
	uint8_t b1, b2;
	if (!getHexByte(src, &b1))
		return false;
	src += 2;
	if (!getHexByte(src, &b2))
		return false;
	*w = b1 << 8 | b2;
	return true;
}

extern "C" uint8_t getHexBuf(const char *src, int len, uint8_t *dst, int max) {
	while (max > 0 && len > 0) {
		if (!getHexByte(src, dst)) {
			return false;
		}
		src += 2;
		len -= 2;
		dst++;
		max--;
	}
	return true;
}

const char HexTab[] = "0123456789ABCDEF";
extern "C" uint8_t putHexByte(char *txt, uint8_t b) {
	txt[0] = HexTab[(b >> 4) & 0x0f];
	txt[1] = HexTab[b & 0x0f];
	return 2;
}

extern "C" uint8_t putHexWord(char *txt, uint16_t w) {
	putHexByte(txt, w >> 8);
	txt += 2;
	putHexByte(txt, w);
	return 4;
}

bool RxData::push(uint8_t dt) {

	mNewData = true;

	uint16_t h = mHead;
	if (++h == RECIVE_BUF_SIZE)
		h = 0;
	if (h != mTail) {
		buf[mHead] = dt;
		mHead = h;
		return true;
	} else
		return false;
}

bool RxData::pop(uint8_t *dt) {
	if (mTail != mHead) {
		*dt = buf[mTail];
		if (++mTail == RECIVE_BUF_SIZE)
			mTail = 0;
		return true;

	} else
		return false;
}

int RxData::getFrame(char *frame, int max) {
	bool fnd = false;
	int frameLen = 0;
	if (mNewData) {

		bool tooLong = false;

		bool cp = false;
		uint16_t memTail = mTail;
		uint8_t a;
		while (pop(&a)) {

			if (a == STX) {
				frameLen = 0;
				cp = true;
			} else if (a == ETX) {
				fnd = true;
				break;
			} else {
				if (cp) {
					//zabezpieczenie jakby by� pakiet, kt�ry nie mie�ci si� w buforze rxFrame
					if (frameLen < max - 1) {
						frame[frameLen++] = a;
					} else
						tooLong = true;

				}
			}
		}
		if (!fnd) {
			mTail = memTail;
			int h = mHead;
			if (++h == RECIVE_BUF_SIZE) {
				h = 0;
			}
			if (h == mTail) {
				//pe�ny bufor, ale w nim nie ma ramki
				mTail = mHead;
			}
		}
		if (mTail == mHead) {
			mNewData = false;
		}
		if (tooLong)
			fnd = false;
	}
	if (fnd) {
		frame[frameLen] = 0;
		return frameLen;
	} else
		return -1;
}

void UsbDev::init() {
	rxData.mNewData = false;
}

extern "C" void CDC_UserOnReciveData(uint8_t *Buf, uint32_t Len) {
	UsbDev::OnReciveData(Buf, Len);
}

int usbfifoFullCnt;

void UsbDev::OnReciveData(uint8_t *Buf, uint32_t Len) {
	for (uint32_t i = 0; i < Len; i++) {
		if (!rxData.push(Buf[i])) {
			usbfifoFullCnt++;
		}
	}
}

// je�li jest bufor funkcja zwraca d�ugosc danych w buforze
// je�li nie ma danych, zwraca -1

int UsbDev::getFrame(uint8_t *binFrame, int binMax) {
	char rxFrame[RECIVE_FRAME_SIZE];
	int oLen = -1;

	int len = rxData.getFrame(rxFrame, sizeof(rxFrame));
	if (len > 0) {
		oLen = translateFrame(binFrame, binMax, rxFrame, len);
	}
	return oLen;
}

int UsbDev::translateFrame(uint8_t *binFrame, int binMax, char *txtFR, int len) {
	if (len < 6) {
		printf("Error, frame too short\r\n");
		return false;
	}

	uint16_t suma = 0;
	for (int i = 0; i < len - 4; i++) {
		suma += (uint8_t) (txtFR[i]);
	}
	uint16_t suma2;
	bool q1 = getHexWord(&txtFR[len - 4], &suma2);
	if (!q1)
		printf("Error, HexFormat \r\n");

	if (mDebug >= 3) {
		printf("H>:");
		printf(txtFR);
		printf("\r\n");
	}

	if (suma != suma2) {
		printf("Error, suma=%04X suma2=%04X\r\n", suma, suma2);
		return -1;
	}
	memset(binFrame, 0, binMax);
	len -= 4;
	if (getHexBuf(txtFR, len, binFrame, binMax))
		return len / 2;
	else
		return -1;
}

bool UsbDev::Transmit(RawData *pFrame) {

	int ptr = 0;
	mBuffer[ptr++] = STX;
	uint8_t *p = (uint8_t*) pFrame;

	int n = pFrame->len;
	if (n > MAX_RAW_DATA_LEN)
		n = MAX_RAW_DATA_LEN;
	n += 12;

	for (int i = 0; i < n; i++) {
		ptr += putHexByte(&mBuffer[ptr], *p++);
	}

	uint16_t suma = 0;
	for (int i = 1; i < ptr; i++) {
		suma += mBuffer[i];
	}

	ptr += putHexWord(&mBuffer[ptr], suma);
	mBuffer[ptr++] = ETX;
	mBuffer[ptr++] = '\r';
	mBuffer[ptr++] = '\n';
	if (mDebug > 3)
		printf(" ptr=%u", ptr);

	return (CDC_Transmit_FS((uint8_t*) mBuffer, ptr) == USBD_OK);
}

bool UsbDev::isTransmiterRdy() {

	return CDC_IsTransmiterRdy();
}

