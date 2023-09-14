/*
 * CfgBase.cpp
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#include <CfgBase.h>
#include <string.h>

#include <I2cDev.h>
#include <utils.h>
#include <ShellItem.h>
#include <Token.h>
#include <CxBuf.h>

#define CFG_ADDR_RTCRAM   (BKPSRAM_BASE+0)
#define CFG_ADDR_FLASH    0x080E0000

extern FramI2c *framMem;

extern "C" __WEAK void doAftetNewCfg() {

}

CfgBase::CfgBase() {

}

TStatus CfgBase::save() {

	prepareToSave();
	HAL_PWR_EnableBkUpAccess();
	memcpy((void*) CFG_ADDR_RTCRAM, mDtInfo.adr, mDtInfo.size);
	HAL_PWR_DisableBkUpAccess();
	TStatus st = framMem->saveCfg(mDtInfo.adr, mDtInfo.size);
	doAftetNewCfg();
	return st;
}

TStatus CfgBase::LoadIntern(uint32_t adr) {

	memcpy(mDtInfo.adr, (void*) adr, mDtInfo.size);
	return CheckCfg();
}

TStatus CfgBase::Init(OutStream *strm) {
	TStatus st;

	getDataInfo(&mDtInfo);
	if (mDtInfo.size > CFG_REC_MAX_SIZE) {
		strm->oMsgX(colRED, "Cfg to BIG !!!!!");
	}

	st = LoadIntern(CFG_ADDR_RTCRAM);
	if (st == stOK) {
		strm->oMsgX(colWHITE, "Cfg from RTC");
		return st;
	}

	st = framMem->loadCfg(mDtInfo.adr, mDtInfo.size);
	if (st == stOK) {
		st = CheckCfg();
		if (st == stOK) {
			strm->oMsgX(colWHITE, "Cfg from FRAM");
			return st;
		}
	}

	st = LoadIntern(CFG_ADDR_FLASH);
	if (st == stOK) {
		strm->oMsgX(colYELLOW, "Cfg from FLASH");
		return st;
	}
	strm->oMsgX(colRED, "Cfg default");
	Default();
	return stError;
}

TStatus CfgBase::saveFlash() {
	save();
	TStatus st = (TStatus) HAL_FLASH_Unlock();
	if (st == stOK) {
		st = (TStatus) HAL_FLASH_Unlock();
		if (st == stOK) {
			FLASH_EraseInitTypeDef EraseRec;
			uint32_t SectorError;

			EraseRec.TypeErase = FLASH_TYPEERASE_SECTORS;
			EraseRec.VoltageRange = FLASH_VOLTAGE_RANGE_3;
			EraseRec.Sector = FLASH_SECTOR_11;
			EraseRec.NbSectors = 1;
			EraseRec.Banks = FLASH_BANK_1;

			st = (TStatus) HAL_FLASHEx_Erase(&EraseRec, &SectorError);
			if (st == stOK) {
				uint32_t Adr = CFG_ADDR_FLASH;
				uint32_t *src = (uint32_t*) mDtInfo.adr;
				for (int i = 0; i < CFG_REC_MAX_SIZE_4; i++) {
					uint32_t d2 = *src++;
					st = (TStatus) HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, Adr, d2);
					if (st != stOK) {
						break;
					}
					Adr += 4;
				}
			}
			HAL_FLASH_Lock();
		}
	}
	if (memcmp(mDtInfo.adr, (void*) CFG_ADDR_FLASH, mDtInfo.size) != 0)
		st = stCompareErr;
	return st;
}

int CfgBase::FindHistoryNewest() {
	HistoryItem *pHist = mDtInfo.histCfg->tab;
	int idMax = 0;
	int mxIdx = -1;
	for (int i = 0; i < CFG_HIST_CNT; i++) {
		int id = pHist->ID;
		if (id != (int) 0xFFFFFFFF && id != 0) {
			if (id > idMax) {
				idMax = id;
				mxIdx = i;
			}
		}
		pHist++;
	}
	return mxIdx;
}

void CfgBase::showCfgWrHistory(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		int mxIdx = FindHistoryNewest();
		if (mxIdx >= 0) {
			int idx = mxIdx;
			int k = 1;
			do {
				uint16_t pack = mDtInfo.histCfg->tab[idx].packedDate;
				if (pack != 0xFFFF && pack != 0) {
					TDATE tm;
					char txt[16];
					TimeTools::UnPackDate(&tm, pack);
					TimeTools::DateStr(txt, &tm);
					strm->oMsg("%2u.[%2u] %s KEY=%d", k, mDtInfo.histCfg->tab[idx].ID, txt, mDtInfo.histCfg->tab[idx].keySrvNr);
				} else {
					strm->oMsg("%2u.", k);
				}
				if (idx == 0)
					idx = CFG_HIST_CNT;
				idx--;
				k++;
			} while (idx != mxIdx);
		} else {
			strm->oMsg("Historia pusta");
		}
		strm->oClose();
	}
}

void CfgBase::addHistory(uint16_t packDate, uint16_t keySrvnr) {
	int idx = FindHistoryNewest();
	int ID = 0;
	if (idx >= 0) {
		ID = mDtInfo.histCfg->tab[idx].ID;
		if ((mDtInfo.histCfg->tab[idx].keySrvNr == keySrvnr) && (mDtInfo.histCfg->tab[idx].packedDate == packDate)) {
			//nie zapisujemy, taki już był
			return;
		}
	}

	if (++idx == CFG_HIST_CNT)
		idx = 0;
	mDtInfo.histCfg->tab[idx].ID = ID + 1;
	mDtInfo.histCfg->tab[idx].keySrvNr = keySrvnr;
	mDtInfo.histCfg->tab[idx].packedDate = packDate;
}

void CfgBase::zeroHist() {
	memset(mDtInfo.histCfg, 0, sizeof(HistoryCfg));
}

extern "C" OutStream* getOutStream();

TStatus CfgBase::setFromKeyBin(const uint8_t *data, int len) {
	Cpx cpx;

	cpx.init(mDtInfo.dscr, mDtInfo.adr);
	TStatus st = cpx.InsertChanges(getOutStream(), data, len);
	if (st == stOK)
		st = save();
	return st;
}

void CfgBase::getHistMemInfo(MemInfo *memInfo) {
	memInfo->mem = mDtInfo.histCfg;
	memInfo->size = sizeof(HistoryCfg);
}

const char* CfgBase::getSerialNum() {
	return mDtInfo.baseCfg->SerialNr;
}

TStatus CfgBase::setSerialNum(const void *data, int len) {
	if (len > (int) sizeof(BaseCfg::SerialNr) - 1)
		len = sizeof(BaseCfg::SerialNr) - 1;
	memcpy(mDtInfo.baseCfg->SerialNr, data, len);
	mDtInfo.baseCfg->SerialNr[len] = 0;
	return save();
}

//zrobić free dla zwracanego wskaźnika
CxBuf* CfgBase::getCxBufWithCfgBin() {
	int sz = getCfgBinSize();
	CxBuf *buf = new CxBuf(sz, 0x100);
	Cpx cpx;

	cpx.init(mDtInfo.dscr, mDtInfo.adr);
	cpx.buildBinCfg(buf);
	return buf;
}

const ShellItem menuCfg[] = { //
		{ "hist", "pokaż historię zmian" }, //
		{ "list", "pokaż ustawienia , parametr [ |rtc|flash]" }, //
		{ "listk", "pokaż ustawienia z kluczami" }, //
		{ "set", "ustaw wartość" }, //
		{ "setk", "ustaw wartość według klucza" }, //
		{ "default", "wartości domyślne" }, //
		{ "save", "save to Rtc RAM" }, //
		{ "saveflash", "save to Flash" }, //
		{ "init", "reload cfg from FRAM" }, //
		{ "initflash", "reload cfg from Flash" }, //
		{ "def", "pokaż definicje" }, //
		{ "json", "pokaż w postaci json" }, //
		{ "addhist", "dodaj do histori konfiguracji" }, //
		{ "zerohist", "wyzeruj historie" }, //
		{ "dump", "pamięć konfiguracji" }, //
		{ "bin", "dump strumienia konfiguracji" }, //

		{ NULL, NULL } };

void CfgBase::shell(OutStream *strm, const char *cmd) {
	char tok[40];
	int idx = -1;
	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuCfg, tok);
	switch (idx) {
	case 0:  //hist
		showCfgWrHistory(strm);
		break;
	case 1: //list
	{
		Cpx cpx;

		cpx.init(mDtInfo.dscr, mDtInfo.adr);

		if (Token::get(&cmd, tok, sizeof(tok))) {
			if (strcmp(tok, "rtc") == 0) {
				cpx.init(mDtInfo.dscr, (void*) CFG_ADDR_RTCRAM);
				strm->oMsgX(colYELLOW, "RTC");
			} else if (strcmp(tok, "flash") == 0) {
				cpx.init(mDtInfo.dscr, (void*) CFG_ADDR_FLASH);
				strm->oMsgX(colYELLOW, "FLASH");
			}
		}
		cpx.list(strm);
	}
		break;
	case 2: //listk
	{
		Cpx cpx;
		cpx.init(mDtInfo.dscr, mDtInfo.adr);
		cpx.listk(strm);
	}
		break;

	case 3: //set
	{
		if (Token::get(&cmd, tok, sizeof(tok))) {
			char valB[60];
			valB[0] = 0;
			Token::get(&cmd, valB, sizeof(valB));
			Cpx cpx;
			cpx.init(mDtInfo.dscr, mDtInfo.adr);
			if (cpx.set(tok, valB)) {
				strm->oMsgX(colGREEN, "[%s]=(%s) OK", tok, valB);
			} else {
				strm->oMsgX(colRED, "[%s]=(%s) Error", tok, valB);
			}
		}
	}
		break;
	case 4: { //setk
		if (Token::get(&cmd, tok, sizeof(tok))) {
			char valB[60];
			valB[0] = 0;
			Token::get(&cmd, valB, sizeof(valB));
			Cpx cpx;
			cpx.init(mDtInfo.dscr, mDtInfo.adr);
			if (cpx.setk(tok, valB)) {
				strm->oMsgX(colGREEN, "[%s]=(%s) OK", tok, valB);
			} else {
				strm->oMsgX(colRED, "[%s]=(%s) Error", tok, valB);
			}
		}
	}
		break;

	case 5: //default
		strm->oMsgX(colWHITE, "Ustawienia domyślne");
		Default();
		break;
	case 6: { //save
		TStatus st = save();
		strm->oMsgX(getStatusColor(st), "Save to FRAM : %s", getStatusStr(st));
	}
		break;

	case 7: //saveFlash
	{
		TStatus st = saveFlash();
		strm->oMsgX(getStatusColor(st), "Save to Flash & FRAM : %s", getStatusStr(st));
	}
		break;
	case 8: //init
	{
		TStatus st = framMem->loadCfg(mDtInfo.adr, mDtInfo.size);
		if (st == stOK) {
			st = CheckCfg();
		}
		strm->oMsgX(getStatusColor(st), "Load from FRAM : %s", getStatusStr(st));
	}
		break;
	case 9: //initflash
	{
		TStatus st = LoadIntern(CFG_ADDR_FLASH);
		strm->oMsgX(getStatusColor(st), "Load from Flash: %s", getStatusStr(st));
	}
		break;

	case 10: //def
	{
		Cpx cpx;

		cpx.init(mDtInfo.dscr, mDtInfo.adr);
		cpx.showDef(strm);
	}
		break;
	case 11: //json
	{
		int sz = getJsonSize();
		CxString *buf = new CxString(sz);
		Cpx cpx;

		cpx.init(mDtInfo.dscr, mDtInfo.adr);
		cpx.buildjson(buf);

		strm->oWrX(colYELLOW, buf->p());

		delete buf;
	}
		break;
	case 12: { //addhist
		int keySrvnr;
		TDATE tm;

		if (Token::getAsDate(&cmd, &tm)) {
			if (Token::getAsInt(&cmd, &keySrvnr)) {
				uint16_t packDate = TimeTools::PackDate(&tm);
				addHistory(packDate, keySrvnr);
			}
		}
	}
		break;
	case 13: //zerohist;
		zeroHist();
		break;
	case 14: //dump;
		strm->oMsgX(colYELLOW, "adr=%08X cnt=%u", mDtInfo.adr, mDtInfo.size);
		memDump(strm, 0, (uint8_t*) mDtInfo.adr, mDtInfo.size);
		break;
	case 15: { //bin;
		CxBuf *buf = getCxBufWithCfgBin();

		strm->oMsgX(colYELLOW, "cnt=%u", buf->len());
		memDump(strm, 0, buf->mem(), buf->len());

		delete buf;
	}
		break;

	default:
		showHelp(strm, "Config Menu", menuCfg);
		break;
	};

}
