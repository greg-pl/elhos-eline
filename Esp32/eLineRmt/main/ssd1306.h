/**
 * This Library was originally written by Olivier Van den Eede (4ilo) in 2016.
 * Some refactoring was done and SPI support was added by Aleksander Alekseev (afiskon) in 2018.
 *
 * https://github.com/afiskon/stm32-ssd1306
 */

#ifndef __SSD1306_H__
#define __SSD1306_H__

#include <stddef.h>
#include <I2C.h>

class SSD1306Dev: public I2CDev {
public:
	typedef enum {
		colBlack = 0x00, colWhite = 0x01
	} SSD1306_COLOR;

	typedef enum {
		fn6x8 = 0, fn7x10, fn11x18, fn16x26,
	} SSD1306_FONT;

private:
	enum {
		HEIGHT = 64, //
		WIDTH = 128, //
	};

	uint8_t mDevAdr;
	bool mDevExist;
	bool mError;
	bool mLcdNarrow;

	uint8_t mBuffer[WIDTH * HEIGHT / 8]; // Screenbuffer
	char prnBuf[80];
	struct {
		uint16_t X;
		uint16_t Y;
		bool Inverted;
		bool Initialized;
		const void *pFont;
		SSD1306_COLOR color;

	} mState;
	void _WriteCmd(uint8_t cmd);
	void _WriteData(uint8_t *buffer, size_t buff_size);
	bool wrCharHd(char ch);
	const void* getFontDef(SSD1306_FONT font);
	void Fill(SSD1306_COLOR color);
public:

	void lineH(int y1, int x1, int x2);
	void lineV(int x1, int y1, int y2);
	void rectangle(int x1, int y1, int x2, int y2);

public:
	SSD1306Dev(uint8_t adr);
	void showState();

	void Init(void);
	void updateScr(void);
	void setFont(SSD1306_FONT font);
	void setColor(SSD1306_COLOR color);
	bool wrChar(char ch);
	bool wrStr(const char *str);
	void prn(const char *pFormat, ...);
	void incY(int dy);
	void drawPixel(uint8_t x, uint8_t y, SSD1306_COLOR color);
	void setCursor(uint8_t x, uint8_t y);
	void welcomeScr();
	void releaseKeyScr();
	void endScr();
	void clear();
	bool menu(char ch);
};

#endif // __SSD1306_H__
