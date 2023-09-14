#include "string.h"
#include "stdarg.h"
#include "ssd1306.h"
#include "ssd1306_fonts.h"
#include "I2C.h"

SSD1306Dev::SSD1306Dev(uint8_t adr) {
	mDevAdr = adr;
	mDevExist = false;
	mError = false;
	mLcdNarrow = true;

	memset(mBuffer, 0, sizeof(mBuffer));
	memset(&mState, 0, sizeof(mState));
}

void SSD1306Dev::showState() {
	printf("chipOk: %u\n", mDevExist);
	printf("Error: %u\n", mError);
	printf("LcdNarrow: %u\n", mLcdNarrow);
}

void SSD1306Dev::_WriteCmd(uint8_t cmd) {
	bool st = _writeByte(mDevAdr, 0x00, cmd);
	if (!st)
		mError = true;
}

void SSD1306Dev::_WriteData(uint8_t *buffer, size_t buff_size) {
	bool st = _writeMem(mDevAdr, 0x40, buffer, buff_size);
	if (!st)
		mError = true;
}

void SSD1306Dev::Init(void) {
	mDevExist = checkDevExist(mDevAdr);
	if (!mDevExist)
		return;

	lock();
	{

		// Init OLED

		_WriteCmd(0xAE); //display off

		_WriteCmd(0x20); //Set Memory Addressing Mode
		_WriteCmd(0x00); // 00b,Horizontal Addressing Mode; 01b,Vertical Addressing Mode;
						 // 10b,Page Addressing Mode (RESET); 11b,Invalid

		_WriteCmd(0xB0); //Set Page Start Address for Page Addressing Mode,0-7

#ifdef SSD1306_MIRROR_VERT
    _WriteCmd(0xC0); // Mirror vertically
#else
		_WriteCmd(0xC8); //Set COM Output Scan Direction
#endif

		_WriteCmd(0x00); //---set low column address
		_WriteCmd(0x10); //---set high column address

		_WriteCmd(0x40); //--set start line address - CHECK

		_WriteCmd(0x81); //--set contrast control register - CHECK
		_WriteCmd(0xFF);

#ifdef SSD1306_MIRROR_HORIZ
    _WriteCmd(0xA0); // Mirror horizontally
#else
		_WriteCmd(0xA1); //--set segment re-map 0 to 127 - CHECK
#endif

#ifdef SSD1306_INVERSE_COLOR
    _WriteCmd(0xA7); //--set inverse color
#else
		_WriteCmd(0xA6); //--set normal color
#endif

		_WriteCmd(0xA8); //--set multiplex ratio(1 to 64) - CHECK
		_WriteCmd(0x3F); //

		_WriteCmd(0xA4); //0xa4,Output follows RAM content;0xa5,Output ignores RAM content

		_WriteCmd(0xD3); //-set display offset - CHECK
		_WriteCmd(0x00); //-not offset

		_WriteCmd(0xD5); //--set display clock divide ratio/oscillator frequency
		_WriteCmd(0xF0); //--set divide ratio

		_WriteCmd(0xD9); //--set pre-charge period
		_WriteCmd(0x22); //

		_WriteCmd(0xDA); //--set com pins hardware configuration - CHECK
		_WriteCmd(0x12);

		_WriteCmd(0xDB); //--set vcomh
		_WriteCmd(0x20); //0x20,0.77xVcc

		_WriteCmd(0x8D); //--set DC-DC enable
		_WriteCmd(0x14); //
		_WriteCmd(0xAF); //--turn on SSD1306 panel
	}
	unlock();

	// Clear screen
	Fill(colBlack);

	// Flush buffer to screen
	updateScr();

	// Set default values for screen object
	mState.X = 0;
	mState.Y = 0;

	mState.Initialized = 1;

	setFont(fn7x10);
	setColor(colWhite);

}

void SSD1306Dev::Fill(SSD1306_COLOR color) {
	int v = (color == colBlack) ? 0x00 : 0xFF;
	memset(mBuffer, v, sizeof(mBuffer));
}

void SSD1306Dev::setCursor(uint8_t x, uint8_t y) {
	mState.X = x;
	mState.Y = y;
}

void SSD1306Dev::updateScr(void) {
	lock();
	{
		for (int i = 0; i < 8; i++) {
			_WriteCmd(0xB0 + i);
			_WriteCmd(0x00);
			_WriteCmd(0x10);
			_WriteData(&mBuffer[WIDTH * i], WIDTH);
		}
	}
	unlock();
}

void SSD1306Dev::drawPixel(uint8_t x, uint8_t y, SSD1306_COLOR color) {
	if (mLcdNarrow) {
		y = (y << 1) + 1; // dane rozrzucone
	}

	if (x >= WIDTH || y >= HEIGHT) {
		return;
	}

	if (mState.Inverted) {
		color = (SSD1306_COLOR) !color;
	}
	if (color == colWhite) {
		mBuffer[x + (y / 8) * WIDTH] |= 1 << (y % 8);
	} else {
		mBuffer[x + (y / 8) * WIDTH] &= ~(1 << (y % 8));
	}
}

void SSD1306Dev::lineH(int y1, int x1, int x2) {
	while (x1 <= x2) {
		drawPixel(x1, y1, mState.color);
		x1++;
	}

}
void SSD1306Dev::lineV(int x1, int y1, int y2) {
	while (y1 <= y2) {
		drawPixel(x1, y1, mState.color);
		y1++;
	}
}

void SSD1306Dev::rectangle(int x1, int y1, int x2, int y2) {
	lineH(y1, x1, x2);
	lineH(y2, x1, x2);
	lineV(x1, y1, y2);
	lineV(x2, y1, y2);
}

const void* SSD1306Dev::getFontDef(SSD1306_FONT font) {
	switch (font) {
	default:
	case fn6x8:
		return &Font_6x8;
	case fn7x10:
		return &Font_7x10;
	case fn11x18:
		return &Font_11x18;
	case fn16x26:
		return &Font_16x26;
	}
}

void SSD1306Dev::setFont(SSD1306_FONT font) {
	mState.pFont = getFontDef(font);
}
void SSD1306Dev::setColor(SSD1306_COLOR color) {
	mState.color = color;
}

void SSD1306Dev::incY(int dy) {
	int y = mState.Y + dy;
	if (y < 0)
		y = 0;
	if (y > HEIGHT-1)
		y = HEIGHT-1;
	mState.Y = y;
}

bool SSD1306Dev::wrCharHd(char ch) {
	FontDef *pFont = (FontDef*) mState.pFont;

	if (ch != '\n') {
		if (ch < 32 || ch > 126)
			return false;

		if ((mState.X >= WIDTH) || (mState.Y >= HEIGHT)) {
			return false;
		}

		for (int i = 0; i < pFont->FontHeight; i++) {
			uint32_t b = pFont->data[(ch - 32) * pFont->FontHeight + i];
			for (int j = 0; j < pFont->FontWidth; j++) {
				if ((b << j) & 0x8000) {
					drawPixel(mState.X + j, (mState.Y + i), (SSD1306_COLOR) mState.color);
				} else {
					drawPixel(mState.X + j, (mState.Y + i), (SSD1306_COLOR) !mState.color);
				}
			}
		}
		mState.X += pFont->FontWidth;
	} else {
		mState.X = 0;
		mState.Y += pFont->FontHeight;
	}

	return true;
}

bool SSD1306Dev::wrChar(char ch) {
	return wrCharHd(ch);
}

bool SSD1306Dev::wrStr(const char *str) {
	while (*str) {
		wrCharHd(*str);
		str++;
	}
	return true;
}

void SSD1306Dev::prn(const char *pFormat, ...) {
	va_list ap;
	va_start(ap, pFormat);
	vsnprintf(prnBuf, sizeof(prnBuf), pFormat, ap);
	//strncpy(prnBuf,pFormat,sizeof(prnBuf));
	va_end(ap);
	wrStr(prnBuf);
}

void SSD1306Dev::clear() {
	mState.X = 0;
	mState.Y = 0;
	Fill(colBlack);
}

void SSD1306Dev::welcomeScr() {
	clear();
	setFont(fn16x26);
	wrStr(" eLINE\n");
	setFont(fn7x10);
	wrStr("\nREMOTE");
	updateScr();
}

void SSD1306Dev::releaseKeyScr() {
	clear();
	setFont(fn16x26);
	wrStr("  ____  \n");
	updateScr();
}

void SSD1306Dev::endScr() {
	clear();
	setFont(fn16x26);
	wrStr(" KONIEC ");
	updateScr();
}

bool SSD1306Dev::menu(char ch) {
	switch (ch) {
	case 'I':
		Init();
		break;
	case 'N':
		mLcdNarrow = !mLcdNarrow;
		printf("LcdNarrow=%u\n", mLcdNarrow);
		break;
	case 's':
		showState();
		break;
	case 'f':
		printf("Font_6x8  : %ux%u\n", Font_6x8.FontWidth, Font_6x8.FontHeight);
		printf("Font_7x10 : %ux%u\n", Font_7x10.FontWidth, Font_7x10.FontHeight);
		printf("Font_11x18: %ux%u\n", Font_11x18.FontWidth, Font_11x18.FontHeight);
		printf("Font_16x26: %ux%u\n", Font_16x26.FontWidth, Font_16x26.FontHeight);
		break;

	case 'w':
		welcomeScr();
		break;
	case '1':
		clear();
		setFont(fn6x8);
		prn("ALA i JA\n");
		prn("jeden\n");
		prn("dwa\n");
		prn("trzy\n");
		updateScr();
		break;
	case '2':
		clear();
		setFont(fn16x26);
		prn("F=12.05N\n");
		updateScr();
		break;
	case '3': {
		clear();
		rectangle(0, 0, 31, 31);
		rectangle(10, 10, 21, 21);

		rectangle(96, 0, 127, 31);
		rectangle(106, 10, 117, 21);

		updateScr();
	}
		break;
	case 27:
		return true;
	default:
		printf("____LCD menu____\n"
				"I - lcd init\n"
				"s - Lcd status\n"
				"N - switch LcdNarrow\n"
				"f - font size\n"
				"w - Lcd welcomest\n"
				"1,2,3 - Lcd test1\n");
	}
	return false;
}
