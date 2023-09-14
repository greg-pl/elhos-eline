#ifndef __SPI1DEV_BOARD__
#define __SPI1DEV_BOARD__


#include "mydef.h"
#include "main.h"

//------------------------------------------------------------------------
// w pliku "main.h" zdefiniuj:
//#define RFM69_SHELL_CHAR 0
//#define RFM69_SHELL_CMD  1
//------------------------------------------------------------------------

#if RFM69_SHELL_CMD
#include "IOStream.h"
#endif

class SPI_1 {
private:
	static SPI_HandleTypeDef hspi;
public:

	static void Init();
	static uint8_t RW(uint8_t reg);
	static HAL_StatusTypeDef Transmit(const uint8_t *pData, uint16_t Size);
	static HAL_StatusTypeDef Receive(uint8_t *pData, uint16_t Size);
};

enum {
	bd4800, bd19200, bd38400, bd300000,
};

enum TRfmErrorDef {
	stRFM_OK = 0, //
	stRFM_TXFIFOFULL,
	stRFM_NOSND,
	stRFM_SWRXTXERR, //Switch TX/RX error
	stRFM_TOOMANY,
	stRFM_TXERROR,
	stRFM_CSMALIMIT,
};

typedef struct {
	int ChannelFreq;
	uint8_t BaudRate;
	uint8_t TxPower;
	uint8_t PAMode;
} RFMCfg;


#define RF69_MAX_DATA_LEN       65 // to take advantage of the built in AES/CRC we want to limit the frame size to the internal FIFO size (66 uint8_ts - 3 uint8_ts overhead - 2 uint8_ts crc)

typedef struct {
	volatile uint8_t SenderID;
	volatile uint8_t DataLen;
	volatile float RSSI; // most accurate RSSI during reception (closest to the reception)
	volatile int RSSI_hd; // most accurate RSSI during reception (closest to the reception)
	uint8_t DataBuf[RF69_MAX_DATA_LEN];
} RadioRecord;

typedef enum {
	modeSLEEP = 0, // XTAL OFF
	modeSTANDBY = 1, // XTAL ON
	modeSYNTH = 2, // PLL ON
	modeTX = 3, // TX MODE
	modeRX = 4, // RX MODE
} TRFM69_MODE;

typedef struct {
	uint32_t lastSend;
	int sendFrameCnt;

} TRFM69_Params;

//Instrukcja do RFM69HW rozdzia� 3.3.6, strona 21
typedef enum {
	paMode1, //  -18..+13dBm
	paMode2, //  -2..+13dBm
	paMode3, //  +2..+17dBm
	paMode4, //  +5..+20dBm
} PAMode;


class RFM69 {
private:
	static bool mShowRecFrame;
	static TRFM69_MODE mMode;
	static PAMode mPA_Mode;
	static uint8_t mPowerLevel;
	static TRFM69_Params mParam;
	static bool mNewframe;
	static char txt[120];

	static void CS_DN();
	static void CS_UP();
	static void RESET_DN();
	static void RESET_UP();

	static uint8_t readReg(uint8_t addr);
	static void writeReg(uint8_t addr, uint8_t value);
	static void writeMReg(uint8_t addr, const uint8_t *ptr, int cnt);
	static void modifyReg(uint8_t addr, uint8_t mask, uint8_t value);

	static uint32_t getBitRate();
	static void setBitRate(uint32_t rate);
	static uint32_t getDeviation();
	static void setDeviation(uint32_t dev);
	static void setFrequency(uint32_t freqHz);
	static void setPowerLevel(uint8_t powerLevel);
#if RFM69_SHELL_CMD
	static void dumpReg(OutStream *strm);
#endif
#if RFM69_SHELL_CHAR
	static void dumpReg();
#endif

	static void waitForModeRdy();
	static void setMode(TRFM69_MODE newMode);
	static void setHighPowerRegs(bool onOff);
	static uint8_t readTemperature(uint8_t calFactor);
	static void encrypt(const char *key);
	static int readRSSI_hd(bool forceTrigger = false);
	static float readRSSI(bool forceTrigger = false);
	static bool canSend();
	static bool readIrqPin();
	static bool reciveTick();
	static void receiveBegin();
	static void InitIO();

public:
	static RadioRecord recVar;

	static bool Init(const RFMCfg *cfg);
#if RFM69_SHELL_CMD
	static void shell(OutStream *strm, const char *cmd);
#endif

#if RFM69_SHELL_CHAR
	static bool shell(char key);
#endif

	static void tick();
	static TRfmErrorDef sendPacket(uint8_t myAddress, const void *buffer, uint8_t bufferSize);
	static uint32_t getFrequency();
	static bool readINT();
	static int getChannelFreq(int channel);
	static bool identifyDev();
	static void setPAMode(PAMode mode);
	static bool isNewFrame();
	static void setSleepMode(){
		setMode(modeSLEEP);
	}
	static void setStandByMode(){
		setMode(modeSTANDBY);
	}

	static void setReciveMode(){
		setMode(modeRX);
	}

};

#endif

