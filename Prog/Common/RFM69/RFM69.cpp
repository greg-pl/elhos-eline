#include "string.h"
#include "stdio.h"

#include "RFM69.h"
#include "main.h"
#include "UMain.h"

#if RFM69_SHELL_CMD
#include "ShellItem.h"
#include "utils.h"
#include <Token.h>
#endif

//------------------------------------------------------------------------
// SPI_1
//------------------------------------------------------------------------
SPI_HandleTypeDef SPI_1::hspi;

void SPI_1::Init() {
	hspi.Instance = SPI1;
	hspi.Init.Mode = SPI_MODE_MASTER;
	hspi.Init.Direction = SPI_DIRECTION_2LINES;
	hspi.Init.DataSize = SPI_DATASIZE_8BIT;
	hspi.Init.CLKPolarity = SPI_POLARITY_LOW;
	hspi.Init.CLKPhase = SPI_PHASE_1EDGE;
	hspi.Init.NSS = SPI_NSS_SOFT;
	hspi.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_16;
	hspi.Init.FirstBit = SPI_FIRSTBIT_MSB;
	hspi.Init.TIMode = SPI_TIMODE_DISABLE;
	hspi.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
	hspi.Init.CRCPolynomial = 10;
	HAL_SPI_Init(&hspi);

}

uint8_t SPI_1::RW(uint8_t reg) {
	uint8_t rec;
	HAL_SPI_TransmitReceive(&hspi, &reg, &rec, 1, 1000);
	return rec;
}

HAL_StatusTypeDef SPI_1::Transmit(const uint8_t *pData, uint16_t Size) {
	return HAL_SPI_Transmit(&hspi, (uint8_t*) (uint32_t) pData, Size, 1000);
}

HAL_StatusTypeDef SPI_1::Receive(uint8_t *pData, uint16_t Size) {
	return HAL_SPI_Receive(&hspi, pData, Size, 1000);
}

extern "C" void InitRfm73TrEn(void);
extern "C" void SetRfm73TrEn(bool state);

//------------------------------------------------------------------------
// RFM69
//------------------------------------------------------------------------
#include "RFM69registers.h"

#define RF69_FSTEP  61.03515625 // == FXOSC / 2^19 = 32MHz / 2^19 (p13 in datasheet)
#define CSMA_LIMIT              -90 //-100 // upper RX signal sensitivity threshold in dBm for carrier sense access
#define COURSE_TEMP_COEF        -90 // puts the temperature reading in the ballpark, user can fine tune the returned value
#define RF69_CSMA_LIMIT_MS     1000
#define RF69_TX_LIMIT_MS   	   1000
#define RF69_BROADCAST_ADDR     255

TRFM69_MODE RFM69::mMode;        // current transceiver state
PAMode RFM69::mPA_Mode;
RadioRecord RFM69::recVar;
uint8_t RFM69::mPowerLevel;
TRFM69_Params RFM69::mParam;
bool RFM69::mNewframe;
bool RFM69::mShowRecFrame;

char RFM69::txt[120];

#define MY_NETWORK_ID 0x47
//#define BAUDRATE  19200 // 4800, 19200, 38400, 300000

void RFM69::CS_DN() {
	HAL_GPIO_WritePin(R_CS_GPIO_Port, R_CS_Pin, GPIO_PIN_RESET);
}
void RFM69::CS_UP() {
	HAL_GPIO_WritePin(R_CS_GPIO_Port, R_CS_Pin, GPIO_PIN_SET);
}
void RFM69::RESET_DN() {
	HAL_GPIO_WritePin(R_RESET_GPIO_Port, R_RESET_Pin, GPIO_PIN_RESET);
}
void RFM69::RESET_UP() {
	HAL_GPIO_WritePin(R_RESET_GPIO_Port, R_RESET_Pin, GPIO_PIN_SET);
}

bool RFM69::readINT() {
	return (HAL_GPIO_ReadPin(R_INT_GPIO_Port, R_INT_Pin) == GPIO_PIN_RESET);
}

void RFM69::InitIO() {
	GPIO_InitTypeDef GPIO_InitStruct;

	GPIO_InitStruct.Pin = R_CS_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(R_CS_GPIO_Port, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = R_RESET_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(R_RESET_GPIO_Port, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = R_INT_Pin;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(R_INT_GPIO_Port, &GPIO_InitStruct);

	CS_UP();
	RESET_UP();
	SPI_1::Init();
}

#define SLINE_FREQ_BASE         868050000
#define SLINE_FREQ_CHANNEL_WIDE    100000

int RFM69::getChannelFreq(int channel) {
	return SLINE_FREQ_BASE + channel * SLINE_FREQ_CHANNEL_WIDE;
}

bool RFM69::Init(const RFMCfg *cfg) {

	mNewframe = false;
	mShowRecFrame = false;
	mPowerLevel = 31;
	mPA_Mode = paMode1;
	mMode = modeSTANDBY;

	InitIO();
	CS_UP();
	RESET_UP();
	HAL_Delay(2);
	RESET_DN();
	HAL_Delay(10);

	const uint8_t CONFIG[][2] = {
	/* 0x01 */{ REG_OPMODE, RF_OPMODE_SEQUENCER_ON | RF_OPMODE_LISTEN_OFF | RF_OPMODE_STANDBY },
	/* 0x02 */{ REG_DATAMODUL, RF_DATAMODUL_DATAMODE_PACKET | RF_DATAMODUL_MODULATIONTYPE_FSK | RF_DATAMODUL_MODULATIONSHAPING_00 }, // no shaping

			// looks like PA1 and PA2 are not implemented on RFM69W, hence the max output power is 13dBm
			// +17dBm and +20dBm are possible on RFM69HW
			// +13dBm formula: Pout = -18 + OutputPower (with PA0 or PA1**)
			// +17dBm formula: Pout = -14 + OutputPower (with PA1 and PA2)**
			// +20dBm formula: Pout = -11 + OutputPower (with PA1 and PA2)** and high power PA settings (section 3.3.7 in datasheet)
			///* 0x11 */ { REG_PALEVEL, RF_PALEVEL_PA0_ON | RF_PALEVEL_PA1_OFF | RF_PALEVEL_PA2_OFF | RF_PALEVEL_OUTPUTPOWER_11111},
			///* 0x13 */ { REG_OCP, RF_OCP_ON | RF_OCP_TRIM_95 }, // over current protection (default is 95mA)

			// RXBW defaults are { REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_24 | RF_RXBW_EXP_5} (RxBw: 10.4KHz)
			/* 0x25 */{ REG_DIOMAPPING1, RF_DIOMAPPING1_DIO0_01 }, // DIO0 is the only IRQ we're using
			/* 0x26 */{ REG_DIOMAPPING2, RF_DIOMAPPING2_CLKOUT_OFF }, // DIO5 ClkOut disable for power saving
			/* 0x28 */{ REG_IRQFLAGS2, RF_IRQFLAGS2_FIFOOVERRUN }, // writing to this bit ensures that the FIFO & status flags are reset
			/* 0x29 */{ REG_RSSITHRESH, 220 }, // must be set to dBm = (-Sensitivity / 2), default is 0xE4 = 228 so -114dBm
			/* 0x2D */{ REG_PREAMBLELSB, RF_PREAMBLESIZE_LSB_VALUE }, // default 3 preamble uint8_ts 0xAAAAAA
			/* 0x2E */{ REG_SYNCCONFIG, RF_SYNC_ON | RF_SYNC_FIFOFILL_AUTO | RF_SYNC_SIZE_2 | RF_SYNC_TOL_0 },
			/* 0x2F */{ REG_SYNCVALUE1, 0x2D },      // attempt to make this compatible with sync1 uint8_t of RFM12B lib
			/* 0x30 */{ REG_SYNCVALUE2, MY_NETWORK_ID }, // NETWORK ID
			/* 0x37 */{ REG_PACKETCONFIG1, RF_PACKET1_FORMAT_VARIABLE | RF_PACKET1_DCFREE_OFF | RF_PACKET1_CRC_ON | RF_PACKET1_CRCAUTOCLEAR_ON
					| RF_PACKET1_ADRSFILTERING_OFF },
			/* 0x38 */{ REG_PAYLOADLENGTH, 66 }, // in variable length mode: the max frame size, not used in TX
			///* 0x39 */ { REG_NODEADRS, nodeID }, // turned off because we're not using address filtering
			/* 0x3C */{ REG_FIFOTHRESH, RF_FIFOTHRESH_TXSTART_FIFONOTEMPTY | RF_FIFOTHRESH_VALUE }, // TX on FIFO not empty
			/* 0x6F */{ REG_TESTDAGC, RF_DAGC_IMPROVED_LOWBETA0 }, // run DAGC continuously in RX mode for Fading Margin Improvement, recommended default for AfcLowBetaOn=0
			{ 255, 0 } };

	//sprawdzenie, odczekanie, czy uk�ad jest ju� obudzony
	uint32_t start = HAL_GetTick();
	uint8_t timeout = 50;
	while (HAL_GetTick() - start < timeout) {
		writeReg(REG_SYNCVALUE1, 0xAA);
		if (readReg(REG_SYNCVALUE1) == 0xAA)
			break;
	};
	start = HAL_GetTick();
	while (HAL_GetTick() - start < timeout) {
		writeReg(REG_SYNCVALUE1, 0x55);
		if (readReg(REG_SYNCVALUE1) == 0x55)
			break;
	};

	//wpisanie tablicy parametr�w
	for (int i = 0; CONFIG[i][0] != 255; i++)
		writeReg(CONFIG[i][0], CONFIG[i][1]);

	setFrequency(cfg->ChannelFreq);

	switch (cfg->BaudRate) {
	case bd4800:
		setBitRate(4800);
		setDeviation(10000);
		// (BitRate < 2 * RxBw) -> 125kHz ????
		writeReg(REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_16 | RF_RXBW_EXP_2); // REG_RXBW: 125kHz
		// RXRESTARTDELAY must match transmitter PA ramp-down time (bitrate dependent)
		writeReg(REG_PACKETCONFIG2, RF_PACKET2_RXRESTARTDELAY_2BITS | RF_PACKET2_AUTORXRESTART_ON | RF_PACKET2_AES_OFF);
		break;

	case bd19200:
		setBitRate(19200);
		setDeviation(20000);

		//writeReg(REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_24 | RF_RXBW_EXP_3 );  //  -> 41.7kHz
		writeReg(REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_16 | RF_RXBW_EXP_1); //  -> 250kHz

		// RXRESTARTDELAY must match transmitter PA ramp-down time (bitrate dependent)
		writeReg(REG_PACKETCONFIG2, RF_PACKET2_RXRESTARTDELAY_NONE | RF_PACKET2_AUTORXRESTART_ON | RF_PACKET2_AES_OFF);
		break;
	case bd38400:

		setBitRate(38400);
		setDeviation(40000);
		writeReg(REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_16 | RF_RXBW_EXP_1);  //  -> 250kHz
		// RXRESTARTDELAY must match transmitter PA ramp-down time (bitrate dependent)
		writeReg(REG_PACKETCONFIG2, RF_PACKET2_RXRESTARTDELAY_NONE | RF_PACKET2_AUTORXRESTART_ON | RF_PACKET2_AES_OFF);
		break;
	case bd300000:

		setDeviation(300000);
		setBitRate(300000);

		// Filter = 500kHz
		writeReg(REG_RXBW, RF_RXBW_DCCFREQ_010 | RF_RXBW_MANT_16 | RF_RXBW_EXP_0);  //REG_RXBW: 500kHz

		writeReg(REG_AFCBW, RF_AFCBW_DCCFREQAFC_100 | RF_AFCBW_MANTAFC_16 | RF_AFCBW_EXPAFC_0);  //REG_AFCBW: 500kHz

		writeReg(REG_RSSITHRESH, 240);   //set REG_RSSITHRESH to -120dBm
		break;
	}

	// Encryption is persistent between resets and can trip you up during debugging.
	// Disable it during initialization so we always start from a known state.
	encrypt(0);

	setPAMode((PAMode) cfg->PAMode);
	setPowerLevel(cfg->TxPower);
	setMode(modeRX);

	// wait for ModeReady
	start = HAL_GetTick();
	while (((readReg(REG_IRQFLAGS1) & RF_IRQFLAGS1_MODEREADY) == 0x00)) {
		if (HAL_GetTick() - start > timeout) {
			return false;
		}
	}

	return true;
}

bool RFM69::readIrqPin() {
	return (HAL_GPIO_ReadPin(R_INT_GPIO_Port, R_INT_Pin) != 0);
}

uint8_t RFM69::readReg(uint8_t addr) {
	CS_DN();
	SPI_1::RW(addr); // Select register to read from..
	uint8_t value = SPI_1::RW(0); // ..then read register value
	CS_UP();
	return value;
}

void RFM69::writeReg(uint8_t addr, uint8_t value) {
	CS_DN();
	SPI_1::RW(addr | 0x80); // Select register to read from..
	SPI_1::RW(value); // ..then read register value
	CS_UP();
}

void RFM69::writeMReg(uint8_t addr, const uint8_t *ptr, int cnt) {
	CS_DN();
	SPI_1::RW(addr | 0x80); // Select register to read from..
	for (int i = 0; i < cnt; i++) {
		SPI_1::RW(*ptr); // ..then read register ptr
		ptr++;
	}
	CS_UP();
}

void RFM69::modifyReg(uint8_t addr, uint8_t mask, uint8_t value) {
	uint8_t v = readReg(addr);
	v = v & ~mask;
	v = v | value;
	writeReg(addr, v);
}

// internal function
void RFM69::setHighPowerRegs(bool onOff) {
	writeReg(REG_TESTPA1, onOff ? 0x5D : 0x55);
	writeReg(REG_TESTPA2, onOff ? 0x7C : 0x70);
}

// set *transmit/TX* output power: 0=min, 31=max
// this results in a "weaker" transmitted signal, and directly results in a lower RSSI at the receiver
// the power configurations are explained in the SX1231H datasheet (Table 10 on p21; RegPaLevel p66): http://www.semtech.com/images/datasheet/sx1231h.pdf
// valid powerLevel parameter values are 0-31 and result in a directly proportional effect on the output/transmission power
// this function implements 2 modes as follows:
//       - for RFM69W the range is from 0-31 [-18dBm to 13dBm] (PA0 only on RFIO pin)
//       - for RFM69HW the range is from 0-31 [5dBm to 20dBm]  (PA1 & PA2 on PA_BOOST pin & high Power PA settings - see section 3.3.7 in datasheet, p22)
void RFM69::setPowerLevel(uint8_t powerLevel) {
	mPowerLevel = (powerLevel > 31 ? 31 : powerLevel);
	if (mPA_Mode == paMode4)
		mPowerLevel /= 2;
	writeReg(REG_PALEVEL, (readReg(REG_PALEVEL) & 0xE0) | mPowerLevel);
}

// for RFM69HW only: you must call setHighPower(true) after initialize() or else transmission won't work
void RFM69::setPAMode(PAMode mode) {
	mPA_Mode = mode;
	writeReg(REG_OCP, (mPA_Mode == paMode4) ? RF_OCP_OFF : RF_OCP_ON);
	uint8_t val = readReg(REG_PALEVEL) & 0x1F;
	switch (mPA_Mode) {
	case paMode1:
		val |= RF_PALEVEL_PA0_ON;
		break;
	case paMode2:
		val |= RF_PALEVEL_PA1_ON;
		break;
	case paMode3:
	case paMode4:
		val |= RF_PALEVEL_PA1_ON | RF_PALEVEL_PA2_ON;
		break;
	}
	writeReg(REG_PALEVEL, val);
}

void RFM69::setMode(TRFM69_MODE newMode) {
	if (newMode == mMode)
		return;

	switch (newMode) {
	case modeTX:
		modifyReg(REG_OPMODE, 0x1C, RF_OPMODE_TRANSMITTER);
		setHighPowerRegs(mPA_Mode == paMode4);
		break;
	case modeRX:
		modifyReg(REG_OPMODE, 0x1C, RF_OPMODE_RECEIVER);
		setHighPowerRegs(false);
		break;
	case modeSYNTH:
		modifyReg(REG_OPMODE, 0x1C, RF_OPMODE_SYNTHESIZER);
		break;
	case modeSTANDBY:
		modifyReg(REG_OPMODE, 0x1C, RF_OPMODE_STANDBY);
		break;
	case modeSLEEP:
		modifyReg(REG_OPMODE, 0x1C, RF_OPMODE_SLEEP);
		break;
	default:
		return;
	}

	// we are using packet mode, so this check is not really needed
	// but waiting for mode ready is necessary when going from sleep because the FIFO may not be immediately available from previous mode
	if (mMode == modeSLEEP) {
		while ((readReg(REG_IRQFLAGS1) & RF_IRQFLAGS1_MODEREADY) == 0x00) {

		}; // wait for ModeReady
	}
	mMode = newMode;
}

// return the frequency (in Hz)
uint32_t RFM69::getFrequency() {
	uint32_t r1 = readReg(REG_FRFMSB);
	uint32_t r2 = readReg(REG_FRFMID);
	uint32_t r3 = readReg(REG_FRFLSB);
	return (int) (RF69_FSTEP * ((r1 << 16) | (r2 << 8) | r3));
}

// set the frequency (in Hz)
void RFM69::setFrequency(uint32_t freqHz) {
	TRFM69_MODE oldMode = mMode;
	if (oldMode == modeTX) {
		setMode(modeRX);
	}
	freqHz /= RF69_FSTEP; // divide down by FSTEP to get FRF
	writeReg(REG_FRFMSB, freqHz >> 16);
	writeReg(REG_FRFMID, freqHz >> 8);
	writeReg(REG_FRFLSB, freqHz);
	if (oldMode == modeRX) {
		setMode(modeSYNTH);
	}
	setMode(oldMode);
}

#define FOSC 32000000.0
uint32_t RFM69::getBitRate() {
	uint32_t r1 = readReg(REG_BITRATEMSB);
	uint32_t r2 = readReg(REG_BITRATELSB);
	uint32_t r = ((r1 << 8) | r2);

	return FOSC / r;
}

void RFM69::setBitRate(uint32_t rate) {
	uint32_t r = FOSC / rate;
	writeReg(REG_BITRATEMSB, r >> 8);
	writeReg(REG_BITRATELSB, r & 0xff);
}

uint32_t RFM69::getDeviation() {
	uint32_t r1 = readReg(REG_FDEVMSB);
	uint32_t r2 = readReg(REG_FDEVLSB);
	uint32_t freqDev = ((r1 & 0x3f) << 8) | r2;
	return 61 * freqDev;
}

void RFM69::setDeviation(uint32_t dev) {
	dev /= 61;
	if (dev > 0x3fff)
		dev = 0x3fff;
	writeReg(REG_FDEVMSB, dev >> 8);
	writeReg(REG_FDEVLSB, dev & 0xff);
}

// returns centigrade
uint8_t RFM69::readTemperature(uint8_t calFactor) {
	setMode(modeSTANDBY);
	writeReg(REG_TEMP1, RF_TEMP1_MEAS_START);
	while ((readReg(REG_TEMP1) & RF_TEMP1_MEAS_RUNNING))
		;
	return ~readReg(REG_TEMP2) + COURSE_TEMP_COEF + calFactor; // 'complement' corrects the slope, rising temp = rising val
}

// To enable encryption: radio.encrypt("ABCDEFGHIJKLMNOP");
// To disable encryption: radio.encrypt(null) or radio.encrypt(0)
// KEY HAS TO BE 16 uint8_ts !!!
void RFM69::encrypt(const char *key) {
	setMode(modeSTANDBY);
	if (key != 0) {
		writeMReg(REG_AESKEY1, (const uint8_t*) key, 16);
	}
	modifyReg(REG_PACKETCONFIG2, 0x01, (key ? 1 : 0));
}

// internal function
TRfmErrorDef RFM69::sendPacket(uint8_t myAddress, const void *buffer, uint8_t bufferSize) {
	modifyReg(REG_PACKETCONFIG2, 0x04, RF_PACKET2_RXRESTART); // avoid RX deadlocks

	setMode(modeSTANDBY); // turn off receiver to prevent reception while filling fifo
	while ((readReg(REG_IRQFLAGS1) & RF_IRQFLAGS1_MODEREADY) == 0x00) {
		// wait for ModeReady
	}
	if (bufferSize > RF69_MAX_DATA_LEN)
		bufferSize = RF69_MAX_DATA_LEN;

	// write to FIFO
	CS_DN();
	SPI_1::RW(REG_FIFO | 0x80);
	SPI_1::RW(bufferSize + 1);
	SPI_1::RW(myAddress);

	const uint8_t *pBuf = (const uint8_t*) buffer;
	for (uint8_t i = 0; i < bufferSize; i++)
		SPI_1::RW(pBuf[i]);
	CS_UP();

	// no need to wait for transmit mode to be ready since its handled by the radio
	setMode(modeTX);

	// wait for signalling transmission finish
	TRfmErrorDef st = stRFM_OK;
	uint32_t txStart = HAL_GetTick();
	while (true) {
		if (HAL_GetTick() - txStart > RF69_TX_LIMIT_MS) {
			st = stRFM_TXERROR;
			break;
		}
		if ((readReg(REG_IRQFLAGS2) & RF_IRQFLAGS2_PACKETSENT) != 0) {
			break;
		}
	}
	receiveBegin();
	return st;
}

// get the received signal strength indicator (RSSI)
int RFM69::readRSSI_hd(bool forceTrigger) {
	if (forceTrigger) {
		// RSSI trigger not needed if DAGC is in continuous mode
		writeReg(REG_RSSICONFIG, RF_RSSI_START);
		while ((readReg(REG_RSSICONFIG) & RF_RSSI_DONE) == 0x00) {
			// wait for RSSI_Ready
		}
	}
	return readReg(REG_RSSIVALUE);
}

// get the received signal strength indicator (RSSI)
float RFM69::readRSSI(bool forceTrigger) {
	return -0.5 * readRSSI_hd(forceTrigger);
}

bool RFM69::canSend() {
	return (readRSSI() < CSMA_LIMIT);
}

// returns true if frame is recived
bool RFM69::reciveTick() {
	if (mMode == modeRX) {
		if (readReg(REG_IRQFLAGS2) & RF_IRQFLAGS2_PAYLOADREADY) {

			setMode(modeSTANDBY);
			CS_DN();
			SPI_1::RW(REG_FIFO & 0x7F);
			int payloadLen = SPI_1::RW(0);
			if (payloadLen > RF69_MAX_DATA_LEN)
				payloadLen = RF69_MAX_DATA_LEN;

			recVar.DataLen = payloadLen - 1;

			recVar.SenderID = SPI_1::RW(0);
			for (uint8_t i = 0; i < recVar.DataLen; i++) {
				recVar.DataBuf[i] = SPI_1::RW(0);
			}
			if (recVar.DataLen < RF69_MAX_DATA_LEN)
				recVar.DataBuf[recVar.DataLen] = 0; // add null at end of string

			CS_UP();
			setMode(modeRX);
			recVar.RSSI_hd = readReg(REG_RSSIVALUE);
			recVar.RSSI = -0.5 * recVar.RSSI_hd;
			mNewframe = true;
			if (mShowRecFrame) {
#if RFM69_SHELL_CMD
				int n = snprintf(txt, sizeof(txt), "RAD:Snd=%u L=%u RSSI=%.1fdBm ", recVar.SenderID, recVar.DataLen, recVar.RSSI);
				for (int i = 0; i < recVar.DataLen; i++) {
					n += snprintf(&txt[n], sizeof(txt) - n, "%02X ", recVar.DataBuf[i]);
				}
				getOutStream()->oMsgX(colYELLOW, txt);

#endif
#if RFM69_SHELL_CHAR
				int n = snprintf(txt, sizeof(txt), "RADIO: Snd=%u Len=%u RSSI=%df[dBm/2] ", recVar.SenderID, recVar.DataLen, -recVar.RSSI_hd);
				for (int i = 0; i < recVar.DataLen; i++) {
					n += snprintf(&txt[n], sizeof(txt) - n, "%02X ", recVar.DataBuf[i]);
				}
				n += snprintf(&txt[n], sizeof(txt) - n, "\r\n");
				printf(txt);

#endif
			}

			return true;
		} else
			recVar.RSSI = readRSSI();
	}
	return false;
}

void RFM69::receiveBegin() {
	memset(&recVar, 0, sizeof(recVar));
	if (readReg(REG_IRQFLAGS2) & RF_IRQFLAGS2_PAYLOADREADY)
		modifyReg(REG_PACKETCONFIG2, 0x04, RF_PACKET2_RXRESTART); // avoid RX deadlocks
	setMode(modeRX);
}

#if  (RFM69_SHELL_CMD || RFM69_SHELL_CHAR)

const char *const tabNames[] = { //
		"FIFO", //
				"OPMODE", //
				"DATAMODUL", //
				"BITRATEMSB", //
				"BITRATELSB", //
				"FDEVMSB", //
				"FDEVLSB", //
				"FRFMSB", //
				"FRFMID", //
				"FRFLSB", //
				"OSC1", //
				"AFCCTRL", //
				"LOWBAT", //
				"LISTEN1", //
				"LISTEN2", //
				"LISTEN3", //
				"VERSION", //0x10
				"PALEVEL", //
				"PARAMP", //
				"OCP", //
				"AGCREF", //
				"AGCTHRESH1", //
				"AGCTHRESH2", //
				"AGCTHRESH3", //
				"LNA", //
				"RXBW", //
				"AFCBW", //
				"OOKPEAK", //
				"OOKAVG", //
				"OOKFIX", //
				"AFCFEI", //
				"AFCMSB", //
				"AFCLSB", // 0x20
				"FEIMSB", //
				"FEILSB", //
				"RSSICONFIG", //
				"RSSIVALUE", //
				"DIOMAPPING1", //
				"DIOMAPPING2", //
				"IRQFLAGS1", //
				"IRQFLAGS2", //
				"RSSITHRESH", //
				"RXTIMEOUT1", //
				"RXTIMEOUT2", //
				"PREAMBLEMSB", //
				"PREAMBLELSB", //
				"SYNCCONFIG", //
				"SYNCVALUE1", // 0x2F
				"SYNCVALUE2", // 0x30
				"SYNCVALUE3", //
				"SYNCVALUE4", //
				"SYNCVALUE5", //
				"SYNCVALUE6", //
				"SYNCVALUE7", //
				"SYNCVALUE8", //
				"PACKETCONFIG1", //
				"PAYLOADLENGTH", //
				"NODEADRS", //
				"BROADCASTADRS", //
				"AUTOMODES", //
				"FIFOTHRESH", //
				"PACKETCONFIG2", //
				"AESKEY1", // 0x3E
				"AESKEY2", //
				"AESKEY3", // 0x40
				"AESKEY4", //
				"AESKEY5", //
				"AESKEY6", //
				"AESKEY7", //
				"AESKEY8", //
				"AESKEY9", //
				"AESKEY10", //
				"AESKEY11", //
				"AESKEY12", //
				"AESKEY13", //
				"AESKEY14", //
				"AESKEY15", //
				"AESKEY16", //
				"TEMP1", //
				"TEMP2", //

		};
#endif

#if RFM69_SHELL_CMD

void RFM69::dumpReg(OutStream *strm) {
	uint8_t tab[0x50];
	for (int n = 1; n < 0x50; n++) {
		tab[n] = readReg(n);
	}

	if (strm->oOpen(colWHITE)) {
		for (int i = 1; i < 0x50; i++) {
			int n = snprintf(txt, sizeof(txt), "%02X. ", i);
			n += snprintf(&txt[n], sizeof(txt) - n, "%-14s ", tabNames[i]);

			uint8_t regVal = tab[i];

			if (regVal == 0)
				n += snprintf(&txt[n], sizeof(txt) - n, "0        ");
			else if (regVal == 255)
				n += snprintf(&txt[n], sizeof(txt) - n, "FF       ");
			else
				n += snprintf(&txt[n], sizeof(txt) - n, "%.3u,0x%02x ", regVal, regVal);

			switch (i) {
			case REG_BITRATEMSB:
				n += snprintf(&txt[n], sizeof(txt) - n, "BitRate=%u", (int) getBitRate());
				break;
			case REG_FDEVMSB:
				n += snprintf(&txt[n], sizeof(txt) - n, "deviation=%u", (int) getDeviation());
				break;
			case REG_FRFMSB:
				n += snprintf(&txt[n], sizeof(txt) - n, "freq=%u[Hz]", (int) getFrequency());
				break;
			case REG_VERSION:
				n += snprintf(&txt[n], sizeof(txt) - n, "ChipVersion");
				break;
			}
			strm->oMsg(txt);
			if ((i & 0x0F) == 0x0F)
				osDelay(300);

		}
		strm->oClose();
	}

}
#endif

#if  RFM69_SHELL_CHAR

void RFM69::dumpReg() {
	uint8_t tab[0x50];
	for (int n = 1; n < 0x50; n++) {
		tab[n] = readReg(n);
	}

	for (int n = 1; n < 0x50; n++) {
		printf("%02X. ", n);
		HAL_Delay(20);
		printf("%s ", tabNames[n]);

		uint8_t regVal = tab[n];

		if (regVal == 0)
			printf("0        ");
		else if (regVal == 255)
			printf("FF       ");
		else
			printf("%.3u,0x%02x ", regVal, regVal);

		switch (n) {
		case REG_BITRATEMSB:
			printf("BitRate=%u", (int) getBitRate());
			break;
		case REG_FDEVMSB:
			printf("deviation=%u", (int) getDeviation());
			break;
		case REG_FRFMSB:
			printf("freq=%u[Hz]", (int) getFrequency());
			break;
		case REG_VERSION:
			printf("ChipVersion");
			break;
		}

		printf("\r\n");
	}
}

#endif

bool RFM69::identifyDev() {
	RESET_UP();
	HAL_Delay(2);
	RESET_DN();
	HAL_Delay(10);

	writeReg(REG_SYNCVALUE1, 0x11);
	writeReg(REG_SYNCVALUE2, 0x22);
	uint8_t a1 = readReg(REG_SYNCVALUE1);
	uint8_t a2 = readReg(REG_SYNCVALUE2);
	writeReg(REG_SYNCVALUE1, 0);
	writeReg(REG_SYNCVALUE2, 0);
	return ((a1 == 0x11) && (a2 == 0x22));
}

bool RFM69::isNewFrame() {
	bool q = mNewframe;
	mNewframe = false;
	return q;
}

void RFM69::tick() {
	reciveTick();
}

#if RFM69_SHELL_CMD

const ShellItem menuRFM[] = { //
		{ "s", "stan" }, //
				{ "show", "wyświetl odebrane dane" }, //
				{ "freq", "pokaż częstotliwość" }, //
				{ "reg", "dump RFm69 registry" }, //
				{ "send", "send user frame" }, //
				{ "rssi", "read rssi" }, //
				{ NULL, NULL } };

void RFM69::shell(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuRFM, tok);
	switch (idx) {
	case 0: //s
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("Mode=%u", mMode);
			strm->oMsg("PAMode=%u", mPA_Mode);
			strm->oMsg("REG_OPMODE=%u", (readReg(REG_OPMODE) >> 2) & 0x07);
			strm->oMsg("REG_IRQFLAGS1=0x%02X", readReg(REG_IRQFLAGS1));
			strm->oMsg("REG_IRQFLAGS2=0x%02X", readReg(REG_IRQFLAGS2));
			strm->oMsg("REG_RSSIVALUE=%.1f[dBm]", -0.5 * readReg(REG_RSSIVALUE));
			uint8_t b = readReg(REG_OCP);
			strm->oMsg("OCP: OverCurrent, On=%u Limit=%u[mA]", ((b & 0x10) != 0), 45 + 5 * (b & 0x0f));
			strm->oClose();
		}
		break;
	case 1: //show
		Token::getAsBool(&cmd, &mShowRecFrame);
		strm->oMsgX(colWHITE, "ShowData=%u", mShowRecFrame);
		break;
	case 2: //freq
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("freq=%u[Hz]", (int) getFrequency());
			strm->oMsg("BitRate=%u[bit/sek]", (int) getBitRate());
			strm->oMsg("Deviation=%u[Hz]", (int) getDeviation());
			strm->oMsg("Temp=%u", readTemperature(0));
			strm->oClose();
		}
		break;
	case 3: //reg
		dumpReg(strm);
		break;
	case 4: { //send
		int myAddress;
		char buf[40];
		if (Token::getAsInt(&cmd, &myAddress)) {
			if (Token::get(&cmd, buf, sizeof(buf))) {
				TRfmErrorDef err = sendPacket(myAddress, (const uint8_t*) buf, strlen(buf));
				strm->oMsgX(colWHITE, "sendBuf st=%d", err);

			}
		}
	}
		break;
	case 5: //rssi
		strm->oMsg("RSSI=%.1f[dBm]", readRSSI(1));
		break;

	default:
		showHelp(strm, "RFM69 Menu", menuRFM);
		break;
	}
}

#endif

#if RFM69_SHELL_CHAR

bool RFM69::shell(char key) {
	uint8_t w, w1;
	switch (key) {
	case 27:
		return true;
	case 'f':
		printf("freq=%u[Hz]\r\n", (int) getFrequency());
		printf("BitRate=%u[bit/sek]\r\n", (int) getBitRate());
		printf("Deviation=%u[Hz]\r\n", (int) getDeviation());
		break;
	case 's':
		printf("Mode=%u\r\n", mMode);
		printf("PAMode=%u\r\n", mPA_Mode);
		printf("REG_OPMODE=%u\r\n", (readReg(REG_OPMODE) >> 2) & 0x07);
		printf("REG_IRQFLAGS1=0x%02X\r\n", readReg(REG_IRQFLAGS1));
		printf("REG_IRQFLAGS2=0x%02X\r\n", readReg(REG_IRQFLAGS2));
		printf("REG_RSSIVALUE=%d[*0.5 dBm]\r\n", -readReg(REG_RSSIVALUE));
		break;
	case 'l':
		printf("RSSI=%d[0.5*dBm]\r\n", - readRSSI_hd(true));
		break;

	case '>':
		w = readReg(REG_DIOMAPPING2);

		w1 = w & 0x07;
		w1 = (w1 + 1) & 0x07;
		w = (w & 0xF8) | w1;
		writeReg(REG_DIOMAPPING2, w);
		printf("ClkOut=%u\r\n", w1);
		break;

	case 'r':
		printf("reciveBegin\r\n");
		receiveBegin();
		break;

	case 'd':
		dumpReg();
		break;
	case 'T':
		printf("Temp=%u\r\n", readTemperature(0));
		break;
	case 'Y':
		setMode(modeSTANDBY);
		printf("StandBy Mode\r\n");
		break;
	case 'S':
		setMode(modeSYNTH);
		printf("SYNTH Mode\r\n");
		break;
	case 'k':
		mShowRecFrame = !mShowRecFrame;
		printf("mShowRecFrame=%u\r\n", mShowRecFrame);
		break;

	default:
		printf( //
				"d - dump registers\r\n"
						"s - status\r\n"
						"> - Switch clkOut\r\n"
						"e - send frame\r\n"
						"E - continuos send frame\r\n"
						"R - send replay\r\n"
						"r - Recive begin\r\n"
						"l - read RSSI\r\n"
						"Y - StandBy Mode\r\n"
						"S - SYNTH Mode\r\n"
						"f - show freq\r\n"
						"k - show recFrames");
		break;
	}
	return false;
}

#endif
