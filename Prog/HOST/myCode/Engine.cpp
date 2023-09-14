/*
 * Engine.cpp
 *
 *  Created on: 20 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>

#include <Engine.h>
#include "I2cFrontExp.h"
#include "Hdw.h"
#include "UMain.h"
#include "KObj.h"
#include "Config.h"
#include "ModbusMaster.h"

extern I2cFront *frontPanel; // expander I2C na płycie czołowej

enum {
#include  "Host.ctg"
};

extern Config *config;
extern TModbusMaster *modbusMaster;

//-------------------------------------------------------------------------------
// Buzzer
//-------------------------------------------------------------------------------



typedef struct {
	bool on;
	int time;
} Nuta;

#define SND_END   {0,0}
#define SND_BRQ   {0,40}
#define SND_BRS   {0,80}
#define SND_BRK   {0,200}
#define SND_Q     {1,20}
#define SND_K     {1,60}
#define SND_D     {1,200}
#define SND_L     {1,500}

const Nuta tab_Q[] = {
		SND_Q, SND_END };
const Nuta tab_K[] = {
		SND_K, SND_END };
const Nuta tab_D[] = {
		SND_D, SND_END };
const Nuta tab_DD[] = {
		SND_D, SND_BRS, SND_D, SND_END };
const Nuta tab_L[] = {
		SND_L, SND_END };
const Nuta tab_KK[] = {
		SND_K, SND_BRS, SND_K, SND_END };
const Nuta tab_KKK[] = {
		SND_K, SND_BRQ, SND_K, SND_BRQ, SND_K, SND_END };
const Nuta tab_DDD[] = {
		SND_D, SND_BRK, SND_D, SND_BRK, SND_D, SND_END };
const Nuta tab_DKKK[] = {
		SND_D, SND_BRS, SND_K, SND_BRS, SND_K, SND_BRS, SND_K, SND_END };
const Nuta tab_LL[] = {
		SND_L, SND_BRK, SND_L, SND_END };
const Nuta tab_DKK[] = {
		SND_D, SND_BRS, SND_K, SND_BRS, SND_K, SND_END };
const Nuta tab_QQQQ[] = {
		SND_Q, SND_BRQ, SND_Q, SND_BRQ, SND_Q, SND_BRQ, SND_Q, SND_END };

class Buzzer {
private:
	static dword mTime;
	static dword mStarTick;
	static const Nuta *nutaPtr;
	static Nuta mBeepTab[2];
	static void hdSound(bool on);

public:
	static void Init();
	static void tick();
	static void Sound(int ton, int time);
	static void Sound(const Nuta *tab);
	static void Sound(SndSign sign);
};

dword Buzzer::mTime;
dword Buzzer::mStarTick;
const Nuta *Buzzer::nutaPtr;
Nuta Buzzer::mBeepTab[2];

void Buzzer::Init() {
	nutaPtr = NULL;
}

void Buzzer::hdSound(bool on) {
	mStarTick = HAL_GetTick();
	Hdw::setBuzzer(on);
}

void Buzzer::tick() {
	if (nutaPtr != NULL) {
		if ((int) (HAL_GetTick() - mStarTick) > nutaPtr->time) {
			nutaPtr++;
			if (nutaPtr->time > 0) {
				if (nutaPtr->on == 0) {
					hdSound(false);
				} else {
					hdSound(nutaPtr->on);
				}
			} else {
				hdSound(false);
				nutaPtr = NULL;
			}
		}
	}
}

void Buzzer::Sound(const Nuta *tab) {
	nutaPtr = tab;
	hdSound(tab[0].on);
}

void Buzzer::Sound(int ton, int time) {
	mBeepTab[0].time = time;
	mBeepTab[0].on = ton;
	mBeepTab[1].time = 0;
	mBeepTab[1].on = 0;
	Sound(mBeepTab);
}

void Buzzer::Sound(SndSign sign) {
	const Nuta *tab;
	switch (sign) {
	default:
	case ssK:
		tab = tab_K;
		break;
	case ssKK:
		tab = tab_KK;
		break;
	case ssKKK:
		tab = tab_KKK;
		break;
	case ssD:
		tab = tab_D;
		break;
	case ssDD:
		tab = tab_DD;
		break;
	case ssL:
		tab = tab_L;
		break;
	case ssDDD:
		tab = tab_DDD;
		break;
	case ssDKKK:
		tab = tab_DKKK;
		break;
	case ssLL:
		tab = tab_LL;
		break;
	case ssQ:
		tab = tab_Q;
		break;
	case ssDKK:
		tab = tab_DKK;
		break;
	case ssQQQQ:
		tab = tab_QQQQ;
		break;
	}
	Sound(tab);
}

//-------------------------------------------------------------------------------
// FiltrInp
//-------------------------------------------------------------------------------

FiltrInp::FiltrInp() {
	state = 0;
	mem = 0;
	chg = 0;
	mChgTick = 0;
}

void FiltrInp::inp(bool q) {
	if (q != mem) {
		mem = q;
		mChgTick = HAL_GetTick();
	}
	if (state != mem) {
		if (HAL_GetTick() - mChgTick > TM_FILTR) {
			state = mem;
			chg = true;
		}
	}
}

bool FiltrInp::isChg() {
	bool q = chg;
	chg = false;
	return q;
}

//-------------------------------------------------------------------------------
// Engine
//-------------------------------------------------------------------------------
Engine::Engine() {
	state.filtrInp1 = new FiltrInp();
	state.filtrInp2 = new FiltrInp();
	state.PkState = Hdw::getPKs();
	mMotocyklMode = false;
	memset(&mFalow, 0, sizeof(mFalow));

}

void Engine::setPk(int pknr, bool q) {

	uint8_t mask = 1 << pknr;
	if (q)
		state.PkState |= mask;
	else
		state.PkState &= ~mask;

	Hdw::setPk(pknr, q);
	frontPanel->setPK(state.PkState);
	frontPanel->updateLeds();
}

uint8_t Engine::getPKs() {
	return state.PkState;
}

void Engine::makeBuzzer(int snd) {
	Buzzer::Sound((SndSign) snd);

}

// rozkazy sterujące falownikiem
typedef enum {
	falTURNOFF = 1, //
	falTURN_FORW_SPEED1, //
	falTURN_FORW_SPEED2, //
	falTURN_BACK_SPEED1, //
	falTURN_BACK_SPEED2, //
	falTURN_EXITSUPPORT, //
	falTURN_FORW, //
	falTURN_BACK, //
	falTURNOFFFREE //
} FalFun;

enum {
	falfCMD, falfTURN_OFF, falfSPEED
};

enum {
	fal_LEFT = 1,  // numer falownika lewego na magistrali MODBUS
	fal_RIGHT = 2  // numer falownika prawego na magistrali MODBUS
};

typedef struct {
	uint8_t status;
	uint8_t falNr;
	uint8_t falCmd;
} TFalownikReply;

//rejstry modbus falownika LG
#define LG_REG_FREQ           5
#define LG_REG_CMD            6          // To jest numer_rejestru (numeracja rozpoczyna się od 1)
#define LG_ACCELERATION_TIME  7          // czas przyspieszania
#define LG_DECELERATION_TIME  8          // czas wyhamowywania

// bity w rejestrze  LG_REG_CMD
#define LG_CMD_TURNOFF      0x0001
#define LG_CMD_TURN_FORW    0x0002
#define LG_CMD_TURN_BACK    0x0004
#define LG_CMD_TURNOFFFREE  0x0010

typedef enum {
	speNOACT = 0,  //
	speSUPPORT,  //
	speLOW,  //
	speHIGH,  //
} SpeedMode;

typedef struct {
	FalFun fun;
	uint16_t falCmd;
	SpeedMode speedMode;
} FalCmdData;

const FalCmdData falCmdData[] = {  //
		{ falTURNOFF, LG_CMD_TURNOFF, speNOACT }, //
		{ falTURN_FORW_SPEED1, LG_CMD_TURN_FORW, speLOW }, //
		{ falTURN_FORW_SPEED2, LG_CMD_TURN_FORW, speHIGH }, //
		{ falTURN_BACK_SPEED1, LG_CMD_TURN_BACK, speLOW }, //
		{ falTURN_BACK_SPEED2, LG_CMD_TURN_BACK, speHIGH }, //
		{ falTURN_EXITSUPPORT, LG_CMD_TURN_FORW, speSUPPORT }, //
		{ falTURN_FORW, LG_CMD_TURN_FORW, speNOACT }, //
		{ falTURN_BACK, LG_CMD_TURN_BACK, speNOACT }, //
		{ falTURNOFFFREE, LG_CMD_TURNOFFFREE, speNOACT }, //
		{ (FalFun) 0, 0, speNOACT }, //
		};

void Engine::OnModbusDone(MdbReqItem *item) {
	TFalownikReply rply;

	switch (item->rmtParams.Id) {
	case falfSPEED:
		break;
	case falfCMD:
		rply.falNr = item->devNr;
		rply.status = item->Result;
		rply.falCmd = item->rmtParams.userCmd;
		item->rmtParams.trg->addToSend(dsdHOST, msgHostSterFalownik, &rply, sizeof(rply));
		item->rmtParams.trg->sendNow();
		getOutStream()->oMsgX(colYELLOW, "OnModbusDone FalNr=%d Cmd=%d Status=%d", rply.falNr, rply.falCmd, rply.status);
		break;
	}
	int pos = item->devNr - 1;
	if (pos >= 0 && pos < 2) {
		if (mFalow[pos].cmdInRun > 0)
			mFalow[pos].cmdInRun--;
		frontPanel->setLedUpdate(I2cFront::ledF1 + pos, (mFalow[pos].cmdInRun != 0));
	}
}

void Engine::SterFalownik(SvrTargetStream *trg, uint8_t falNr, uint8_t falCmd) {
	TFalownikReply rply;
	memset(&rply, 0, sizeof(rply));
	rply.falNr = falNr;
	rply.falCmd = falCmd;

	if (falNr == fal_LEFT || falNr == fal_RIGHT) {
		int pos = falNr - 1;
		const FalCmdData *falDt = falCmdData;
		const FalCmdData *fndDt = NULL;
		while (falDt->fun != 0) {
			if (falDt->fun == falCmd) {
				fndDt = falDt;
				break;
			}
			falDt++;
		}
		if (fndDt != NULL) {
			RmtParams params;
			params.client = this;
			params.strm = getOutStream();
			params.trg = trg;
			params.client = this;
			params.userCmd = falCmd;

			//ustawienie prdkości w falowniku
			if (fndDt->speedMode != speNOACT) {
				uint16_t freq;
				switch (fndDt->speedMode) {
				case speSUPPORT:
					freq = (uint16_t) (100 * config->data.R.H.falowFreqSupport);
					break;
				case speLOW:
					freq = (uint16_t) (100 * config->data.R.H.falowFreqLow);
					break;
				case speHIGH:
					freq = (uint16_t) (100 * config->data.R.H.falowFreqHigh);
					break;
				default:
					freq = 0;
				}
				if (freq != 0) {
					params.Delay = 40;
					params.Id = falfSPEED;
					modbusMaster->PushBufWrReg(&params, falNr, LG_REG_FREQ, freq);
					mFalow[pos].cmdInRun++;

				}
			}

			//komenda włączenia/wyłaczenia
			uint16_t cmd = fndDt->falCmd;
			if (cmd == LG_CMD_TURN_FORW || cmd == LG_CMD_TURN_BACK) {
				//jeśli włączanie, jest załączona blokada od podniesionych rolek
				if (config->data.R.E.emerRolerOffAfterBeamUp) {
					if (IsBelkiUp()) {
						rply.status = stBelkiUp;
					}
				}
			}

			if (mMotocyklMode && (falNr == fal_RIGHT)) {
				rply.status = stMotocyklMode;
			}
			if (rply.status == stOK) {
				mFalow[pos].run = (cmd == LG_CMD_TURN_FORW || cmd == LG_CMD_TURN_BACK);
				params.Delay = 0;
				params.Id = falfCMD;

				modbusMaster->PushBufWrReg(&params, falNr, LG_REG_CMD, cmd);
				mFalow[pos].cmdInRun++;
				frontPanel->setLedUpdate(I2cFront::ledF1 + pos, true);
			}
		} else
			rply.status = stUnknownFalCmd;
	} else
		rply.status = stUnknownFalNr;

	if (rply.status != 0) {
		trg->addToSend(dsdHOST, msgHostSterFalownik, &rply, sizeof(rply));
		trg->sendNow();

	}
}

bool Engine::IsBelkiUp() {
	return false;
}

void Engine::AwariaOff(int awarCode) {

}

void Engine::tick() {
	Buzzer::tick();
	state.filtrInp1->inp(Hdw::getInp1());
	state.filtrInp2->inp(Hdw::getInp2());
	if (state.filtrInp1->isChg() || state.filtrInp2->isChg()) {
		uint8_t b = 0;
		if (state.filtrInp1->getState())
			b |= 0x01;
		if (state.filtrInp2->getState())
			b |= 0x02;
		sendPcMsgNow(dsdHOST, msgHostInpState, &b, 1);
	}
}

